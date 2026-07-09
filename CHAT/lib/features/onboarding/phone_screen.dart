import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/countries.dart';
import '../../core/widgets/back_chevron.dart';
import '../../core/widgets/numeric_keypad.dart';
import '../../core/widgets/primary_button.dart';
import '../../l10n/app_localizations.dart';
import 'onboarding_controller.dart';

class PhoneScreen extends StatelessWidget {
  const PhoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<OnboardingController>();
    final t = S.of(context);
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(alignment: Alignment.centerLeft, child: BackChevron(() => c.back(AppScreen.welcome))),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(32, 18, 32, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.phoneTitle, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: C.ink, letterSpacing: -.4)),
                  const SizedBox(height: 10),
                  Text(t.phoneSubtitle,
                    style: const TextStyle(fontSize: 14.5, height: 1.5, color: C.sub)),
                  const SizedBox(height: 32),
                  Row(children: [
                    GestureDetector(
                      onTap: () => _pickCountry(context, c),
                      child: Container(
                        height: 58, padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(color: C.fieldAlt, borderRadius: BorderRadius.circular(14), border: Border.all(color: C.border, width: 1.5)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text(c.country.flag, style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: 6),
                          Text('+${c.country.dial}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: C.ink)),
                          const Icon(Icons.expand_more, size: 18, color: C.muted),
                        ]),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        height: 58, padding: const EdgeInsets.symmetric(horizontal: 18),
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          color: Colors.white, borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: C.accent, width: 1.5),
                          boxShadow: [BoxShadow(color: C.aOpacity(88), blurRadius: 0, spreadRadius: 4)],
                        ),
                        child: Row(children: [
                          Flexible(child: Text(c.phoneFormatted, maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: C.ink, letterSpacing: .5))),
                          Container(width: 2, height: 24, margin: const EdgeInsets.only(left: 3), color: C.accent),
                        ]),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  Text(t.phoneCarrierFee, style: const TextStyle(fontSize: 12.5, color: C.muted)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: PrimaryButton(t.phoneCta, c.submitPhone, enabled: c.phoneComplete),
          ),
          const SizedBox(height: 6),
          NumericKeypad(onDigit: c.onDigit, onBackspace: c.onBackspace),
        ],
      ),
    );
  }
}

void _pickCountry(BuildContext context, OnboardingController c) {
  var query = '';
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (sheet) => StatefulBuilder(
      builder: (sheet, setState) {
        final visible = [
          for (final k in countries)
            if (query.isEmpty ||
                k.name.toLowerCase().contains(query) ||
                ('+${k.dial}').contains(query))
              k,
        ];
        return SizedBox(
          height: MediaQuery.sizeOf(sheet).height * .72,
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: TextField(
                onChanged: (v) => setState(() => query = v.trim().toLowerCase()),
                decoration: InputDecoration(
                  hintText: S.of(context).searchCountry,
                  prefixIcon: const Icon(Icons.search, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(13)),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: visible.length,
                itemBuilder: (_, i) {
                  final k = visible[i];
                  return ListTile(
                    leading: Text(k.flag, style: const TextStyle(fontSize: 22)),
                    title: Text(k.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    trailing: Text('+${k.dial}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: C.accent)),
                    onTap: () {
                      c.setCountry(k);
                      Navigator.pop(sheet);
                    },
                  );
                },
              ),
            ),
          ]),
        );
      },
    ),
  );
}
