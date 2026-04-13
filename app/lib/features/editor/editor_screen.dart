import 'package:flutter/material.dart';

// TODO: Full editor implementation — Phase 1
class EditorScreen extends StatelessWidget {
  final String songId;
  const EditorScreen({super.key, required this.songId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editor')),
      body: Center(child: Text('Editor for song: $songId')),
    );
  }
}
