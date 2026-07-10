import 'dart:ui' show Color;

import '../core/theme/app_colors.dart';
import '../domain/models/chat_target.dart';
import '../domain/models/community.dart';
import '../domain/models/contact.dart';
import '../domain/models/conversation.dart';
import '../domain/models/message.dart';
import '../domain/repositories/chat_repository.dart';
import 'seed_data.dart';

class InMemoryChatRepository extends ChatRepository {
  final List<Message> _messages = SeedData.initialThread();
  ChatTarget? _active;
  Community? _activeCommunity;
  final Map<String, List<VoiceUser>> _voice = {};

  @override
  List<Conversation> get conversations => SeedData.conversations;

  @override
  List<Contact> get contacts => SeedData.contacts;

  @override
  Community? get activeCommunity => _activeCommunity;

  @override
  ChatTarget? get activeChat => _active;

  @override
  List<Message> get messages => List.unmodifiable(_messages);

  @override
  bool get peerTyping => false;

  @override
  Map<String, List<VoiceUser>> get voiceStates => _voice;

  @override
  Future<void> refresh() async {}

  @override
  Future<void> openConversation(Conversation c) async {
    _active = ChatTarget(
      title: c.name,
      initials: c.initials,
      color: c.color,
      subtitle: c.id == 'sop' ? 'cuenta oficial' : 'en línea',
    );
    notifyListeners();
  }

  @override
  Future<void> openCommunity(String communityId) async {
    _activeCommunity = Community(
      id: communityId,
      name: 'Equipo Producto',
      ownerId: '',
      channels: const [
        Channel(id: 'ch-general', communityId: 'demo', name: 'general', type: 'text'),
        Channel(id: 'ch-voz', communityId: 'demo', name: 'Sala general', type: 'voice'),
      ],
      roles: const [],
      members: const [],
    );
    notifyListeners();
  }

  @override
  Future<void> openChannel(Channel ch) async {
    _active = ChatTarget(
      title: '# ${ch.name}',
      initials: '#',
      color: C.accent,
      subtitle: '${_activeCommunity?.name ?? 'Equipo Producto'} · canal',
      isChannel: true,
    );
    notifyListeners();
  }

  @override
  Future<Conversation?> startChat(String phone) async => null;

  @override
  Future<Community> createCommunity(String name) async {
    await openCommunity('demo');
    return _activeCommunity!;
  }

  @override
  Future<String> createInvite() async => 'DEMO1234';

  @override
  Future<bool> joinInvite(String code) async => false;

  @override
  Future<void> createChannel(String name, String type) async {
    final c = _activeCommunity;
    if (c == null) return;
    _activeCommunity = Community(
      id: c.id, name: c.name, ownerId: c.ownerId,
      channels: [...c.channels, Channel(id: 'ch-$name', communityId: c.id, name: name, type: type)],
      roles: c.roles, members: c.members,
    );
    notifyListeners();
  }

  @override
  Future<void> leaveCommunity() async {
    _activeCommunity = null;
    notifyListeners();
  }

  @override
  Future<void> createRole(String name, Color? color, BigInt permissions) async {}

  @override
  Future<void> updateRole(String roleId,
      {String? name, Color? color, BigInt? permissions}) async {}

  @override
  Future<void> deleteRole(String roleId) async {}

  @override
  Future<void> setMemberRole(String userId, String roleId, {required bool assign}) async {}

  @override
  Future<void> sendText(String text) async {
    final t = text.trim();
    if (t.isEmpty) return;
    _messages.add(Message.text(Sender.me, t, time: '9:41'));
    notifyListeners();
  }

  @override
  Future<void> sendMessage(Message m) async {
    _messages.add(m);
    notifyListeners();
  }

  @override
  Future<void> sendFile(MessageType type, List<int> bytes, String filename, String mime) async {
    _messages.add(type == MessageType.doc
        ? Message.doc(Sender.me, docName: filename, docSize: '${(bytes.length / 1024).ceil()} KB', time: '9:41')
        : Message.image(Sender.me, time: '9:41'));
    notifyListeners();
  }

  @override
  Future<void> sendTyping() async {}

  @override
  Future<VoiceTicket> joinVoice(String channelId) async {
    _voice[channelId] = [...(_voice[channelId] ?? const []), const VoiceUser('me')];
    notifyListeners();
    return const VoiceTicket('token', 'ws://localhost:7880');
  }

  @override
  Future<void> leaveVoice(String channelId) async {
    _voice.remove(channelId);
    notifyListeners();
  }
}
