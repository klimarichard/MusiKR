import 'package:flutter/material.dart';
import 'router.dart';

class MusiKRApp extends StatelessWidget {
  const MusiKRApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MusiKR',
      routerConfig: appRouter,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A1A2E)),
        useMaterial3: true,
      ),
    );
  }
}
