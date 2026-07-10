import 'dart:async';
import 'dart:ui' show Color;

import '../core/theme/app_colors.dart';
import '../domain/models/chat_target.dart';
import '../domain/models/community.dart';
import '../domain/models/contact.dart';
import '../domain/models/conversation.dart';
import '../domain/models/message.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/chat_repository.dart';
import 'api/api_client.dart';
import 'api/wire.dart';
import 'api/ws_client.dart';

class ApiChatRepository extends ChatRepository {
  final ApiClient _api;
  final WsClient _ws;
  final AuthRepository _auth;
  late final StreamSubscription<WsEvent> _sub;

  List<Conversation> _oneToOnes = [];
  List<Map<String, dynamic>> _communityRows = [];
  Community? _activeCommunity;
  ChatTarget? _active;
  String? _activeConversationId, _activeChannelId;
  List<Message> _messages = [];
  bool _peerTyping = false;
  Timer? _typingReset;
  DateTime _lastTypingSent = DateTime.fromMillisecondsSinceEpoch(0);
  final Map<String, List<VoiceUser>> _voice = {};

  ApiChatRepository(this._api, this._ws, this._auth) {
    _sub = _ws.events.listen(_onEvent);
    _auth.addListener(_onAuth);
    _onAuth();
  }

  String get _me => _auth.user.id;

  void _onAuth() {
    if (_me.isEmpty) return;
    _ws.connect().catchError((_) {}); // el WsClient reintenta solo
    refresh();
  }

  @override
  List<Conversation> get conversations => [
        for (final c in _communityRows)
          Conversation(
            id: c['id'] as String,
            name: c['name'] as String,
            lastMessage: wireStrings.community,
            time: '',
            initials: initialsOf(c['name'] as String),
            color: C.accent,
            isGroup: true,
            unread: (c['unread'] as int?) ?? 0,
          ),
        ..._oneToOnes,
      ];

  @override
  List<Contact> get contacts => [
        for (final c in _oneToOnes)
          Contact(id: c.id, name: c.name, initials: c.initials, color: c.color),
      ];

  @override
  Community? get activeCommunity => _activeCommunity;

  @override
  ChatTarget? get activeChat => _active;

  @override
  List<Message> get messages => List.unmodifiable(_messages);

  @override
  bool get peerTyping => _peerTyping;

  @override
  Map<String, List<VoiceUser>> get voiceStates => _voice;

  @override
  Future<void> refresh() async {
    try {
      final convs = await _api.send('GET', '/conversations') as List? ?? const [];
      final comms = await _api.send('GET', '/communities') as List? ?? const [];
      _oneToOnes = [
        for (final c in convs)
          conversationFromWire((c as Map).cast<String, dynamic>(), _me),
      ];
      _communityRows = [for (final c in comms) (c as Map).cast<String, dynamic>()];
      notifyListeners();
    } on ApiException {
      // sin sesión o backend caído: se reintenta en el siguiente evento
    }
  }

  @override
  Future<void> openConversation(Conversation c) async {
    _activeConversationId = c.id;
    _activeChannelId = null;
    _peerTyping = false;
    _active = ChatTarget(
        title: c.name, initials: c.initials, color: c.color, subtitle: wireStrings.online,
        phone: c.phone);
    _messages = [];
    notifyListeners();
    final r = await _api.send('GET', '/conversations/${c.id}/messages') as Map;
    _messages = [
      for (final m in (r['messages'] as List).reversed)
        messageFromWire((m as Map).cast<String, dynamic>(), _me, baseUrl: _api.baseUrl),
    ];
    _oneToOnes = [for (final x in _oneToOnes) x.id == c.id ? x.copyWith(unread: 0) : x];
    notifyListeners();
    _markRead({'conversationId': c.id});
  }

  Future<void> _markRead(Map<String, dynamic> target) async {
    final last = _messages.isEmpty ? null : _messages.last;
    if (last == null || last.id.isEmpty) return;
    await _ws
        .request('read.mark', {...target, 'messageId': last.id})
        .catchError((_) => <String, dynamic>{});
  }

  @override
  Future<void> openCommunity(String communityId) async {
    final j = await _api.send('GET', '/communities/$communityId') as Map;
    _activeCommunity = communityFromWire(j.cast<String, dynamic>());
    notifyListeners();
  }

