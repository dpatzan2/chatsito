import 'package:chatsito/app/app_router.dart';
import 'package:chatsito/data/in_memory_chat_repository.dart';
import 'package:chatsito/domain/models/message.dart';
import 'package:chatsito/features/chat/chat_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late InMemoryChatRepository chat;
  late ChatController c;

  setUp(() {
    chat = InMemoryChatRepository();
    c = ChatController(chat, AppRouter());
  });

  test('send appends a trimmed message and clears the draft', () async {
    final before = chat.messages.length;
    c.setDraft('   ');
    await c.send(); // blank ignored
    expect(chat.messages.length, before);

    c.setDraft('  hola  ');
    await c.send();
    expect(chat.messages.length, before + 1);
    expect(chat.messages.last.text, 'hola');
    expect(chat.messages.last.isMine, true);
    expect(c.draft, '');
  });

  test('opening a group conversation routes to the group screen', () {
    final router = AppRouter();
    final ctrl = ChatController(chat, router);
    final group = chat.conversations.firstWhere((c) => c.isGroup);
    ctrl.openConversation(group);
    expect(router.screen, AppScreen.group);
  });

  test('back desde un canal vuelve a la comunidad, no a chats', () async {
    final router = AppRouter();
    final ctrl = ChatController(chat, router);
    await chat.openCommunity('demo');
    ctrl.openChannel(chat.activeCommunity!.channels.first);
    ctrl.backToChats();
    expect(router.screen, AppScreen.group);
  });

  test('back desde un 1:1 vuelve a chats', () async {
    final router = AppRouter();
    final ctrl = ChatController(chat, router);
    ctrl.openConversation(chat.conversations.firstWhere((c) => !c.isGroup));
    ctrl.backToChats();
    expect(router.screen, AppScreen.chats);
  });

  test('openDetails: 1:1 → contactProfile, canal → channelDetail', () async {
    final router = AppRouter();
    final ctrl = ChatController(chat, router);
    ctrl.openConversation(chat.conversations.firstWhere((c) => !c.isGroup));
    ctrl.openDetails();
    expect(router.screen, AppScreen.contactProfile);
    await chat.openCommunity('demo');
    ctrl.openChannel(chat.activeCommunity!.channels.first);
    ctrl.openDetails();
    expect(router.screen, AppScreen.channelDetail);
  });

  test('sendFile(doc) posts a document message', () async {
    await c.sendFile(MessageType.doc, [1, 2, 3], 'informe.pdf', 'application/pdf');
    expect(chat.messages.last.type, MessageType.doc);
    expect(chat.messages.last.docName, 'informe.pdf');
  });
}
