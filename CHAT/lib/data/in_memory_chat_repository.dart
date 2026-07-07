import '../core/theme/app_colors.dart';
import '../domain/models/chat_target.dart';
import '../domain/models/contact.dart';
import '../domain/models/conversation.dart';
import '../domain/models/message.dart';
import '../domain/repositories/chat_repository.dart';
import 'seed_data.dart';

class InMemoryChatRepository extends ChatRepository {
  final List<Message> _messages = SeedData.initialThread();
  ChatTarget? _active;

  @override
  List<Conversation> get conversations => SeedData.conversations;

  @override
  List<Contact> get contacts => SeedData.contacts;

  @override
  ChatTarget? get activeChat => _active;

  @override
  List<Message> get messages => List.unmodifiable(_messages);

  @override
  void openConversation(Conversation c) {
    _active = ChatTarget(
      title: c.name,
      initials: c.initials,
      color: c.color,
      subtitle: c.id == 'sop' ? 'cuenta oficial' : 'en línea',
    );
    notifyListeners();
  }

  @override
  void openChannel(String name) {
    _active = ChatTarget(title: '# $name', initials: '#', color: C.accent, subtitle: 'Equipo Producto · canal');
    notifyListeners();
  }

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
}
