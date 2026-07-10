// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get welcomeTagline =>
      'Private messaging for your team. Chats, groups, voice channels and much more.';

  @override
  String get welcomeCta => 'Continue with your number';

  @override
  String get legalPrefix => 'By continuing you accept Chatsito\'s ';

  @override
  String get legalTerms => 'Terms';

  @override
  String get legalAnd => ' and ';

  @override
  String get legalPrivacy => 'Privacy Policy';

  @override
  String get legalSuffix => '.';

  @override
  String get phoneTitle => 'Your phone number';

  @override
  String get phoneSubtitle =>
      'We\'ll send you an SMS with a 6-digit code to verify your account.';

  @override
  String get phoneCarrierFee => 'Carrier fees may apply.';

  @override
  String get phoneCta => 'Send code';

  @override
  String get searchCountry => 'Search country';

  @override
  String get otpTitle => 'Verify your number';

  @override
  String get otpSentTo => 'Enter the code sent to ';

  @override
  String get otpNotReceived => 'Didn\'t get it?';

  @override
  String otpResendIn(Object time) {
    return 'Resend in $time';
  }

  @override
  String get profileTitle => 'Set up your profile';

  @override
  String get profileSubtitle =>
      'Add your name and a photo. You can change them anytime.';

  @override
  String get profileNameLabel => 'Your name';

  @override
  String get profileNameHint => 'E.g. Marta García';

  @override
  String get profileCta => 'Start chatting';

  @override
  String get chatsTitle => 'Chats';

  @override
  String get searchHint => 'Search';

  @override
  String get newChat => 'New chat';

  @override
  String get newCommunity => 'New community';

  @override
  String get joinWithCode => 'Join with a code';

  @override
  String get newChatHint => 'Phone (digits only)';

  @override
  String get newChatAction => 'Open chat';

  @override
  String get newChatError => 'No user with that number';

  @override
  String get joinTitle => 'Join a community';

  @override
  String get joinHint => 'Invite code';

  @override
  String get joinAction => 'Join';

  @override
  String get joinError => 'Invalid or expired code';

  @override
  String get newTextChannel => 'New text channel';

  @override
  String get newVoiceChannel => 'New voice channel';

  @override
  String get channelNameHint => 'Channel name';

  @override
  String get createChannelAction => 'Create';

  @override
  String get channelCreateError => 'Couldn\'t create the channel';

  @override
  String get membersOnline => 'Online';

  @override
  String get membersOffline => 'Offline';

  @override
  String get leaveCommunity => 'Leave community';

  @override
  String get leaveCommunityConfirm =>
      'You\'ll stop seeing its channels and messages.';

  @override
  String get leaveAction => 'Leave';

  @override
  String get editProfileTitle => 'Edit profile';

  @override
  String get changePhoto => 'Change photo';

  @override
  String get saveAction => 'Save';

  @override
  String get logoutAction => 'Log out';

  @override
  String get logoutConfirm => 'Log out on this device?';

  @override
  String get deleteAccountWarning =>
      'Your account, messages and memberships will be deleted. This cannot be undone.';

  @override
  String get deleteAction => 'Delete';

  @override
  String get uploadError => 'Couldn\'t upload the file';

  @override
  String get cancel => 'Cancel';

  @override
  String get navChats => 'Chats';

  @override
  String get navGroups => 'Groups';

  @override
  String get navCalls => 'Calls';

  @override
  String get navSettings => 'Settings';

  @override
  String get today => 'Today';

  @override
  String get typing => 'typing…';

  @override
  String get messageHint => 'Message';

  @override
  String get attachCamera => 'Camera';

  @override
  String get attachGallery => 'Gallery';

  @override
  String get attachVideo => 'Video';

  @override
  String get attachDocument => 'Document';

  @override
  String get attachAudio => 'Audio';

  @override
  String get attachLocation => 'Location';

  @override
  String get attachContact => 'Contact';

  @override
  String get attachPoll => 'Poll';

  @override
  String get newGroupTitle => 'New group';

  @override
  String participantsSelected(num n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n participants selected',
      one: '1 participant selected',
    );
    return '$_temp0';
  }

  @override
  String get groupNameHint => 'Group name';

  @override
  String get addParticipants => 'Add participants';

  @override
  String get createGroupCta => 'Create group';

  @override
  String get communityFallback => 'Community';

  @override
  String membersCount(Object n) {
    return '$n members';
  }

  @override
  String get textChannels => 'Text channels';

  @override
  String get voiceChannels => 'Voice channels';

  @override
  String get voiceEmpty => 'Empty';

  @override
  String voiceConnected(Object n) {
    return '$n connected';
  }

  @override
  String get connecting => 'Connecting…';

  @override
  String voiceChannelSubtitle(Object name) {
    return 'Voice channel · $name';
  }

  @override
  String get rolesTitle => 'Roles';

  @override
  String get newRole => 'New role';

  @override
  String get roleNameLabel => 'Name';

  @override
  String get roleNameHint => 'Role name';

  @override
  String get roleColor => 'Color';

  @override
  String get rolePermissions => 'Permissions';

  @override
  String get roleMembers => 'Members';

  @override
  String get createRoleCta => 'Create role';

  @override
  String get saveRole => 'Save';

  @override
  String get permViewChannel => 'View channels';

  @override
  String get permSendMessages => 'Send messages';

  @override
  String get permManageMessages => 'Manage messages';

  @override
  String get permManageChannels => 'Manage channels';

  @override
  String get permManageRoles => 'Manage roles';

  @override
  String get permKickMembers => 'Kick members';

  @override
  String get permManageInvites => 'Create invites';

  @override
  String get permVoiceConnect => 'Connect to voice';

  @override
  String get permVoiceSpeak => 'Speak in voice';

  @override
  String get permVoiceMuteMembers => 'Mute others';

  @override
  String get permAdmin => 'Administrator';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get availableVerified => 'Available · ✓ verified';

  @override
  String get setAccount => 'Account';

  @override
  String get setPrivacy => 'Privacy';

  @override
  String get setChats => 'Chats';

  @override
  String get setNotifications => 'Notifications';

  @override
  String get setStorage => 'Storage and data';

  @override
  String get setHelp => 'Help';

  @override
  String get setInvite => 'Invite a friend';

  @override
  String get inviteCommunityTitle => 'Invite to the community';

  @override
  String get inviteFriendTitle => 'Invite a friend';

  @override
  String get inviteCommunityHeading => 'Invite people to the community';

  @override
  String get inviteFriendHeading => 'Invite your team to Chatsito';

  @override
  String get inviteCommunityCopy =>
      'Share this code: in Chatsito, \"Join with a code\". Expires in 7 days.';

  @override
  String get inviteFriendCopy =>
      'Share your personal link. When they join, you\'ll see them in your chats instantly.';

  @override
  String get copyAction => 'Copy';

  @override
  String get shareMessage => 'Message';

  @override
  String get shareEmail => 'Email';

  @override
  String get shareMore => 'More';

  @override
  String get done => 'Done';

  @override
  String get shareLink => 'Share link';

  @override
  String get actionAudio => 'Audio';

  @override
  String get actionVideo => 'Video';

  @override
  String get actionSearch => 'Search';

  @override
  String get actionMute => 'Mute';

  @override
  String get aboutHeader => 'About';

  @override
  String get aboutSample =>
      'Available ✨ Designing nice things on the product team.';

  @override
  String get mediaFiles => 'Media and files';

  @override
  String get seeAll => 'See all ›';

  @override
  String get muteNotifications => 'Mute notifications';

  @override
  String get tempMessages => 'Disappearing messages';

  @override
  String get disabled => 'Off';

  @override
  String get encryption => 'Encryption';

  @override
  String get verified => 'Verified';

  @override
  String blockContact(Object name) {
    return 'Block $name';
  }

  @override
  String get reportContact => 'Report contact';

  @override
  String get e2eNotice => 'Your messages are end-to-end encrypted.';

  @override
  String get catInfo => 'Information';

  @override
  String get catPhoneNumber => 'Phone number';

  @override
  String get catChangeNumber => 'Change number';

  @override
  String get catEmail => 'Email';

  @override
  String get catAdd => 'Add';

  @override
  String get catRequestInfo => 'Request my account info';

  @override
  String get catDeleteAccount => 'Delete my account';

  @override
  String get catWhoCanSee => 'Who can see my info';

  @override
  String get catLastSeen => 'Last seen and online';

  @override
  String get catEveryone => 'Everyone';

  @override
  String get catProfilePhoto => 'Profile photo';

  @override
  String get catMyContacts => 'My contacts';

  @override
  String get catStatus => 'Status';

  @override
  String get catReadReceipts => 'Read receipts';

  @override
  String get catBlocked => 'Blocked contacts';

  @override
  String get catScreenLock => 'Screen lock';

  @override
  String get catDisplay => 'Display';

  @override
  String get catTheme => 'Theme';

  @override
  String get catLight => 'Light';

  @override
  String get catWallpaper => 'Wallpaper';

  @override
  String get catFontSize => 'Font size';

  @override
  String get catMedium => 'Medium';

  @override
  String get catEnterToSend => 'Enter key to send';

  @override
  String get catSaveToRoll => 'Save to camera roll';

  @override
  String get catBackup => 'Backup';

  @override
  String get catChatHistory => 'Chat history';

  @override
  String get catMessages => 'Messages';

  @override
  String get catShowNotifications => 'Show notifications';

  @override
  String get catTone => 'Tone';

  @override
  String get catVibration => 'Vibration';

  @override
  String get catDefault => 'Default';

  @override
  String get catShowPreview => 'Show preview';

  @override
  String get catNotifyReactions => 'Notify reactions';

  @override
  String get catManageStorage => 'Manage storage';

  @override
  String get catAutoDownload => 'Auto-download';

  @override
  String get catOnMobile => 'On mobile data';

  @override
  String get catPhotos => 'Photos';

  @override
  String get catOnWifi => 'On Wi-Fi';

  @override
  String get catAll => 'Everything';

  @override
  String get catNetworkUsage => 'Network usage';

  @override
  String get catViewNetwork => 'View network usage';

  @override
  String get catLessData => 'Use less data for calls';

  @override
  String get catHelpCenter => 'Help center';

  @override
  String get catContactUs => 'Contact us';

  @override
  String get catTermsPrivacy => 'Terms and Privacy Policy';

  @override
  String get catAppInfo => 'App info';
}
