import 'package:flutter/material.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class MusiKRApp extends StatelessWidget {
  const MusiKRApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MusiKR',
      routerConfig: appRouter,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
    );
  }
}
