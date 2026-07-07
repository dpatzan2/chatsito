import 'package:flutter/foundation.dart';
import '../../app/app_router.dart';
import '../../domain/models/chat_target.dart';
import '../../domain/models/conversation.dart';
import '../../domain/models/message.dart';
import '../../domain/repositories/chat_repository.dart';

/// Presentation state for the chat screen: draft text and the open sheets.
/// Message data lives in [ChatRepository].
class ChatController extends ChangeNotifier {
  final ChatRepository _chat;
  final AppRouter _router;
  ChatController(this._chat, this._router);

  String draft = '';
  bool attachOpen = false, emojiOpen = false, stickerTab = false;

  List<Message> get messages => _chat.messages;
  ChatTarget? get target => _chat.activeChat;
  bool get hasDraft => draft.trim().isNotEmpty;

  void openConversation(Conversation c) {
    _resetSheets();
    if (c.isGroup) {
      _router.go(AppScreen.group);
      return;
    }
    _chat.openConversation(c);
    _router.go(AppScreen.chat);
  }

  void openChannel(String name) {
    _resetSheets();
    _chat.openChannel(name);
    _router.go(AppScreen.chat);
  }

  void openContactProfile() => _router.go(AppScreen.contactProfile);
  void backToChats() => _router.go(AppScreen.chats);
  void backToChat() => _router.go(AppScreen.chat);

  void setDraft(String v) { draft = v; notifyListeners(); }
  void addEmoji(String glyph) { draft += glyph; notifyListeners(); }

  Future<void> send() async {
    if (!hasDraft) return;
    await _chat.sendText(draft);
    draft = '';
    emojiOpen = false;
    notifyListeners();
  }

  Future<void> sendSticker(String glyph) async {
    await _chat.sendMessage(Message.sticker(Sender.me, glyph, time: '9:41'));
    _resetSheets();
    notifyListeners();
  }

  Future<void> sendAttachment(MessageType type) async {
    final m = switch (type) {
      MessageType.image => const Message.image(Sender.me, time: '9:41'),
      MessageType.video => const Message.video(Sender.me, time: '9:41'),
      MessageType.doc => const Message.doc(Sender.me, docName: 'Informe_final.pdf', docSize: '1,8 MB · PDF', time: '9:41'),
      _ => null,
    };
    if (m != null) await _chat.sendMessage(m);
    attachOpen = false;
    notifyListeners();
  }

  void toggleAttach() { attachOpen = !attachOpen; emojiOpen = false; notifyListeners(); }
  void toggleEmoji() { emojiOpen = !emojiOpen; attachOpen = false; stickerTab = false; notifyListeners(); }
  void closeSheets() { _resetSheets(); notifyListeners(); }
  void setStickerTab(bool v) { stickerTab = v; notifyListeners(); }

  void _resetSheets() { attachOpen = false; emojiOpen = false; }
}
