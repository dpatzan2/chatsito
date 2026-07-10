// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class SFr extends S {
  SFr([String locale = 'fr']) : super(locale);

  @override
  String get welcomeTagline =>
      'Messagerie privée pour ton équipe. Discussions, groupes, salons vocaux et bien plus.';

  @override
  String get welcomeCta => 'Continuer avec ton numéro';

  @override
  String get legalPrefix => 'En continuant, tu acceptes les ';

  @override
  String get legalTerms => 'Conditions';

  @override
  String get legalAnd => ' et la ';

  @override
  String get legalPrivacy => 'Politique de confidentialité';

  @override
  String get legalSuffix => ' de Chatsito.';

  @override
  String get phoneTitle => 'Ton numéro de téléphone';

  @override
  String get phoneSubtitle =>
      'Nous t\'enverrons un SMS avec un code à 6 chiffres pour vérifier ton compte.';

  @override
  String get phoneCarrierFee => 'Des frais opérateur peuvent s\'appliquer.';

  @override
  String get phoneCta => 'Envoyer le code';

  @override
  String get searchCountry => 'Rechercher un pays';

  @override
  String get otpTitle => 'Vérifie ton numéro';

  @override
  String get otpSentTo => 'Saisis le code envoyé au ';

  @override
  String get otpNotReceived => 'Rien reçu ?';

  @override
  String otpResendIn(Object time) {
    return 'Renvoyer dans $time';
  }

  @override
  String get profileTitle => 'Configure ton profil';

  @override
  String get profileSubtitle =>
      'Ajoute ton nom et une photo. Tu pourras les changer quand tu veux.';

  @override
  String get profileNameLabel => 'Ton nom';

  @override
  String get profileNameHint => 'Ex. Marta García';

  @override
  String get profileCta => 'Commencer à discuter';

  @override
  String get chatsTitle => 'Discussions';

  @override
  String get searchHint => 'Rechercher';

  @override
  String get newChat => 'Nouvelle discussion';

  @override
  String get newCommunity => 'Nouvelle communauté';

  @override
  String get joinWithCode => 'Rejoindre avec un code';

  @override
  String get newChatHint => 'Téléphone (chiffres uniquement)';

  @override
  String get newChatAction => 'Ouvrir la discussion';

  @override
  String get newChatError => 'Aucun utilisateur avec ce numéro';

  @override
  String get joinTitle => 'Rejoindre une communauté';

  @override
  String get joinHint => 'Code d\'invitation';

  @override
  String get joinAction => 'Rejoindre';

  @override
  String get joinError => 'Code invalide ou expiré';

  @override
  String get newTextChannel => 'Nouveau salon textuel';

  @override
  String get newVoiceChannel => 'Nouveau salon vocal';

  @override
  String get channelNameHint => 'Nom du salon';

  @override
  String get createChannelAction => 'Créer';

  @override
  String get channelCreateError => 'Impossible de créer le salon';

  @override
  String get cancel => 'Annuler';

  @override
  String get navChats => 'Discussions';

  @override
  String get navGroups => 'Groupes';

  @override
  String get navCalls => 'Appels';

  @override
  String get navSettings => 'Réglages';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get typing => 'écrit…';

  @override
  String get messageHint => 'Message';

  @override
  String get attachCamera => 'Caméra';

  @override
  String get attachGallery => 'Galerie';

  @override
  String get attachVideo => 'Vidéo';

  @override
  String get attachDocument => 'Document';

  @override
  String get attachAudio => 'Audio';

  @override
  String get attachLocation => 'Position';

  @override
  String get attachContact => 'Contact';

  @override
  String get attachPoll => 'Sondage';

  @override
  String get newGroupTitle => 'Nouveau groupe';

  @override
  String participantsSelected(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n participants sélectionnés',
      one: '1 participant sélectionné',
    );
    return '$_temp0';
  }

  @override
  String get groupNameHint => 'Nom du groupe';

  @override
  String get addParticipants => 'Ajouter des participants';

  @override
  String get createGroupCta => 'Créer le groupe';

  @override
  String get communityFallback => 'Communauté';

  @override
  String membersCount(Object n) {
    return '$n membres';
  }

  @override
  String get textChannels => 'Salons textuels';

  @override
  String get voiceChannels => 'Salons vocaux';

  @override
  String get voiceEmpty => 'Vide';

  @override
  String voiceConnected(Object n) {
    return '$n connectés';
  }

  @override
  String get connecting => 'Connexion…';

  @override
  String voiceChannelSubtitle(Object name) {
    return 'Salon vocal · $name';
  }

  @override
  String get rolesTitle => 'Rôles';

  @override
  String get newRole => 'Nouveau rôle';

  @override
  String get roleNameLabel => 'Nom';

  @override
  String get roleNameHint => 'Nom du rôle';

  @override
  String get roleColor => 'Couleur';

  @override
  String get rolePermissions => 'Permissions';

  @override
  String get roleMembers => 'Membres';

  @override
  String get createRoleCta => 'Créer le rôle';

  @override
  String get saveRole => 'Enregistrer';

  @override
  String get permViewChannel => 'Voir les salons';

  @override
  String get permSendMessages => 'Envoyer des messages';

  @override
  String get permManageMessages => 'Gérer les messages';

  @override
  String get permManageChannels => 'Gérer les salons';

  @override
  String get permManageRoles => 'Gérer les rôles';

  @override
  String get permKickMembers => 'Expulser des membres';

  @override
  String get permManageInvites => 'Créer des invitations';

  @override
  String get permVoiceConnect => 'Se connecter en vocal';

  @override
  String get permVoiceSpeak => 'Parler en vocal';

  @override
  String get permVoiceMuteMembers => 'Rendre muets les autres';

  @override
  String get permAdmin => 'Administrateur';

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get availableVerified => 'Disponible · ✓ vérifié';

  @override
  String get setAccount => 'Compte';

  @override
  String get setPrivacy => 'Confidentialité';

  @override
  String get setChats => 'Discussions';

  @override
  String get setNotifications => 'Notifications';

  @override
  String get setStorage => 'Stockage et données';

  @override
  String get setHelp => 'Aide';

  @override
  String get setInvite => 'Inviter un ami';

  @override
  String get inviteCommunityTitle => 'Inviter dans la communauté';

  @override
  String get inviteFriendTitle => 'Inviter un ami';

  @override
  String get inviteCommunityHeading => 'Invite des gens dans la communauté';

  @override
  String get inviteFriendHeading => 'Invite ton équipe sur Chatsito';

  @override
  String get inviteCommunityCopy =>
      'Partage ce code : dans Chatsito, « Rejoindre avec un code ». Expire dans 7 jours.';

  @override
  String get inviteFriendCopy =>
      'Partage ton lien personnel. Dès qu\'ils rejoignent, tu les verras dans tes discussions.';

  @override
  String get copyAction => 'Copier';

  @override
  String get shareMessage => 'Message';

  @override
  String get shareEmail => 'E-mail';

  @override
  String get shareMore => 'Plus';

  @override
  String get done => 'Terminé';

  @override
  String get shareLink => 'Partager le lien';

  @override
  String get actionAudio => 'Audio';

  @override
  String get actionVideo => 'Vidéo';

  @override
  String get actionSearch => 'Rechercher';

  @override
  String get actionMute => 'Muet';

  @override
  String get aboutHeader => 'À propos';

  @override
  String get aboutSample =>
      'Disponible ✨ Je conçois de jolies choses dans l\'équipe produit.';

  @override
  String get mediaFiles => 'Médias et fichiers';

  @override
  String get seeAll => 'Tout voir ›';

  @override
  String get muteNotifications => 'Couper les notifications';

  @override
  String get tempMessages => 'Messages éphémères';

  @override
  String get disabled => 'Désactivé';

  @override
  String get encryption => 'Chiffrement';

  @override
  String get verified => 'Vérifié';

  @override
  String blockContact(Object name) {
    return 'Bloquer $name';
  }

  @override
  String get reportContact => 'Signaler le contact';

  @override
  String get e2eNotice => 'Tes messages sont chiffrés de bout en bout.';

  @override
  String get catInfo => 'Informations';

  @override
  String get catPhoneNumber => 'Numéro de téléphone';

  @override
  String get catChangeNumber => 'Changer de numéro';

  @override
  String get catEmail => 'E-mail';

  @override
  String get catAdd => 'Ajouter';

  @override
  String get catRequestInfo => 'Demander les infos de mon compte';

  @override
  String get catDeleteAccount => 'Supprimer mon compte';

  @override
  String get catWhoCanSee => 'Qui peut voir mes infos';

  @override
  String get catLastSeen => 'Vu pour la dernière fois et en ligne';

  @override
  String get catEveryone => 'Tout le monde';

  @override
  String get catProfilePhoto => 'Photo de profil';

  @override
  String get catMyContacts => 'Mes contacts';

  @override
  String get catStatus => 'Statut';

  @override
  String get catReadReceipts => 'Confirmations de lecture';

  @override
  String get catBlocked => 'Contacts bloqués';

  @override
  String get catScreenLock => 'Verrouillage par code';

  @override
  String get catDisplay => 'Affichage';

  @override
  String get catTheme => 'Thème';

  @override
  String get catLight => 'Clair';

  @override
  String get catWallpaper => 'Fond d\'écran';

  @override
  String get catFontSize => 'Taille de police';

  @override
  String get catMedium => 'Moyenne';

  @override
  String get catEnterToSend => 'Touche Entrée pour envoyer';

  @override
  String get catSaveToRoll => 'Enregistrer dans la pellicule';

  @override
  String get catBackup => 'Sauvegarde';

  @override
  String get catChatHistory => 'Historique des discussions';

  @override
  String get catMessages => 'Messages';

  @override
  String get catShowNotifications => 'Afficher les notifications';

  @override
  String get catTone => 'Sonnerie';

  @override
  String get catVibration => 'Vibration';

  @override
  String get catDefault => 'Par défaut';

  @override
  String get catShowPreview => 'Afficher l\'aperçu';

  @override
  String get catNotifyReactions => 'Notifier les réactions';

  @override
  String get catManageStorage => 'Gérer le stockage';

  @override
  String get catAutoDownload => 'Téléchargement automatique';

  @override
  String get catOnMobile => 'En données mobiles';

  @override
  String get catPhotos => 'Photos';

  @override
  String get catOnWifi => 'En Wi-Fi';

  @override
  String get catAll => 'Tout';

  @override
  String get catNetworkUsage => 'Utilisation du réseau';

  @override
  String get catViewNetwork => 'Voir l\'utilisation du réseau';

  @override
  String get catLessData => 'Moins de données pour les appels';

  @override
  String get catHelpCenter => 'Centre d\'aide';

  @override
  String get catContactUs => 'Nous contacter';

  @override
  String get catTermsPrivacy => 'Conditions et Politique de confidentialité';

  @override
  String get catAppInfo => 'Infos de l\'appli';
}
