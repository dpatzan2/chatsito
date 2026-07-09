import 'package:flutter/foundation.dart';
import '../../app/app_router.dart';
import '../../domain/models/community.dart';
import '../../domain/models/contact.dart';
import '../../domain/repositories/chat_repository.dart';

/// New-community flow: name, creation and invite codes.
class GroupController extends ChangeNotifier {
  final ChatRepository _chat;
  final AppRouter _router;
  GroupController(this._chat, this._router);

  final Map<String, bool> _selected = {};
  String groupName = '';
  String inviteCode = '';

  List<Contact> get contacts => _chat.contacts;
  bool isSelected(String id) => _selected[id] ?? false;
  int get selectedCount => _selected.values.where((v) => v).length;

  void openCreate() => _router.go(AppScreen.createGroup);
  void back() => _router.go(AppScreen.chats);

  void toggle(String id) { _selected[id] = !isSelected(id); notifyListeners(); }
  void setGroupName(String v) { groupName = v; notifyListeners(); }

  // ponytail: la selección de contactos es decorativa — los miembros reales
  // entran con el código de invitación (el backend no tiene "añadir miembro").
  Future<void> create() async {
    final name = groupName.trim().isEmpty ? 'Nueva comunidad' : groupName.trim();
    await _chat.createCommunity(name);
    _router.go(AppScreen.group);
  }

  /// Crea un código de invitación de la comunidad activa y abre la pantalla.
  Future<void> openInvite() async {
    inviteCode = await _chat.createInvite();
    _router.go(AppScreen.invite);
    notifyListeners();
  }

  Role? editingRole; // null = creando uno nuevo

  void openRoles() => _router.go(AppScreen.roles);

  void openRole(Role? role) {
    editingRole = role;
    _router.go(AppScreen.roleEdit);
    notifyListeners();
  }

  void closeRoleEdit() => _router.go(AppScreen.roles);
  void closeRoles() => _router.go(AppScreen.group);

  void closeInvite() {
    final to = inviteCode.isEmpty ? AppScreen.settings : AppScreen.group;
    inviteCode = '';
    _router.go(to);
  }
}
