import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/avatar.dart';
import '../../core/widgets/primary_button.dart';
import '../../domain/models/contact.dart';
import '../../l10n/app_localizations.dart';
import 'group_controller.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});
  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  late final TextEditingController _name;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: context.read<GroupController>().groupName);
  }

  @override
  void dispose() { _name.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<GroupController>();
    final n = c.selectedCount;
    final t = S.of(context);
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 8, 14, 6),
            child: Row(children: [
              IconButton(onPressed: c.back, icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: C.ink)),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.newGroupTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: C.ink)),
                  Text(t.participantsSelected(n), style: const TextStyle(fontSize: 12.5, color: C.muted)),
                ],
              )),
            ]),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: C.field, width: 8))),
            child: Row(children: [
              Container(
                width: 54, height: 54,
                decoration: BoxDecoration(color: C.tint(84), borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.groups, color: C.accent, size: 24),
              ),
              const SizedBox(width: 13),
              Expanded(child: TextField(
                controller: _name,
                onChanged: c.setGroupName,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: C.ink),
                decoration: InputDecoration(
                  hintText: t.groupNameHint, hintStyle: const TextStyle(color: C.muted, fontWeight: FontWeight.w600),
                  enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: C.border, width: 1.5)),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: C.accent, width: 1.5)),
                ),
              )),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 6),
            child: Align(alignment: Alignment.centerLeft, child: Text(t.addParticipants.toUpperCase(), style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: C.muted, letterSpacing: .4))),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 20),
              children: [for (final p in c.contacts) _row(c, p)],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 30),
            child: PrimaryButton(t.createGroupCta, c.create, height: 54),
          ),
        ],
      ),
    );
  }

  Widget _row(GroupController c, Contact contact) {
    final sel = c.isSelected(contact.id);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => c.toggle(contact.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 9),
        child: Row(children: [
          Avatar(contact.initials, contact.color, size: 46, fontSize: 15),
          const SizedBox(width: 13),
          Expanded(child: Text(contact.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: C.ink))),
          Container(
            width: 24, height: 24,
            decoration: BoxDecoration(
              color: sel ? C.accent : Colors.transparent, shape: BoxShape.circle,
              border: Border.all(color: sel ? C.accent : const Color(0xFFD4D6DE), width: 2),
            ),
            child: sel ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
          ),
        ]),
      ),
    );
  }
}
