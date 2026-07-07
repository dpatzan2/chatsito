import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../data/in_memory_auth_repository.dart';
import '../data/in_memory_chat_repository.dart';
import '../data/in_memory_settings_repository.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/chat_repository.dart';
import '../domain/repositories/settings_repository.dart';
import '../features/chat/chat_controller.dart';
import '../features/group/call_controller.dart';
import '../features/group/group_controller.dart';
import '../features/onboarding/onboarding_controller.dart';
import '../features/settings/settings_controller.dart';
import 'app_router.dart';

/// Composition root. Repositories are bound to their interfaces, so swapping
/// the in-memory implementations for API-backed ones is a one-line change here.
class AppProviders extends StatelessWidget {
  final Widget child;
  const AppProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ---- infrastructure ----
        ChangeNotifierProvider(create: (_) => AppRouter()),
        ChangeNotifierProvider<AuthRepository>(create: (_) => InMemoryAuthRepository()),
        ChangeNotifierProvider<ChatRepository>(create: (_) => InMemoryChatRepository()),
        ChangeNotifierProvider<SettingsRepository>(create: (_) => InMemorySettingsRepository()),
        // ---- feature controllers ----
        ChangeNotifierProvider(create: (c) => OnboardingController(c.read<AuthRepository>(), c.read<AppRouter>())),
        ChangeNotifierProvider(create: (c) => ChatController(c.read<ChatRepository>(), c.read<AppRouter>())),
        ChangeNotifierProvider(create: (c) => GroupController(c.read<ChatRepository>(), c.read<AppRouter>())),
        ChangeNotifierProvider(create: (c) => CallController(c.read<AuthRepository>(), c.read<AppRouter>())),
        ChangeNotifierProvider(create: (c) => SettingsController(c.read<SettingsRepository>(), c.read<AppRouter>())),
      ],
      child: child,
    );
  }
}
