import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/back_chevron.dart';
import '../../core/widgets/numeric_keypad.dart';
import '../../core/widgets/primary_button.dart';
import 'onboarding_controller.dart';

class PhoneScreen extends StatelessWidget {
  const PhoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<OnboardingController>();
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
                  const Text('Tu número de teléfono', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: C.ink, letterSpacing: -.4)),
                  const SizedBox(height: 10),
                  const Text('Te enviaremos un SMS con un código de 6 dígitos para verificar tu cuenta.',
                    style: TextStyle(fontSize: 14.5, height: 1.5, color: C.sub)),
                  const SizedBox(height: 32),
                  Row(children: [
                    Container(
                      height: 58, padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(color: C.fieldAlt, borderRadius: BorderRadius.circular(14), border: Border.all(color: C.border, width: 1.5)),
                      child: const Row(children: [
                        Text('🇪🇸', style: TextStyle(fontSize: 20)),
                        SizedBox(width: 8),
                        Text('+34', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: C.ink)),
                      ]),
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
                  const Text('Puede que se apliquen tarifas de tu operador.', style: TextStyle(fontSize: 12.5, color: C.muted)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: PrimaryButton('Enviar código', c.submitPhone, enabled: c.phoneComplete),
          ),
          const SizedBox(height: 6),
          NumericKeypad(onDigit: c.onDigit, onBackspace: c.onBackspace),
        ],
      ),
    );
  }
}
