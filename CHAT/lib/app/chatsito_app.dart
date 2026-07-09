import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import 'app_shell.dart';

class ChatsitoApp extends StatelessWidget {
  const ChatsitoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chatsito',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      localizationsDelegates: S.localizationsDelegates,
      supportedLocales: S.supportedLocales,
      // idioma del sistema; si no está soportado, caemos a español
      localeResolutionCallback: (locale, supported) {
        for (final s in supported) {
          if (s.languageCode == locale?.languageCode) return s;
        }
        return const Locale('es');
      },
      home: const AppShell(),
    );
  }
}
