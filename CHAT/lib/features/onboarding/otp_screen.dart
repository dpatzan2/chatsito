import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/back_chevron.dart';
import '../../core/widgets/numeric_keypad.dart';
import 'onboarding_controller.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<OnboardingController>();
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(alignment: Alignment.centerLeft, child: BackChevron(() => c.back(AppScreen.phone))),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(32, 18, 32, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 54, height: 54,
                    decoration: BoxDecoration(color: C.tint(86), borderRadius: BorderRadius.circular(16)),
                    child: const Icon(Icons.mail_outline, color: C.accent, size: 26),
                  ),
                  const SizedBox(height: 22),
                  const Text('Verifica tu número', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: C.ink, letterSpacing: -.4)),
                  const SizedBox(height: 10),
                  Text.rich(TextSpan(
                    style: const TextStyle(fontSize: 14.5, height: 1.5, color: C.sub),
                    children: [
                      const TextSpan(text: 'Introduce el código enviado al '),
                      TextSpan(text: '+34 ${c.phoneFormatted}', style: const TextStyle(color: C.ink, fontWeight: FontWeight.w700)),
                    ],
                  )),
                  const SizedBox(height: 30),
                  Row(children: List.generate(6, (i) {
                    final char = i < c.otp.length ? c.otp[i] : '';
                    final active = i == c.otp.length;
                    final filled = char.isNotEmpty;
                    return Expanded(
                      child: Container(
                        height: 62,
                        margin: EdgeInsets.only(right: i == 5 ? 0 : 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: filled ? C.tint(92) : C.fieldAlt,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: (filled || active) ? C.accent : C.border, width: 1.5),
                          boxShadow: active ? [BoxShadow(color: C.aOpacity(88), blurRadius: 0, spreadRadius: 4)] : null,
                        ),
                        child: Text(char, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: C.ink)),
                      ),
                    );
                  })),
                  const SizedBox(height: 26),
                  const Row(children: [
                    Text('¿No llegó?', style: TextStyle(fontSize: 13.5, color: C.muted)),
                    SizedBox(width: 7),
                    Text('Reenviar en 0:28', style: TextStyle(fontSize: 13.5, color: C.accent, fontWeight: FontWeight.w700)),
                  ]),
                ],
              ),
            ),
          ),
          NumericKeypad(onDigit: c.onDigit, onBackspace: c.onBackspace),
        ],
      ),
    );
  }
}
