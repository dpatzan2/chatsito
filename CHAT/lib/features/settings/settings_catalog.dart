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

const settingsCatalog = <String, SettingDetail>{
  'cuenta': SettingDetail('Cuenta', [
    SettingGroup([SettingRow.nav('Número de teléfono', '+34 555 555 555'), SettingRow.nav('Cambiar número'), SettingRow.nav('Correo electrónico', 'Añadir')], header: 'Información'),
    SettingGroup([SettingRow.nav('Solicitar información de mi cuenta')]),
    SettingGroup([SettingRow.danger('Eliminar mi cuenta')]),
  ]),
  'privacidad': SettingDetail('Privacidad', [
    SettingGroup([SettingRow.nav('Última vez y en línea', 'Todos'), SettingRow.nav('Foto de perfil', 'Mis contactos'), SettingRow.nav('Estado', 'Mis contactos')], header: 'Quién puede ver mi info'),
    SettingGroup([SettingRow.toggle('readReceipts', 'Confirmaciones de lectura'), SettingRow.nav('Contactos bloqueados', '3')]),
    SettingGroup([SettingRow.toggle('screenLock', 'Bloqueo con código'), SettingRow.nav('Mensajes temporales', 'Desactivado')]),
  ]),
  'chats': SettingDetail('Chats', [
    SettingGroup([SettingRow.nav('Tema', 'Claro'), SettingRow.nav('Fondo de pantalla'), SettingRow.nav('Tamaño de fuente', 'Mediano')], header: 'Pantalla'),
    SettingGroup([SettingRow.toggle('enterToSend', 'Tecla Enter para enviar'), SettingRow.toggle('saveToRoll', 'Guardar en el carrete')]),
    SettingGroup([SettingRow.nav('Copia de seguridad', 'Hoy, 9:00'), SettingRow.nav('Historial de chats')], header: 'Copia de seguridad'),
  ]),
  'notif': SettingDetail('Notificaciones', [
    SettingGroup([SettingRow.toggle('msgNotif', 'Mostrar notificaciones'), SettingRow.nav('Tono', 'Nota'), SettingRow.nav('Vibración', 'Predeterminada')], header: 'Mensajes'),
    SettingGroup([SettingRow.toggle('groupNotif', 'Mostrar notificaciones'), SettingRow.nav('Tono', 'Nota')], header: 'Grupos'),
    SettingGroup([SettingRow.toggle('showPreview', 'Mostrar vista previa'), SettingRow.toggle('reactionNotif', 'Notificar reacciones')]),
  ]),
  'storage': SettingDetail('Almacenamiento y datos', [
    SettingGroup([SettingRow.nav('Administrar almacenamiento', '2,4 GB')]),
    SettingGroup([SettingRow.nav('Con datos móviles', 'Fotos'), SettingRow.nav('Con Wi-Fi', 'Todo')], header: 'Descarga automática'),
    SettingGroup([SettingRow.nav('Ver uso de red'), SettingRow.toggle('lessData', 'Usar menos datos en llamadas')], header: 'Uso de la red'),
  ]),
  'ayuda': SettingDetail('Ayuda', [
    SettingGroup([SettingRow.nav('Centro de ayuda'), SettingRow.nav('Contáctanos'), SettingRow.nav('Términos y Política de privacidad')]),
    SettingGroup([SettingRow.nav('Información de la app', 'v1.0.0')]),
  ]),
};
