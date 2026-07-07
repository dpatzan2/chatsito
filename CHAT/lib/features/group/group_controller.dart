import 'package:flutter/foundation.dart';
import '../../app/app_router.dart';
import '../../domain/models/contact.dart';
import '../../domain/repositories/chat_repository.dart';

/// New-group flow: participant selection and group name.
class GroupController extends ChangeNotifier {
  final ChatRepository _chat;
  final AppRouter _router;
  GroupController(this._chat, this._router);

  final Map<String, bool> _selected = {'ana': true, 'diego': true};
  String groupName = '';

  List<Contact> get contacts => _chat.contacts;
  bool isSelected(String id) => _selected[id] ?? false;
  int get selectedCount => _selected.values.where((v) => v).length;

  void openCreate() => _router.go(AppScreen.createGroup);
  void back() => _router.go(AppScreen.chats);

  void toggle(String id) { _selected[id] = !isSelected(id); notifyListeners(); }
  void setGroupName(String v) { groupName = v; notifyListeners(); }
  void create() => _router.go(AppScreen.group);
}
