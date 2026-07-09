import '../../l10n/app_localizations.dart';

/// Static definition of the settings detail screens (rows + toggles).
class SettingRow {
  final String label, detail;
  final bool isToggle, isDanger;
  final String? toggleKey;
  const SettingRow.nav(this.label, [this.detail = '']) : isToggle = false, isDanger = false, toggleKey = null;
  const SettingRow.toggle(this.toggleKey, this.label) : detail = '', isToggle = true, isDanger = false;
  const SettingRow.danger(this.label) : detail = '', isToggle = false, isDanger = true, toggleKey = null;
}

class SettingGroup {
  final String? header;
  final List<SettingRow> rows;
  const SettingGroup(this.rows, {this.header});
}

class SettingDetail {
  final String title;
  final List<SettingGroup> groups;
  const SettingDetail(this.title, this.groups);
}

/// Catálogo localizado; los detalles numéricos ('2,4 GB', 'v1.0.0'…) quedan literales.
Map<String, SettingDetail> settingsCatalog(S t) => {
  'cuenta': SettingDetail(t.setAccount, [
    SettingGroup([SettingRow.nav(t.catPhoneNumber, '+34 555 555 555'), SettingRow.nav(t.catChangeNumber), SettingRow.nav(t.catEmail, t.catAdd)], header: t.catInfo),
    SettingGroup([SettingRow.nav(t.catRequestInfo)]),
    SettingGroup([SettingRow.danger(t.catDeleteAccount)]),
  ]),
  'privacidad': SettingDetail(t.setPrivacy, [
    SettingGroup([SettingRow.nav(t.catLastSeen, t.catEveryone), SettingRow.nav(t.catProfilePhoto, t.catMyContacts), SettingRow.nav(t.catStatus, t.catMyContacts)], header: t.catWhoCanSee),
    SettingGroup([SettingRow.toggle('readReceipts', t.catReadReceipts), SettingRow.nav(t.catBlocked, '3')]),
    SettingGroup([SettingRow.toggle('screenLock', t.catScreenLock), SettingRow.nav(t.tempMessages, t.disabled)]),
  ]),
  'chats': SettingDetail(t.setChats, [
    SettingGroup([SettingRow.nav(t.catTheme, t.catLight), SettingRow.nav(t.catWallpaper), SettingRow.nav(t.catFontSize, t.catMedium)], header: t.catDisplay),
    SettingGroup([SettingRow.toggle('enterToSend', t.catEnterToSend), SettingRow.toggle('saveToRoll', t.catSaveToRoll)]),
    SettingGroup([SettingRow.nav(t.catBackup, 'Hoy, 9:00'), SettingRow.nav(t.catChatHistory)], header: t.catBackup),
  ]),
  'notif': SettingDetail(t.setNotifications, [
    SettingGroup([SettingRow.toggle('msgNotif', t.catShowNotifications), SettingRow.nav(t.catTone, 'Nota'), SettingRow.nav(t.catVibration, t.catDefault)], header: t.catMessages),
    SettingGroup([SettingRow.toggle('groupNotif', t.catShowNotifications), SettingRow.nav(t.catTone, 'Nota')], header: t.navGroups),
    SettingGroup([SettingRow.toggle('showPreview', t.catShowPreview), SettingRow.toggle('reactionNotif', t.catNotifyReactions)]),
  ]),
  'storage': SettingDetail(t.setStorage, [
    SettingGroup([SettingRow.nav(t.catManageStorage, '2,4 GB')]),
    SettingGroup([SettingRow.nav(t.catOnMobile, t.catPhotos), SettingRow.nav(t.catOnWifi, t.catAll)], header: t.catAutoDownload),
    SettingGroup([SettingRow.nav(t.catViewNetwork), SettingRow.toggle('lessData', t.catLessData)], header: t.catNetworkUsage),
  ]),
  'ayuda': SettingDetail(t.setHelp, [
    SettingGroup([SettingRow.nav(t.catHelpCenter), SettingRow.nav(t.catContactUs), SettingRow.nav(t.catTermsPrivacy)]),
    SettingGroup([SettingRow.nav(t.catAppInfo, 'v1.0.0')]),
  ]),
};
