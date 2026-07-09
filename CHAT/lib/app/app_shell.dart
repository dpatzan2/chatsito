import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../features/chat/chat_screen.dart';
import '../features/chats/chats_screen.dart';
import '../features/group/create_group_screen.dart';
import '../features/group/group_screen.dart';
import '../features/group/role_edit_screen.dart';
import '../features/group/roles_screen.dart';
import '../features/group/voice_screen.dart';
import '../features/onboarding/otp_screen.dart';
import '../features/onboarding/phone_screen.dart';
import '../features/onboarding/profile_screen.dart';
import '../features/onboarding/welcome_screen.dart';
import '../features/settings/contact_profile_screen.dart';
import '../features/settings/detail_screen.dart';
import '../features/settings/invite_screen.dart';
import '../features/settings/settings_screen.dart';
import 'app_router.dart';

/// Renders the active screen full-bleed (no device frame). Fully responsive:
/// fills any window/phone, content kept clear of the OS status bar via SafeArea.
class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final screen = context.watch<AppRouter>().screen;
    return Scaffold(
      backgroundColor: C.field,
      body: SafeArea(
        bottom: false,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween(begin: const Offset(.04, 0), end: Offset.zero).animate(anim),
              child: child,
            ),
          ),
          child: KeyedSubtree(key: ValueKey(screen), child: _screenFor(screen)),
        ),
      ),
    );
  }

  Widget _screenFor(AppScreen screen) => switch (screen) {
        AppScreen.welcome => const WelcomeScreen(),
        AppScreen.phone => const PhoneScreen(),
        AppScreen.otp => const OtpScreen(),
        AppScreen.profile => const ProfileScreen(),
        AppScreen.chats => const ChatsScreen(),
        AppScreen.chat => const ChatScreen(),
        AppScreen.createGroup => const CreateGroupScreen(),
        AppScreen.group => const GroupScreen(),
        AppScreen.voice => const VoiceScreen(),
        AppScreen.roles => const RolesScreen(),
        AppScreen.roleEdit => const RoleEditScreen(),
        AppScreen.settings => const SettingsScreen(),
        AppScreen.detail => const DetailScreen(),
        AppScreen.invite => const InviteScreen(),
        AppScreen.contactProfile => const ContactProfileScreen(),
      };
}
