import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';
import '../../domain/models/community.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../l10n/app_localizations.dart';
import 'group_controller.dart';

const _palette = <Color>[
  Color(0xFF7C5CFF), Color(0xFF2A9D8F), Color(0xFFE76F51), Color(0xFF4A90D9),
  Color(0xFFC44BC7), Color(0xFFE9C46A), Color(0xFF1FD27A), Color(0xFFE5484D),
];

class RoleEditScreen extends StatefulWidget {
  const RoleEditScreen({super.key});
  @override
  State<RoleEditScreen> createState() => _RoleEditScreenState();
}

class _RoleEditScreenState extends State<RoleEditScreen> {
  late final TextEditingController _name;
  Role? _role;
  Color? _color;
  BigInt _perms = BigInt.zero;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _role = context.read<GroupController>().editingRole;
    _name = TextEditingController(text: _role?.name ?? '');
    _color = _role?.color;
    _perms = _role?.permissions ?? BigInt.zero;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy) return;
    final chat = context.read<ChatRepository>();
    final gc = context.read<GroupController>();
    setState(() => _busy = true);
    final everyone = _role?.isEveryone ?? false;
    if (_role == null) {
      await chat.createRole(
          _name.text.trim().isEmpty ? 'Nuevo rol' : _name.text.trim(), _color, _perms);
    } else {
      await chat.updateRole(_role!.id,
          name: everyone ? null : _name.text.trim(),
          color: everyone ? null : _color,
          permissions: _perms);
    }
    gc.closeRoleEdit();
  }

  Future<void> _delete() async {
    if (_busy) return;
    final chat = context.read<ChatRepository>();
    final gc = context.read<GroupController>();
    setState(() => _busy = true);
    await chat.deleteRole(_role!.id);
    gc.closeRoleEdit();
  }

  String _permLabel(S t, BigInt bit) {
    if (bit == Perm.viewChannel) return t.permViewChannel;
    if (bit == Perm.sendMessages) return t.permSendMessages;
    if (bit == Perm.manageMessages) return t.permManageMessages;
    if (bit == Perm.manageChannels) return t.permManageChannels;
    if (bit == Perm.manageRoles) return t.permManageRoles;
    if (bit == Perm.kickMembers) return t.permKickMembers;
    if (bit == Perm.manageInvites) return t.permManageInvites;
    if (bit == Perm.voiceConnect) return t.permVoiceConnect;
    if (bit == Perm.voiceSpeak) return t.permVoiceSpeak;
    if (bit == Perm.voiceMuteMembers) return t.permVoiceMuteMembers;
    return t.permAdmin;
  }

  @override
  Widget build(BuildContext context) {
    final gc = context.read<GroupController>();
    final community = context.watch<ChatRepository>().activeCommunity;
    final everyone = _role?.isEveryone ?? false;
    final t = S.of(context);
    return Container(
      color: C.ink,
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(6, 14, 14, 6),
          child: Row(children: [
            IconButton(
                onPressed: gc.closeRoleEdit,
                icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white)),
            Expanded(
                child: Text(_role == null ? t.newRole : _role!.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white))),
            if (_role != null && !everyone)
              IconButton(
                  onPressed: _delete,
                  icon: const Icon(Icons.delete_outline, color: C.danger)),
          ]),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
            children: [
              if (!everyone) ...[
                _label(t.roleNameLabel),
                TextField(
                  controller: _name,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: t.roleNameHint,
                    hintStyle: const TextStyle(color: Color(0xFF7E8190)),
                    enabledBorder:
                        const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF3A3D49))),
                    focusedBorder:
                        const UnderlineInputBorder(borderSide: BorderSide(color: C.accent)),
                  ),
                ),
                _label(t.roleColor),
                Wrap(spacing: 10, runSpacing: 10, children: [
                  for (final c in _palette)
                    GestureDetector(
                      onTap: () => setState(() => _color = c),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: _color == c ? Border.all(color: Colors.white, width: 3) : null,
                        ),
                      ),
                    ),
                ]),
              ],
              _label(t.rolePermissions),
              for (final bit in Perm.bits)
                SwitchListTile(
                  value: _perms & bit == bit,
                  onChanged: (v) =>
                      setState(() => _perms = v ? (_perms | bit) : (_perms & ~bit)),
                  title: Text(_permLabel(t, bit),
                      style: const TextStyle(fontSize: 14.5, color: Color(0xFFC7CAD3))),
                  activeTrackColor: C.accent,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              if (_role != null && !everyone && community != null) ...[
                _label(t.roleMembers),
                for (final m in community.members)
                  CheckboxListTile(
                    value: m.roleIds.contains(_role!.id),
                    onChanged: (v) => context
                        .read<ChatRepository>()
                        .setMemberRole(m.id, _role!.id, assign: v ?? false),
                    title: Text(m.name,
                        style: const TextStyle(fontSize: 14.5, color: Color(0xFFC7CAD3))),
                    activeColor: C.accent,
                    checkColor: Colors.white,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
              ],
              const SizedBox(height: 20),
              PrimaryButton(_role == null ? t.createRoleCta : t.saveRole, _save, height: 52),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(0, 22, 0, 8),
        child: Text(t.toUpperCase(),
            style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF7E8190),
                letterSpacing: .6)),
      );
}
