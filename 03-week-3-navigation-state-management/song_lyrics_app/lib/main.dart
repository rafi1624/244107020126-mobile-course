import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'providers/theme_provider.dart';
import 'pages/home_page.dart';
import 'pages/lyrics_page.dart';
import 'pages/stats_page.dart';

import 'pages/animation_page.dart';
import 'pages/async_state_page.dart';
import 'pages/camera_page.dart';
import 'pages/qr_scanner_page.dart';

import 'pages/main_shell.dart';

void main() => runApp(const ProviderScope(child: SongLyricsApp()));

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/lyrics',
          builder: (context, state) => const LyricsPage(),
        ),
        GoRoute(
          path: '/stats',
          builder: (context, state) => const StatsPage(),
        ),
        GoRoute(
          path: '/animation',
          builder: (context, state) => const AnimationPage(),
        ),
        GoRoute(
          path: '/async-state',
          builder: (context, state) => const AsyncStatePage(),
        ),
        GoRoute(
          path: '/camera',
          builder: (context, state) => const CameraPage(),
        ),
        GoRoute(
          path: '/qr-scanner',
          builder: (context, state) => const QRScannerPage(),
        ),
      ],
    ),
  ],
);

class SongLyricsApp extends ConsumerWidget {
  const SongLyricsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Song Lyrics & Navigation',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.deepPurple,
      ),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
    );
  }
}
