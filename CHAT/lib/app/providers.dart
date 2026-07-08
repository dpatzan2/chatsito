import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../data/api/api_client.dart';
import '../data/api/ws_client.dart';
import '../data/api_auth_repository.dart';
import '../data/api_chat_repository.dart';
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

/// Composition root: repositorios API contra el backend de `server/`.
class AppProviders extends StatefulWidget {
  final Widget child;
  const AppProviders({super.key, required this.child});

  @override
  State<AppProviders> createState() => _AppProvidersState();
}

class _AppProvidersState extends State<AppProviders> {
  final _api = ApiClient(defaultApiBase);
  late final _ws =
      WsClient(defaultApiBase.replaceFirst('http', 'ws'), () => _api.access ?? '');

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ---- infrastructure ----
        ChangeNotifierProvider(create: (_) => AppRouter()),
        ChangeNotifierProvider<AuthRepository>(create: (_) => ApiAuthRepository(_api)),
        ChangeNotifierProvider<ChatRepository>(
            create: (c) => ApiChatRepository(_api, _ws, c.read<AuthRepository>())),
        ChangeNotifierProvider<SettingsRepository>(create: (_) => InMemorySettingsRepository()),
        // ---- feature controllers ----
        ChangeNotifierProvider(create: (c) => OnboardingController(c.read<AuthRepository>(), c.read<AppRouter>())),
        ChangeNotifierProvider(create: (c) => ChatController(c.read<ChatRepository>(), c.read<AppRouter>())),
        ChangeNotifierProvider(create: (c) => GroupController(c.read<ChatRepository>(), c.read<AppRouter>())),
        ChangeNotifierProvider(create: (c) => CallController(c.read<AuthRepository>(), c.read<ChatRepository>(), c.read<AppRouter>())),
        ChangeNotifierProvider(create: (c) => SettingsController(c.read<SettingsRepository>(), c.read<AppRouter>())),
      ],
      child: widget.child,
    );
  }
}
