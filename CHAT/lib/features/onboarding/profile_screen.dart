import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/primary_button.dart';
import 'onboarding_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _name;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: context.read<OnboardingController>().name);
  }

  @override
  void dispose() { _name.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<OnboardingController>();
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(32, 30, 32, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Configura tu perfil', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: C.ink, letterSpacing: -.4)),
                  const SizedBox(height: 10),
                  const Text('Pon tu nombre y una foto. Podrás cambiarlos cuando quieras.', style: TextStyle(fontSize: 14.5, height: 1.5, color: C.sub)),
                  const SizedBox(height: 34),
                  Center(
                    child: Stack(clipBehavior: Clip.none, children: [
                      Container(
                        width: 104, height: 104,
                        decoration: const BoxDecoration(color: Color(0xFFEEF0F3), shape: BoxShape.circle),
                        child: const Icon(Icons.person_outline, size: 42, color: Color(0xFFB7BAC4)),
                      ),
                      Positioned(
                        bottom: -2, right: -2,
                        child: Container(
                          width: 34, height: 34,
                          decoration: BoxDecoration(color: C.accent, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)),
                          child: const Icon(Icons.photo_camera_outlined, size: 16, color: Colors.white),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 34),
                  const Text('TU NOMBRE', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: C.muted, letterSpacing: .4)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _name,
                    onChanged: c.setName,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: C.ink),
                    decoration: InputDecoration(
                      hintText: 'Ej. Marta García',
                      hintStyle: const TextStyle(color: C.muted, fontWeight: FontWeight.w600),
                      filled: true, fillColor: C.fieldAlt,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: C.border, width: 1.5)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: C.border, width: 1.5)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: C.accent, width: 1.5)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 0, 32, 30),
            child: PrimaryButton('Empezar a chatear', c.finish, enabled: c.nameValid),
          ),
        ],
      ),
    );
  }
}
