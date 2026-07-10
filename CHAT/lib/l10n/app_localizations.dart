import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S)!;
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('pt'),
  ];

  /// No description provided for @welcomeTagline.
  ///
  /// In es, this message translates to:
  /// **'Mensajería privada para tu equipo. Chats, grupos, canales de voz y mucho más.'**
  String get welcomeTagline;

  /// No description provided for @welcomeCta.
  ///
  /// In es, this message translates to:
  /// **'Continuar con tu número'**
  String get welcomeCta;

  /// No description provided for @legalPrefix.
  ///
  /// In es, this message translates to:
  /// **'Al continuar aceptas los '**
  String get legalPrefix;

  /// No description provided for @legalTerms.
  ///
  /// In es, this message translates to:
  /// **'Términos'**
  String get legalTerms;

  /// No description provided for @legalAnd.
  ///
  /// In es, this message translates to:
  /// **' y la '**
  String get legalAnd;

  /// No description provided for @legalPrivacy.
  ///
  /// In es, this message translates to:
  /// **'Política de privacidad'**
  String get legalPrivacy;

  /// No description provided for @legalSuffix.
  ///
  /// In es, this message translates to:
  /// **' de Chatsito.'**
  String get legalSuffix;

  /// No description provided for @phoneTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu número de teléfono'**
  String get phoneTitle;

  /// No description provided for @phoneSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Te enviaremos un SMS con un código de 6 dígitos para verificar tu cuenta.'**
  String get phoneSubtitle;

  /// No description provided for @phoneCarrierFee.
  ///
  /// In es, this message translates to:
  /// **'Puede que se apliquen tarifas de tu operador.'**
  String get phoneCarrierFee;

  /// No description provided for @phoneCta.
  ///
  /// In es, this message translates to:
  /// **'Enviar código'**
  String get phoneCta;

  /// No description provided for @searchCountry.
  ///
  /// In es, this message translates to:
  /// **'Buscar país'**
  String get searchCountry;

  /// No description provided for @otpTitle.
  ///
  /// In es, this message translates to:
  /// **'Verifica tu número'**
  String get otpTitle;

  /// No description provided for @otpSentTo.
  ///
  /// In es, this message translates to:
  /// **'Introduce el código enviado al '**
  String get otpSentTo;

  /// No description provided for @otpNotReceived.
  ///
  /// In es, this message translates to:
  /// **'¿No llegó?'**
  String get otpNotReceived;

  /// No description provided for @otpResendIn.
  ///
  /// In es, this message translates to:
  /// **'Reenviar en {time}'**
  String otpResendIn(Object time);

  /// No description provided for @profileTitle.
  ///
  /// In es, this message translates to:
  /// **'Configura tu perfil'**
  String get profileTitle;

  /// No description provided for @profileSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Pon tu nombre y una foto. Podrás cambiarlos cuando quieras.'**
  String get profileSubtitle;

  /// No description provided for @profileNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Tu nombre'**
  String get profileNameLabel;

  /// No description provided for @profileNameHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Marta García'**
  String get profileNameHint;

  /// No description provided for @profileCta.
  ///
  /// In es, this message translates to:
  /// **'Empezar a chatear'**
  String get profileCta;

  /// No description provided for @chatsTitle.
  ///
  /// In es, this message translates to:
  /// **'Chats'**
  String get chatsTitle;

  /// No description provided for @searchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar'**
  String get searchHint;

  /// No description provided for @newChat.
  ///
  /// In es, this message translates to:
  /// **'Nuevo chat'**
  String get newChat;

  /// No description provided for @newCommunity.
  ///
  /// In es, this message translates to:
  /// **'Nueva comunidad'**
  String get newCommunity;

  /// No description provided for @joinWithCode.
  ///
  /// In es, this message translates to:
  /// **'Unirme con código'**
  String get joinWithCode;

  /// No description provided for @newChatHint.
  ///
  /// In es, this message translates to:
  /// **'Teléfono (solo dígitos)'**
  String get newChatHint;

  /// No description provided for @newChatAction.
  ///
  /// In es, this message translates to:
  /// **'Abrir chat'**
  String get newChatAction;

  /// No description provided for @newChatError.
  ///
  /// In es, this message translates to:
  /// **'No hay ningún usuario con ese número'**
  String get newChatError;

  /// No description provided for @joinTitle.
  ///
  /// In es, this message translates to:
  /// **'Unirme a una comunidad'**
  String get joinTitle;

  /// No description provided for @joinHint.
  ///
  /// In es, this message translates to:
  /// **'Código de invitación'**
  String get joinHint;

  /// No description provided for @joinAction.
  ///
  /// In es, this message translates to:
  /// **'Unirme'**
  String get joinAction;

  /// No description provided for @joinError.
  ///
  /// In es, this message translates to:
  /// **'Código inválido o caducado'**
  String get joinError;

  /// No description provided for @newTextChannel.
  ///
  /// In es, this message translates to:
  /// **'Nuevo canal de texto'**
  String get newTextChannel;

  /// No description provided for @newVoiceChannel.
  ///
  /// In es, this message translates to:
  /// **'Nuevo canal de voz'**
  String get newVoiceChannel;

  /// No description provided for @channelNameHint.
  ///
  /// In es, this message translates to:
  /// **'Nombre del canal'**
  String get channelNameHint;

  /// No description provided for @createChannelAction.
  ///
  /// In es, this message translates to:
  /// **'Crear'**
  String get createChannelAction;

  /// No description provided for @channelCreateError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo crear el canal'**
  String get channelCreateError;

  /// No description provided for @membersOnline.
  ///
  /// In es, this message translates to:
  /// **'En línea'**
  String get membersOnline;

  /// No description provided for @membersOffline.
  ///
  /// In es, this message translates to:
  /// **'Desconectados'**
  String get membersOffline;

  /// No description provided for @leaveCommunity.
  ///
  /// In es, this message translates to:
  /// **'Salir de la comunidad'**
  String get leaveCommunity;

  /// No description provided for @leaveCommunityConfirm.
  ///
  /// In es, this message translates to:
  /// **'Dejarás de ver sus canales y mensajes.'**
  String get leaveCommunityConfirm;

  /// No description provided for @leaveAction.
  ///
  /// In es, this message translates to:
  /// **'Salir'**
  String get leaveAction;

  /// No description provided for @editProfileTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar perfil'**
  String get editProfileTitle;

  /// No description provided for @changePhoto.
  ///
  /// In es, this message translates to:
  /// **'Cambiar foto'**
  String get changePhoto;

  /// No description provided for @saveAction.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get saveAction;

  /// No description provided for @logoutAction.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get logoutAction;

  /// No description provided for @logoutConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Cerrar sesión en este dispositivo?'**
  String get logoutConfirm;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In es, this message translates to:
  /// **'Se borrarán tu cuenta, tus mensajes y tus membresías. Esto no se puede deshacer.'**
  String get deleteAccountWarning;

  /// No description provided for @deleteAction.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get deleteAction;

  /// No description provided for @uploadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo subir el archivo'**
  String get uploadError;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @navChats.
  ///
  /// In es, this message translates to:
  /// **'Chats'**
  String get navChats;

  /// No description provided for @navGroups.
  ///
  /// In es, this message translates to:
  /// **'Grupos'**
  String get navGroups;

  /// No description provided for @navCalls.
  ///
  /// In es, this message translates to:
  /// **'Llamadas'**
  String get navCalls;

  /// No description provided for @navSettings.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get navSettings;

  /// No description provided for @today.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get today;

  /// No description provided for @typing.
  ///
  /// In es, this message translates to:
  /// **'escribiendo…'**
  String get typing;

  /// No description provided for @messageHint.
  ///
  /// In es, this message translates to:
  /// **'Mensaje'**
  String get messageHint;

  /// No description provided for @attachCamera.
  ///
  /// In es, this message translates to:
  /// **'Cámara'**
  String get attachCamera;

  /// No description provided for @attachGallery.
  ///
  /// In es, this message translates to:
  /// **'Galería'**
  String get attachGallery;

  /// No description provided for @attachVideo.
  ///
  /// In es, this message translates to:
  /// **'Vídeo'**
  String get attachVideo;

  /// No description provided for @attachDocument.
  ///
  /// In es, this message translates to:
  /// **'Documento'**
  String get attachDocument;

  /// No description provided for @attachAudio.
  ///
  /// In es, this message translates to:
  /// **'Audio'**
  String get attachAudio;

  /// No description provided for @attachLocation.
  ///
  /// In es, this message translates to:
  /// **'Ubicación'**
  String get attachLocation;

  /// No description provided for @attachContact.
  ///
  /// In es, this message translates to:
  /// **'Contacto'**
  String get attachContact;

  /// No description provided for @attachPoll.
  ///
  /// In es, this message translates to:
  /// **'Encuesta'**
  String get attachPoll;

  /// No description provided for @newGroupTitle.
  ///
  /// In es, this message translates to:
  /// **'Nuevo grupo'**
  String get newGroupTitle;

  /// No description provided for @participantsSelected.
  ///
  /// In es, this message translates to:
  /// **'{n, plural, =1{1 participante seleccionado} other{{n} participantes seleccionados}}'**
  String participantsSelected(num n);

  /// No description provided for @groupNameHint.
  ///
  /// In es, this message translates to:
  /// **'Nombre del grupo'**
  String get groupNameHint;

  /// No description provided for @addParticipants.
  ///
  /// In es, this message translates to:
  /// **'Añadir participantes'**
  String get addParticipants;

  /// No description provided for @createGroupCta.
  ///
  /// In es, this message translates to:
  /// **'Crear grupo'**
  String get createGroupCta;

  /// No description provided for @communityFallback.
  ///
  /// In es, this message translates to:
  /// **'Comunidad'**
  String get communityFallback;

  /// No description provided for @membersCount.
  ///
  /// In es, this message translates to:
  /// **'{n} miembros'**
  String membersCount(Object n);

  /// No description provided for @textChannels.
  ///
  /// In es, this message translates to:
  /// **'Canales de texto'**
  String get textChannels;

  /// No description provided for @voiceChannels.
  ///
  /// In es, this message translates to:
  /// **'Canales de voz'**
  String get voiceChannels;

  /// No description provided for @voiceEmpty.
  ///
  /// In es, this message translates to:
  /// **'Vacío'**
  String get voiceEmpty;

  /// No description provided for @voiceConnected.
  ///
  /// In es, this message translates to:
  /// **'{n} conectados'**
  String voiceConnected(Object n);

  /// No description provided for @connecting.
  ///
  /// In es, this message translates to:
  /// **'Conectando…'**
  String get connecting;

  /// No description provided for @voiceChannelSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Canal de voz · {name}'**
  String voiceChannelSubtitle(Object name);

  /// No description provided for @rolesTitle.
  ///
  /// In es, this message translates to:
  /// **'Roles'**
  String get rolesTitle;

  /// No description provided for @newRole.
  ///
  /// In es, this message translates to:
  /// **'Nuevo rol'**
  String get newRole;

  /// No description provided for @roleNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get roleNameLabel;

  /// No description provided for @roleNameHint.
  ///
  /// In es, this message translates to:
  /// **'Nombre del rol'**
  String get roleNameHint;

  /// No description provided for @roleColor.
  ///
  /// In es, this message translates to:
  /// **'Color'**
  String get roleColor;

  /// No description provided for @rolePermissions.
  ///
  /// In es, this message translates to:
  /// **'Permisos'**
  String get rolePermissions;

  /// No description provided for @roleMembers.
  ///
  /// In es, this message translates to:
  /// **'Miembros'**
  String get roleMembers;

  /// No description provided for @createRoleCta.
  ///
  /// In es, this message translates to:
  /// **'Crear rol'**
  String get createRoleCta;

  /// No description provided for @saveRole.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get saveRole;

  /// No description provided for @permViewChannel.
  ///
  /// In es, this message translates to:
  /// **'Ver canales'**
  String get permViewChannel;

  /// No description provided for @permSendMessages.
  ///
  /// In es, this message translates to:
  /// **'Enviar mensajes'**
  String get permSendMessages;

  /// No description provided for @permManageMessages.
  ///
  /// In es, this message translates to:
  /// **'Gestionar mensajes'**
  String get permManageMessages;

  /// No description provided for @permManageChannels.
  ///
  /// In es, this message translates to:
  /// **'Gestionar canales'**
  String get permManageChannels;

  /// No description provided for @permManageRoles.
  ///
  /// In es, this message translates to:
  /// **'Gestionar roles'**
  String get permManageRoles;

  /// No description provided for @permKickMembers.
  ///
  /// In es, this message translates to:
  /// **'Expulsar miembros'**
  String get permKickMembers;

  /// No description provided for @permManageInvites.
  ///
  /// In es, this message translates to:
  /// **'Crear invitaciones'**
  String get permManageInvites;

  /// No description provided for @permVoiceConnect.
  ///
  /// In es, this message translates to:
  /// **'Conectarse a voz'**
  String get permVoiceConnect;

  /// No description provided for @permVoiceSpeak.
  ///
  /// In es, this message translates to:
  /// **'Hablar en voz'**
  String get permVoiceSpeak;

  /// No description provided for @permVoiceMuteMembers.
  ///
  /// In es, this message translates to:
  /// **'Silenciar a otros'**
  String get permVoiceMuteMembers;

  /// No description provided for @permAdmin.
  ///
  /// In es, this message translates to:
  /// **'Administrador'**
  String get permAdmin;

  /// No description provided for @settingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get settingsTitle;

  /// No description provided for @availableVerified.
  ///
  /// In es, this message translates to:
  /// **'Disponible · ✓ verificado'**
  String get availableVerified;

  /// No description provided for @setAccount.
  ///
  /// In es, this message translates to:
  /// **'Cuenta'**
  String get setAccount;

  /// No description provided for @setPrivacy.
  ///
  /// In es, this message translates to:
  /// **'Privacidad'**
  String get setPrivacy;

  /// No description provided for @setChats.
  ///
  /// In es, this message translates to:
  /// **'Chats'**
  String get setChats;

  /// No description provided for @setNotifications.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get setNotifications;

  /// No description provided for @setStorage.
  ///
  /// In es, this message translates to:
  /// **'Almacenamiento y datos'**
  String get setStorage;

  /// No description provided for @setHelp.
  ///
  /// In es, this message translates to:
  /// **'Ayuda'**
  String get setHelp;

  /// No description provided for @setInvite.
  ///
  /// In es, this message translates to:
  /// **'Invitar a un amigo'**
  String get setInvite;

  /// No description provided for @inviteCommunityTitle.
  ///
  /// In es, this message translates to:
  /// **'Invitar a la comunidad'**
  String get inviteCommunityTitle;

  /// No description provided for @inviteFriendTitle.
  ///
  /// In es, this message translates to:
  /// **'Invitar a un amigo'**
  String get inviteFriendTitle;

  /// No description provided for @inviteCommunityHeading.
  ///
  /// In es, this message translates to:
  /// **'Invita gente a la comunidad'**
  String get inviteCommunityHeading;

  /// No description provided for @inviteFriendHeading.
  ///
  /// In es, this message translates to:
  /// **'Invita a tu equipo a Chatsito'**
  String get inviteFriendHeading;

  /// No description provided for @inviteCommunityCopy.
  ///
  /// In es, this message translates to:
  /// **'Comparte este código: en Chatsito, \"Unirme con código\". Caduca en 7 días.'**
  String get inviteCommunityCopy;

  /// No description provided for @inviteFriendCopy.
  ///
  /// In es, this message translates to:
  /// **'Comparte tu enlace personal. Cuando se unan, los verás en tus chats al instante.'**
  String get inviteFriendCopy;

  /// No description provided for @copyAction.
  ///
  /// In es, this message translates to:
  /// **'Copiar'**
  String get copyAction;

  /// No description provided for @shareMessage.
  ///
  /// In es, this message translates to:
  /// **'Mensaje'**
  String get shareMessage;

  /// No description provided for @shareEmail.
  ///
  /// In es, this message translates to:
  /// **'Correo'**
  String get shareEmail;

  /// No description provided for @shareMore.
  ///
  /// In es, this message translates to:
  /// **'Más'**
  String get shareMore;

  /// No description provided for @done.
  ///
  /// In es, this message translates to:
  /// **'Listo'**
  String get done;

  /// No description provided for @shareLink.
  ///
  /// In es, this message translates to:
  /// **'Compartir enlace'**
  String get shareLink;

  /// No description provided for @actionAudio.
  ///
  /// In es, this message translates to:
  /// **'Audio'**
  String get actionAudio;

  /// No description provided for @actionVideo.
  ///
  /// In es, this message translates to:
  /// **'Vídeo'**
  String get actionVideo;

  /// No description provided for @actionSearch.
  ///
  /// In es, this message translates to:
  /// **'Buscar'**
  String get actionSearch;

  /// No description provided for @actionMute.
  ///
  /// In es, this message translates to:
  /// **'Silenciar'**
  String get actionMute;

  /// No description provided for @aboutHeader.
  ///
  /// In es, this message translates to:
  /// **'Acerca de'**
  String get aboutHeader;

  /// No description provided for @aboutSample.
  ///
  /// In es, this message translates to:
  /// **'Disponible ✨ Diseñando cosas bonitas en el equipo de producto.'**
  String get aboutSample;

  /// No description provided for @mediaFiles.
  ///
  /// In es, this message translates to:
  /// **'Multimedia y archivos'**
  String get mediaFiles;

  /// No description provided for @seeAll.
  ///
  /// In es, this message translates to:
  /// **'Ver todo ›'**
  String get seeAll;

  /// No description provided for @muteNotifications.
  ///
  /// In es, this message translates to:
  /// **'Silenciar notificaciones'**
  String get muteNotifications;

  /// No description provided for @tempMessages.
  ///
  /// In es, this message translates to:
  /// **'Mensajes temporales'**
  String get tempMessages;

  /// No description provided for @disabled.
  ///
  /// In es, this message translates to:
  /// **'Desactivado'**
  String get disabled;

  /// No description provided for @encryption.
  ///
  /// In es, this message translates to:
  /// **'Cifrado'**
  String get encryption;

  /// No description provided for @verified.
  ///
  /// In es, this message translates to:
  /// **'Verificado'**
  String get verified;

  /// No description provided for @blockContact.
  ///
  /// In es, this message translates to:
  /// **'Bloquear a {name}'**
  String blockContact(Object name);

  /// No description provided for @reportContact.
  ///
  /// In es, this message translates to:
  /// **'Reportar contacto'**
  String get reportContact;

  /// No description provided for @e2eNotice.
  ///
  /// In es, this message translates to:
  /// **'Tus mensajes están cifrados de extremo a extremo.'**
  String get e2eNotice;

  /// No description provided for @catInfo.
  ///
  /// In es, this message translates to:
  /// **'Información'**
  String get catInfo;

  /// No description provided for @catPhoneNumber.
  ///
  /// In es, this message translates to:
  /// **'Número de teléfono'**
  String get catPhoneNumber;

  /// No description provided for @catChangeNumber.
  ///
  /// In es, this message translates to:
  /// **'Cambiar número'**
  String get catChangeNumber;

  /// No description provided for @catEmail.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get catEmail;

  /// No description provided for @catAdd.
  ///
  /// In es, this message translates to:
  /// **'Añadir'**
  String get catAdd;

  /// No description provided for @catRequestInfo.
  ///
  /// In es, this message translates to:
  /// **'Solicitar información de mi cuenta'**
  String get catRequestInfo;

  /// No description provided for @catDeleteAccount.
  ///
  /// In es, this message translates to:
  /// **'Eliminar mi cuenta'**
  String get catDeleteAccount;

  /// No description provided for @catWhoCanSee.
  ///
  /// In es, this message translates to:
  /// **'Quién puede ver mi info'**
  String get catWhoCanSee;

  /// No description provided for @catLastSeen.
  ///
  /// In es, this message translates to:
  /// **'Última vez y en línea'**
  String get catLastSeen;

  /// No description provided for @catEveryone.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get catEveryone;

  /// No description provided for @catProfilePhoto.
  ///
  /// In es, this message translates to:
  /// **'Foto de perfil'**
  String get catProfilePhoto;

  /// No description provided for @catMyContacts.
  ///
  /// In es, this message translates to:
  /// **'Mis contactos'**
  String get catMyContacts;

  /// No description provided for @catStatus.
  ///
  /// In es, this message translates to:
  /// **'Estado'**
  String get catStatus;

  /// No description provided for @catReadReceipts.
  ///
  /// In es, this message translates to:
  /// **'Confirmaciones de lectura'**
  String get catReadReceipts;

  /// No description provided for @catBlocked.
  ///
  /// In es, this message translates to:
  /// **'Contactos bloqueados'**
  String get catBlocked;

  /// No description provided for @catScreenLock.
  ///
  /// In es, this message translates to:
  /// **'Bloqueo con código'**
  String get catScreenLock;

  /// No description provided for @catDisplay.
  ///
  /// In es, this message translates to:
  /// **'Pantalla'**
  String get catDisplay;

  /// No description provided for @catTheme.
  ///
  /// In es, this message translates to:
  /// **'Tema'**
  String get catTheme;

  /// No description provided for @catLight.
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get catLight;

  /// No description provided for @catWallpaper.
  ///
  /// In es, this message translates to:
  /// **'Fondo de pantalla'**
  String get catWallpaper;

  /// No description provided for @catFontSize.
  ///
  /// In es, this message translates to:
  /// **'Tamaño de fuente'**
  String get catFontSize;

  /// No description provided for @catMedium.
  ///
  /// In es, this message translates to:
  /// **'Mediano'**
  String get catMedium;

  /// No description provided for @catEnterToSend.
  ///
  /// In es, this message translates to:
  /// **'Tecla Enter para enviar'**
  String get catEnterToSend;

  /// No description provided for @catSaveToRoll.
  ///
  /// In es, this message translates to:
  /// **'Guardar en el carrete'**
  String get catSaveToRoll;

  /// No description provided for @catBackup.
  ///
  /// In es, this message translates to:
  /// **'Copia de seguridad'**
  String get catBackup;

  /// No description provided for @catChatHistory.
  ///
  /// In es, this message translates to:
  /// **'Historial de chats'**
  String get catChatHistory;

  /// No description provided for @catMessages.
  ///
  /// In es, this message translates to:
  /// **'Mensajes'**
  String get catMessages;

  /// No description provided for @catShowNotifications.
  ///
  /// In es, this message translates to:
  /// **'Mostrar notificaciones'**
  String get catShowNotifications;

  /// No description provided for @catTone.
  ///
  /// In es, this message translates to:
  /// **'Tono'**
  String get catTone;

  /// No description provided for @catVibration.
  ///
  /// In es, this message translates to:
  /// **'Vibración'**
  String get catVibration;

  /// No description provided for @catDefault.
  ///
  /// In es, this message translates to:
  /// **'Predeterminada'**
  String get catDefault;

  /// No description provided for @catShowPreview.
  ///
  /// In es, this message translates to:
  /// **'Mostrar vista previa'**
  String get catShowPreview;

  /// No description provided for @catNotifyReactions.
  ///
  /// In es, this message translates to:
  /// **'Notificar reacciones'**
  String get catNotifyReactions;

  /// No description provided for @catManageStorage.
  ///
  /// In es, this message translates to:
  /// **'Administrar almacenamiento'**
  String get catManageStorage;

  /// No description provided for @catAutoDownload.
  ///
  /// In es, this message translates to:
  /// **'Descarga automática'**
  String get catAutoDownload;

  /// No description provided for @catOnMobile.
  ///
  /// In es, this message translates to:
  /// **'Con datos móviles'**
  String get catOnMobile;

  /// No description provided for @catPhotos.
  ///
  /// In es, this message translates to:
  /// **'Fotos'**
  String get catPhotos;

  /// No description provided for @catOnWifi.
  ///
  /// In es, this message translates to:
  /// **'Con Wi-Fi'**
  String get catOnWifi;

  /// No description provided for @catAll.
  ///
  /// In es, this message translates to:
  /// **'Todo'**
  String get catAll;

  /// No description provided for @catNetworkUsage.
  ///
  /// In es, this message translates to:
  /// **'Uso de la red'**
  String get catNetworkUsage;

  /// No description provided for @catViewNetwork.
  ///
  /// In es, this message translates to:
  /// **'Ver uso de red'**
  String get catViewNetwork;

  /// No description provided for @catLessData.
  ///
  /// In es, this message translates to:
  /// **'Usar menos datos en llamadas'**
  String get catLessData;

  /// No description provided for @catHelpCenter.
  ///
  /// In es, this message translates to:
  /// **'Centro de ayuda'**
  String get catHelpCenter;

  /// No description provided for @catContactUs.
  ///
  /// In es, this message translates to:
  /// **'Contáctanos'**
  String get catContactUs;

  /// No description provided for @catTermsPrivacy.
  ///
  /// In es, this message translates to:
  /// **'Términos y Política de privacidad'**
  String get catTermsPrivacy;

  /// No description provided for @catAppInfo.
  ///
  /// In es, this message translates to:
  /// **'Información de la app'**
  String get catAppInfo;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'fr', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return SEn();
    case 'es':
      return SEs();
    case 'fr':
      return SFr();
    case 'pt':
      return SPt();
  }

  throw FlutterError(
    'S.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
