import 'package:go_router/go_router.dart';
import '../features/library/library_screen.dart';
import '../features/editor/editor_screen.dart';
import '../features/settings/settings_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/library',
  routes: [
    GoRoute(
      path: '/library',
      builder: (context, state) => const LibraryScreen(),
    ),
    GoRoute(
      path: '/editor/:songId',
      builder: (context, state) => EditorScreen(
        songId: state.pathParameters['songId']!,
      ),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
