import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/chatsito_app.dart';
import 'app/providers.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
  ));
  runApp(const AppProviders(child: ChatsitoApp()));
}
