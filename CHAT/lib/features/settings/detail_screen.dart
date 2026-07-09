import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_toggle.dart';
import '../../l10n/app_localizations.dart';
import 'settings_catalog.dart';
import 'settings_controller.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<SettingsController>();
    final catalog = settingsCatalog(S.of(context));
    final detail = catalog[c.detailKey] ?? catalog['cuenta']!;
    return Container(
      color: C.field,
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Color(0xFFEEEFF2)))),
            padding: const EdgeInsets.only(top: 8),
            child: SizedBox(
              height: 50,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: c.backToSettings,
                      icon: const Icon(Icons.arrow_back_ios_new, size: 16, color: C.accent),
                      label: Text(S.of(context).settingsTitle, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: C.accent)),
                    ),
                  ),
                  Text(detail.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: C.ink)),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 40),
              children: [for (final g in detail.groups) _group(c, g)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _group(SettingsController c, SettingGroup g) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (g.header != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 18, 8, 8),
            child: Text(g.header!.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: C.muted, letterSpacing: .4)),
          ),
        Container(
          margin: const EdgeInsets.only(top: 12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: List.generate(g.rows.length, (i) {
              final r = g.rows[i];
              final last = i == g.rows.length - 1;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(border: last ? null : const Border(bottom: BorderSide(color: C.hair))),
                child: Row(children: [
                  Expanded(child: Text(r.label,
                    textAlign: r.isDanger ? TextAlign.center : TextAlign.left,
                    style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w500, color: r.isDanger ? C.danger : C.ink))),
                  if (r.isToggle)
                    AppToggle(c.isOn(r.toggleKey!), () => c.toggle(r.toggleKey!))
                  else if (!r.isDanger) ...[
                    if (r.detail.isNotEmpty) Text(r.detail, style: const TextStyle(fontSize: 14, color: C.muted)),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right, size: 20, color: C.arrow),
                  ],
                ]),
              );
            }),
          ),
        ),
      ],
    );
  }
}