  @override
  Future<void> openChannel(Channel ch) async {
    _activeChannelId = ch.id;
    _activeConversationId = null;
    _peerTyping = false;
    _active = ChatTarget(
      title: '# ${ch.name}',
      initials: '#',
      color: C.accent,
      subtitle: '${_activeCommunity?.name ?? wireStrings.community} · ${wireStrings.channel}',
      isChannel: true,
    );
    _messages = [];
    notifyListeners();
    final r = await _api.send('GET', '/channels/${ch.id}/messages') as Map;
    _messages = [
      for (final m in (r['messages'] as List).reversed)
        messageFromWire((m as Map).cast<String, dynamic>(), _me, baseUrl: _api.baseUrl),
    ];
    notifyListeners();
    await _markRead({'channelId': ch.id});
    await openCommunity(ch.communityId).catchError((_) {});
    await refresh();
  }

  @override
  Future<Conversation?> startChat(String phone) async {
    final Map u;
    try {
      u = await _api.send('GET', '/users/lookup', query: {'phone': phone}) as Map;
    } on ApiException catch (e) {
      if (e.code == 'NOT_FOUND' || e.code == 'VALIDATION') return null;
      rethrow;
    }
    final r = await _api.send('POST', '/conversations', body: {'userId': u['id']}) as Map;
    await refresh();
    final id = r['id'] as String;
    for (final c in _oneToOnes) {
      if (c.id == id) return c;
    }
    return conversationFromWire(
        {'id': id, 'other': r['other'], 'lastMessage': null, 'unread': 0}, _me);
  }

  @override
  Future<Community> createCommunity(String name) async {
    final j = await _api.send('POST', '/communities', body: {'name': name}) as Map;
    _activeCommunity = communityFromWire(j.cast<String, dynamic>());
    await refresh();
    return _activeCommunity!;
  }

  @override
  Future<String> createInvite() async {
    final c = _activeCommunity;
    if (c == null) return '';
    final j = await _api.send('POST', '/communities/${c.id}/invites') as Map;
    return j['code'] as String;
  }

  @override
  Future<bool> joinInvite(String code) async {
    try {
      final j = await _api.send('POST', '/invites/${code.trim().toUpperCase()}/join') as Map;
      _activeCommunity = communityFromWire(j.cast<String, dynamic>());
      await refresh();
      return true;
    } on ApiException {
      return false;
    }
  }

  @override
  Future<void> createChannel(String name, String type) async {
    final c = _activeCommunity;
    if (c == null) return;
    await _api.send('POST', '/communities/${c.id}/channels',
        body: {'name': name, 'type': type});
    await openCommunity(c.id);
  }

  @override
  Future<void> leaveCommunity() async {
    final c = _activeCommunity;
    if (c == null) return;
    await _api.send('DELETE', '/communities/${c.id}/members/$_me');
    _activeCommunity = null;
    await refresh();
  }

  @override
  Future<void> sendFile(MessageType type, List<int> bytes, String filename, String mime) async {
    final up = await _api.upload(bytes, filename, mime);
    final content = switch (type) {
      MessageType.doc => {
          'url': up['url'], 'name': up['name'],
          'size': _humanSize(up['size'] as int), 'mime': mime,
        },
      _ => {'url': up['url'], 'mime': mime},
    };
    await _send(type.name, content);
  }

  String _humanSize(int bytes) => bytes < 1024 * 1024
      ? '${(bytes / 1024).ceil()} KB'
      : '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';

  @override
  Future<void> createRole(String name, Color? color, BigInt permissions) async {
    final c = _activeCommunity;
    if (c == null) return;
    await _api.send('POST', '/communities/${c.id}/roles', body: {
      'name': name,
      if (color != null) 'color': hexOf(color),
      'permissions': permissions.toString(),
    });
    await openCommunity(c.id);
  }

  @override
  Future<void> updateRole(String roleId,
      {String? name, Color? color, BigInt? permissions}) async {
    final c = _activeCommunity;
    if (c == null) return;
    await _api.send('PATCH', '/communities/${c.id}/roles/$roleId', body: {
      if (name != null && name.isNotEmpty) 'name': name,
      if (color != null) 'color': hexOf(color),
      if (permissions != null) 'permissions': permissions.toString(),
    });
    await openCommunity(c.id);
  }

  @override
  Future<void> deleteRole(String roleId) async {
    final c = _activeCommunity;
    if (c == null) return;
    await _api.send('DELETE', '/communities/${c.id}/roles/$roleId');
    await openCommunity(c.id);
  }

  @override
  Future<void> setMemberRole(String userId, String roleId, {required bool assign}) async {
    final c = _activeCommunity;
    if (c == null) return;
    await _api.send(
        assign ? 'PUT' : 'DELETE', '/communities/${c.id}/members/$userId/roles/$roleId');
    await openCommunity(c.id);
  }

  @override
  Future<void> sendText(String text) async {
    final t = text.trim();
    if (t.isEmpty) return;
    await _send('text', {'text': t});
  }

  @override
  Future<void> sendMessage(Message m) => _send(m.type.name, wireContent(m));

