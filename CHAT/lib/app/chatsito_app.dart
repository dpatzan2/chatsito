import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'app_shell.dart';

class ChatsitoApp extends StatelessWidget {
  const ChatsitoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chatsito',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const AppShell(),
    );
  }
}
