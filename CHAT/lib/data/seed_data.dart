import 'package:flutter/material.dart';
import '../domain/models/channels.dart';
import '../domain/models/contact.dart';
import '../domain/models/conversation.dart';
import '../domain/models/message.dart';

/// Static demo content. A backend implementation would fetch the equivalent.
class SeedData {
  static const conversations = <Conversation>[
    Conversation(id: 'laura', name: 'Laura Méndez', lastMessage: 'Perfecto, lo reviso ahora mismo', time: '9:28', initials: 'LM', color: Color(0xFF7C5CFF)),
    Conversation(id: 'team', name: 'Equipo Producto', lastMessage: 'Diego: subí el mockup al canal #diseño', time: '9:15', initials: 'EP', color: Color(0xFF2A9D8F), unread: 3, isGroup: true),
    Conversation(id: 'carlos', name: 'Carlos Ruiz', lastMessage: '¿Nos vemos a las 3 para la review?', time: 'Ayer', initials: 'CR', color: Color(0xFFE76F51), unread: 1),
    Conversation(id: 'ana', name: 'Ana Torres', lastMessage: '¡Gracias! 🙏 Te debo un café', time: 'Ayer', initials: 'AT', color: Color(0xFF457B9D)),
    Conversation(id: 'sop', name: 'Soporte Chatsito', lastMessage: 'Tu cuenta está verificada ✅', time: 'Lun', initials: 'SC', color: Color(0xFF8A8D99)),
  ];

  static const contacts = <Contact>[
    Contact(id: 'laura', name: 'Laura Méndez', initials: 'LM', color: Color(0xFF7C5CFF)),
    Contact(id: 'carlos', name: 'Carlos Ruiz', initials: 'CR', color: Color(0xFFE76F51)),
    Contact(id: 'ana', name: 'Ana Torres', initials: 'AT', color: Color(0xFF457B9D)),
    Contact(id: 'diego', name: 'Diego Salas', initials: 'DS', color: Color(0xFF2A9D8F)),
    Contact(id: 'marta', name: 'Marta Reyes', initials: 'MR', color: Color(0xFFC13D9E)),
    Contact(id: 'javi', name: 'Javier Núñez', initials: 'JN', color: Color(0xFF1F8AC0)),
  ];

  static List<Message> initialThread() => [
        const Message.text(Sender.them, '¡Hola! ¿Listo para la demo de mañana?', time: '9:24'),
        const Message.text(Sender.me, 'Sí, todo preparado 👍 Ya cerré los últimos detalles.', time: '9:25'),
        const Message.image(Sender.them, time: '9:26'),
        const Message.text(Sender.them, 'Mira cómo quedó la pantalla nueva ✨', time: '9:26'),
        const Message.doc(Sender.me, docName: 'Propuesta_Q3.pdf', docSize: '2,4 MB · PDF', time: '9:27'),
        const Message.text(Sender.them, 'Perfecto, lo reviso ahora mismo', time: '9:28'),
      ];

  static const emojis = ['😀','😂','🥹','😍','😎','🤩','🥳','😘','🤔','😴','🙄','😇','😅','🤗','🫶','🙌','👍','👏','🙏','🔥','✨','🎉','❤️','💜','💯','✅','📌','💡','🚀','📎','🎯','☕'];
  static const stickers = ['🐱','🦊','🐼','🚀','🌮','🎸','👾','🦄','🍕'];

  static const textChannels = <TextChannel>[
    TextChannel('general'),
    TextChannel('anuncios'),
    TextChannel('diseño', badge: 5, active: true),
    TextChannel('desarrollo', badge: 2),
  ];

  /// Voice members excluding the current user ("Tú"), which is appended at runtime.
  static const voiceCallOthers = <VoiceMember>[
    VoiceMember(name: 'Ana Torres', initials: 'AT', color: Color(0xFF457B9D), speaking: true),
    VoiceMember(name: 'Diego Salas', initials: 'DS', color: Color(0xFFE76F51), muted: true),
    VoiceMember(name: 'Marta R.', initials: 'MR', color: Color(0xFF2A9D8F)),
  ];

  static const salaGeneralOthers = <VoiceMember>[
    VoiceMember(name: 'Ana Torres', initials: 'AT', color: Color(0xFF457B9D), speaking: true),
    VoiceMember(name: 'Diego Salas', initials: 'DS', color: Color(0xFFE76F51), muted: true),
  ];
}
