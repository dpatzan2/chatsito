enum Sender { me, them }
enum MessageType { text, image, video, doc, sticker }

class Message {
  final String id; // ulid del servidor; '' si aún no confirmado
  final Sender sender;
  final MessageType type;
  final String? text, time, docName, docSize, sticker;

  const Message({
    this.id = '',
    required this.sender,
    required this.type,
    this.text,
    this.time,
    this.docName,
    this.docSize,
    this.sticker,
  });

  bool get isMine => sender == Sender.me;

  const Message.text(this.sender, this.text, {this.id = '', this.time})
      : type = MessageType.text, docName = null, docSize = null, sticker = null;
  const Message.image(this.sender, {this.id = '', this.time})
      : type = MessageType.image, text = null, docName = null, docSize = null, sticker = null;
  const Message.video(this.sender, {this.id = '', this.time})
      : type = MessageType.video, text = null, docName = null, docSize = null, sticker = null;
  const Message.doc(this.sender, {this.docName, this.docSize, this.id = '', this.time})
      : type = MessageType.doc, text = null, sticker = null;
  const Message.sticker(this.sender, this.sticker, {this.id = '', this.time})
      : type = MessageType.sticker, text = null, docName = null, docSize = null;
}
