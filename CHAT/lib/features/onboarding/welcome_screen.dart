import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';
import 'onboarding_controller.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.read<OnboardingController>();
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -1),
          radius: 1.1,
          colors: [C.tint(84), Colors.white],
          stops: const [0, .6],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(32, 56, 32, 44),
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 96, height: 96,
                  decoration: BoxDecoration(
                    color: C.accent,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [BoxShadow(color: C.aOpacity(62), blurRadius: 40, offset: const Offset(0, 18))],
                  ),
                  child: const Icon(Icons.forum_rounded, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 30),
                const Text('Chatsito', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: C.ink, letterSpacing: -.6)),
                const SizedBox(height: 14),
                const SizedBox(
                  width: 250,
                  child: Text('Mensajería privada para tu equipo. Chats, grupos, canales de voz y mucho más.',
                    textAlign: TextAlign.center, style: TextStyle(fontSize: 16, height: 1.5, color: C.sub)),
                ),
              ],
            ),
          ),
          PrimaryButton('Continuar con tu número', c.start),
          const Padding(
            padding: EdgeInsets.fromLTRB(4, 18, 4, 0),
            child: Text.rich(
              TextSpan(
                style: TextStyle(fontSize: 11.5, height: 1.6, color: Color(0xFF9A9DA8)),
                children: [
                  TextSpan(text: 'Al continuar aceptas los '),
                  TextSpan(text: 'Términos', style: TextStyle(color: C.accent, fontWeight: FontWeight.w600)),
                  TextSpan(text: ' y la '),
                  TextSpan(text: 'Política de privacidad', style: TextStyle(color: C.accent, fontWeight: FontWeight.w600)),
                  TextSpan(text: ' de Chatsito.'),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
