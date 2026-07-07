import 'package:flutter/foundation.dart';
import '../models/chat_target.dart';
import '../models/contact.dart';
import '../models/conversation.dart';
import '../models/message.dart';

/// Conversations, contacts and the active message thread.
abstract class ChatRepository extends ChangeNotifier {
  List<Conversation> get conversations;
  List<Contact> get contacts;

  /// Header info for the conversation currently open in the chat screen.
  ChatTarget? get activeChat;

  /// Messages of the active conversation.
  List<Message> get messages;

  void openConversation(Conversation conversation);
  void openChannel(String channelName);

  Future<void> sendText(String text);
  Future<void> sendMessage(Message message);
}
