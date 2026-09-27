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
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF7C3AED),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B5CF6),
          brightness: Brightness.dark,
          surface: const Color(0xFF16192B),
        ),
        scaffoldBackgroundColor: const Color(0xFF0D0F1D),
        cardTheme: CardThemeData(
          color: const Color(0xFF1A1E36),
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: Colors.white.withOpacity(0.08),
              width: 1,
            ),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D0F1D),
          elevation: 0,
        ),
      ),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
    );
  }
}