  // Sin append optimista: el hub nos manda el eco msg.new y ahí se pinta.
  Future<void> _send(String type, Map<String, dynamic> content) async {
    final Map<String, dynamic> target;
    if (_activeChannelId != null) {
      target = {'channelId': _activeChannelId};
    } else if (_activeConversationId != null) {
      target = {'conversationId': _activeConversationId};
    } else {
      return;
    }
    await _ws.request('msg.send', {...target, 'type': type, 'content': content});
  }

  @override
  Future<void> sendTyping() async {
    final cid = _activeConversationId;
    if (cid == null) return;
    final now = DateTime.now();
    if (now.difference(_lastTypingSent).inSeconds < 3) return;
    _lastTypingSent = now;
    await _ws
        .request('typing.start', {'conversationId': cid}).catchError((_) => <String, dynamic>{});
  }

  @override
  Future<VoiceTicket> joinVoice(String channelId) async {
    final ready = _ws.events
        .firstWhere((e) => e.op == 'voice.ready' && e.d['channelId'] == channelId);
    await _ws.request('voice.join', {'channelId': channelId});
    final d = (await ready).d;
    _voice[channelId] = _voiceUsers(d['members']);
    notifyListeners();
    return VoiceTicket(d['token'] as String, d['url'] as String);
  }

  @override
  Future<void> leaveVoice(String channelId) async {
    await _ws.request('voice.leave', {'channelId': channelId});
  }

  List<VoiceUser> _voiceUsers(dynamic members) => [
        for (final m in (members as List? ?? const []))
          VoiceUser((m as Map)['userId'] as String, muted: (m['muted'] as bool?) ?? false),
      ];

  void _onEvent(WsEvent e) {
    switch (e.op) {
      case 'sys.open':
        refresh();
        final cid = _activeCommunity?.id;
        if (cid != null) openCommunity(cid).catchError((_) {});
      case 'msg.new':
        _onMsgNew(e.d);
      case 'msg.deleted':
        _messages = [for (final m in _messages) if (m.id != e.d['id']) m];
        notifyListeners();
      case 'typing':
        if (e.d['conversationId'] == _activeConversationId && e.d['userId'] != _me) {
          _peerTyping = true;
          _typingReset?.cancel();
          _typingReset = Timer(const Duration(seconds: 4), () {
            _peerTyping = false;
            notifyListeners();
          });
          notifyListeners();
        }
      case 'voice.state':
        _voice[e.d['channelId'] as String] = _voiceUsers(e.d['members']);
        notifyListeners();
      case 'presence':
        final c = _activeCommunity;
        if (c == null) return;
        _activeCommunity = Community(
          id: c.id, name: c.name, ownerId: c.ownerId, channels: c.channels, roles: c.roles,
          members: [for (final m in c.members)
            m.id == e.d['userId'] ? m.withOnline(e.d['online'] as bool? ?? false) : m],
        );
        notifyListeners();
      case 'community.updated' || 'community.deleted' || 'channel.created' ||
            'channel.updated' || 'channel.deleted' || 'role.created' || 'role.updated' ||
            'role.deleted' || 'member.joined' || 'member.left' || 'member.updated' ||
            'override.updated':
        // ponytail: refetch en vez de aplicar deltas
        refresh();
        final cid = (e.d['communityId'] ?? e.d['id']) as String?;
        if (cid != null && cid == _activeCommunity?.id) {
          openCommunity(cid).catchError((_) => _clearCommunity(e.op));
        }
    }
  }

  void _clearCommunity(String op) {
    if (op == 'community.deleted' || op == 'member.left') {
      _activeCommunity = null;
      notifyListeners();
    }
  }

  void _onMsgNew(Map<String, dynamic> d) {
    final inActive = (d['conversationId'] != null &&
            d['conversationId'] == _activeConversationId) ||
        (d['channelId'] != null && d['channelId'] == _activeChannelId);
    if (inActive) {
      _messages = [..._messages, messageFromWire(d, _me, baseUrl: _api.baseUrl)];
      _peerTyping = false;
      notifyListeners();
      if (d['authorId'] != _me) {
        final target = d['conversationId'] != null
            ? {'conversationId': d['conversationId']}
            : {'channelId': d['channelId']};
        _ws
            .request('read.mark', {...target, 'messageId': d['id']})
            .catchError((_) => <String, dynamic>{});
      }
    }
    // ponytail: recarga las listas por mensaje; deltas locales si duele
    refresh();
    final cid = _activeCommunity?.id;
    if (d['channelId'] != null && cid != null) openCommunity(cid).catchError((_) {});
  }

  @override
  void dispose() {
    _sub.cancel();
    _typingReset?.cancel();
    _auth.removeListener(_onAuth);
    _ws.close();
    super.dispose();
  }
}
