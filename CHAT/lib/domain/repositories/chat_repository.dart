import 'package:flutter/foundation.dart';
import '../models/chat_target.dart';
import '../models/community.dart';
import '../models/contact.dart';
import '../models/conversation.dart';
import '../models/message.dart';

/// Conversaciones, comunidades y el hilo activo.
abstract class ChatRepository extends ChangeNotifier {
  /// Comunidades (isGroup) primero + conversaciones 1:1.
  List<Conversation> get conversations;

  /// Gente conocida, derivada de las conversaciones 1:1.
  List<Contact> get contacts;

  /// Comunidad abierta en la pantalla de grupo.
  Community? get activeCommunity;

  /// Header info for the conversation currently open in the chat screen.
  ChatTarget? get activeChat;

  /// Messages of the active conversation.
  List<Message> get messages;

  /// El otro usuario está escribiendo en el hilo 1:1 activo.
  bool get peerTyping;

  /// channelId → ocupantes del canal de voz (voice.state del servidor).
  Map<String, List<VoiceUser>> get voiceStates;

  Future<void> refresh();
  Future<void> openConversation(Conversation conversation);
  Future<void> openCommunity(String communityId);
  Future<void> openChannel(Channel channel);

  /// null si no hay usuario con ese teléfono.
  Future<Conversation?> startChat(String phone);
  Future<Community> createCommunity(String name);

  /// Código de invitación de [activeCommunity].
  Future<String> createInvite();
  Future<bool> joinInvite(String code);

  Future<void> sendText(String text);
  Future<void> sendMessage(Message message);
  Future<void> sendTyping();

  Future<VoiceTicket> joinVoice(String channelId);
  Future<void> leaveVoice(String channelId);
}
