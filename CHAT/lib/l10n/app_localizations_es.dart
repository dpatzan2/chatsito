// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class SEs extends S {
  SEs([String locale = 'es']) : super(locale);

  @override
  String get welcomeTagline =>
      'Mensajería privada para tu equipo. Chats, grupos, canales de voz y mucho más.';

  @override
  String get welcomeCta => 'Continuar con tu número';

  @override
  String get legalPrefix => 'Al continuar aceptas los ';

  @override
  String get legalTerms => 'Términos';

  @override
  String get legalAnd => ' y la ';

  @override
  String get legalPrivacy => 'Política de privacidad';

  @override
  String get legalSuffix => ' de Chatsito.';

  @override
  String get phoneTitle => 'Tu número de teléfono';

  @override
  String get phoneSubtitle =>
      'Te enviaremos un SMS con un código de 6 dígitos para verificar tu cuenta.';

  @override
  String get phoneCarrierFee => 'Puede que se apliquen tarifas de tu operador.';

  @override
  String get phoneCta => 'Enviar código';

  @override
  String get searchCountry => 'Buscar país';

  @override
  String get otpTitle => 'Verifica tu número';

  @override
  String get otpSentTo => 'Introduce el código enviado al ';

  @override
  String get otpNotReceived => '¿No llegó?';

  @override
  String otpResendIn(Object time) {
    return 'Reenviar en $time';
  }

  @override
  String get profileTitle => 'Configura tu perfil';

  @override
  String get profileSubtitle =>
      'Pon tu nombre y una foto. Podrás cambiarlos cuando quieras.';

  @override
  String get profileNameLabel => 'Tu nombre';

  @override
  String get profileNameHint => 'Ej. Marta García';

  @override
  String get profileCta => 'Empezar a chatear';

  @override
  String get chatsTitle => 'Chats';

  @override
  String get searchHint => 'Buscar';

  @override
  String get newChat => 'Nuevo chat';

  @override
  String get newCommunity => 'Nueva comunidad';

  @override
  String get joinWithCode => 'Unirme con código';

  @override
  String get newChatHint => 'Teléfono (solo dígitos)';

  @override
  String get newChatAction => 'Abrir chat';

  @override
  String get newChatError => 'No hay ningún usuario con ese número';

  @override
  String get joinTitle => 'Unirme a una comunidad';

  @override
  String get joinHint => 'Código de invitación';

  @override
  String get joinAction => 'Unirme';

  @override
  String get joinError => 'Código inválido o caducado';

  @override
  String get newTextChannel => 'Nuevo canal de texto';

  @override
  String get newVoiceChannel => 'Nuevo canal de voz';

  @override
  String get channelNameHint => 'Nombre del canal';

  @override
  String get createChannelAction => 'Crear';

  @override
  String get channelCreateError => 'No se pudo crear el canal';

  @override
  String get cancel => 'Cancelar';

  @override
  String get navChats => 'Chats';

  @override
  String get navGroups => 'Grupos';

  @override
  String get navCalls => 'Llamadas';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get today => 'Hoy';

  @override
  String get typing => 'escribiendo…';

  @override
  String get messageHint => 'Mensaje';

  @override
  String get attachCamera => 'Cámara';

  @override
  String get attachGallery => 'Galería';

  @override
  String get attachVideo => 'Vídeo';

  @override
  String get attachDocument => 'Documento';

  @override
  String get attachAudio => 'Audio';

  @override
  String get attachLocation => 'Ubicación';

  @override
  String get attachContact => 'Contacto';

  @override
  String get attachPoll => 'Encuesta';

  @override
  String get newGroupTitle => 'Nuevo grupo';

  @override
  String participantsSelected(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n participantes seleccionados',
      one: '1 participante seleccionado',
    );
    return '$_temp0';
  }

  @override
  String get groupNameHint => 'Nombre del grupo';

  @override
  String get addParticipants => 'Añadir participantes';

  @override
  String get createGroupCta => 'Crear grupo';

  @override
  String get communityFallback => 'Comunidad';

  @override
  String membersCount(Object n) {
    return '$n miembros';
  }

  @override
  String get textChannels => 'Canales de texto';

  @override
  String get voiceChannels => 'Canales de voz';

  @override
  String get voiceEmpty => 'Vacío';

  @override
  String voiceConnected(Object n) {
    return '$n conectados';
  }

  @override
  String get connecting => 'Conectando…';

  @override
  String voiceChannelSubtitle(Object name) {
    return 'Canal de voz · $name';
  }

  @override
  String get rolesTitle => 'Roles';

  @override
  String get newRole => 'Nuevo rol';

  @override
  String get roleNameLabel => 'Nombre';

  @override
  String get roleNameHint => 'Nombre del rol';

  @override
  String get roleColor => 'Color';

  @override
  String get rolePermissions => 'Permisos';

  @override
  String get roleMembers => 'Miembros';

  @override
  String get createRoleCta => 'Crear rol';

  @override
  String get saveRole => 'Guardar';

  @override
  String get permViewChannel => 'Ver canales';

  @override
  String get permSendMessages => 'Enviar mensajes';

  @override
  String get permManageMessages => 'Gestionar mensajes';

  @override
  String get permManageChannels => 'Gestionar canales';

  @override
  String get permManageRoles => 'Gestionar roles';

  @override
  String get permKickMembers => 'Expulsar miembros';

  @override
  String get permManageInvites => 'Crear invitaciones';

  @override
  String get permVoiceConnect => 'Conectarse a voz';

  @override
  String get permVoiceSpeak => 'Hablar en voz';

  @override
  String get permVoiceMuteMembers => 'Silenciar a otros';

  @override
  String get permAdmin => 'Administrador';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get availableVerified => 'Disponible · ✓ verificado';

  @override
  String get setAccount => 'Cuenta';

  @override
  String get setPrivacy => 'Privacidad';

  @override
  String get setChats => 'Chats';

  @override
  String get setNotifications => 'Notificaciones';

  @override
  String get setStorage => 'Almacenamiento y datos';

  @override
  String get setHelp => 'Ayuda';

  @override
  String get setInvite => 'Invitar a un amigo';

  @override
  String get inviteCommunityTitle => 'Invitar a la comunidad';

  @override
  String get inviteFriendTitle => 'Invitar a un amigo';

  @override
  String get inviteCommunityHeading => 'Invita gente a la comunidad';

  @override
  String get inviteFriendHeading => 'Invita a tu equipo a Chatsito';

  @override
  String get inviteCommunityCopy =>
      'Comparte este código: en Chatsito, \"Unirme con código\". Caduca en 7 días.';

  @override
  String get inviteFriendCopy =>
      'Comparte tu enlace personal. Cuando se unan, los verás en tus chats al instante.';

  @override
  String get copyAction => 'Copiar';

  @override
  String get shareMessage => 'Mensaje';

  @override
  String get shareEmail => 'Correo';

  @override
  String get shareMore => 'Más';

  @override
  String get done => 'Listo';

  @override
  String get shareLink => 'Compartir enlace';

  @override
  String get actionAudio => 'Audio';

  @override
  String get actionVideo => 'Vídeo';

  @override
  String get actionSearch => 'Buscar';

  @override
  String get actionMute => 'Silenciar';

  @override
  String get aboutHeader => 'Acerca de';

  @override
  String get aboutSample =>
      'Disponible ✨ Diseñando cosas bonitas en el equipo de producto.';

  @override
  String get mediaFiles => 'Multimedia y archivos';

  @override
  String get seeAll => 'Ver todo ›';

  @override
  String get muteNotifications => 'Silenciar notificaciones';

  @override
  String get tempMessages => 'Mensajes temporales';

  @override
  String get disabled => 'Desactivado';

  @override
  String get encryption => 'Cifrado';

  @override
  String get verified => 'Verificado';

  @override
  String blockContact(Object name) {
    return 'Bloquear a $name';
  }

  @override
  String get reportContact => 'Reportar contacto';

  @override
  String get e2eNotice => 'Tus mensajes están cifrados de extremo a extremo.';

  @override
  String get catInfo => 'Información';

  @override
  String get catPhoneNumber => 'Número de teléfono';

  @override
  String get catChangeNumber => 'Cambiar número';

  @override
  String get catEmail => 'Correo electrónico';

  @override
  String get catAdd => 'Añadir';

  @override
  String get catRequestInfo => 'Solicitar información de mi cuenta';

  @override
  String get catDeleteAccount => 'Eliminar mi cuenta';

  @override
  String get catWhoCanSee => 'Quién puede ver mi info';

  @override
  String get catLastSeen => 'Última vez y en línea';

  @override
  String get catEveryone => 'Todos';

  @override
  String get catProfilePhoto => 'Foto de perfil';

  @override
  String get catMyContacts => 'Mis contactos';

  @override
  String get catStatus => 'Estado';

  @override
  String get catReadReceipts => 'Confirmaciones de lectura';

  @override
  String get catBlocked => 'Contactos bloqueados';

  @override
  String get catScreenLock => 'Bloqueo con código';

  @override
  String get catDisplay => 'Pantalla';

  @override
  String get catTheme => 'Tema';

  @override
  String get catLight => 'Claro';

  @override
  String get catWallpaper => 'Fondo de pantalla';

  @override
  String get catFontSize => 'Tamaño de fuente';

  @override
  String get catMedium => 'Mediano';

  @override
  String get catEnterToSend => 'Tecla Enter para enviar';

  @override
  String get catSaveToRoll => 'Guardar en el carrete';

  @override
  String get catBackup => 'Copia de seguridad';

  @override
  String get catChatHistory => 'Historial de chats';

  @override
  String get catMessages => 'Mensajes';

  @override
  String get catShowNotifications => 'Mostrar notificaciones';

  @override
  String get catTone => 'Tono';

  @override
  String get catVibration => 'Vibración';

  @override
  String get catDefault => 'Predeterminada';

  @override
  String get catShowPreview => 'Mostrar vista previa';

  @override
  String get catNotifyReactions => 'Notificar reacciones';

  @override
  String get catManageStorage => 'Administrar almacenamiento';

  @override
  String get catAutoDownload => 'Descarga automática';

  @override
  String get catOnMobile => 'Con datos móviles';

  @override
  String get catPhotos => 'Fotos';

  @override
  String get catOnWifi => 'Con Wi-Fi';

  @override
  String get catAll => 'Todo';

  @override
  String get catNetworkUsage => 'Uso de la red';

  @override
  String get catViewNetwork => 'Ver uso de red';

  @override
  String get catLessData => 'Usar menos datos en llamadas';

  @override
  String get catHelpCenter => 'Centro de ayuda';

  @override
  String get catContactUs => 'Contáctanos';

  @override
  String get catTermsPrivacy => 'Términos y Política de privacidad';

  @override
  String get catAppInfo => 'Información de la app';
}
