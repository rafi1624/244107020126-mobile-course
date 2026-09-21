import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/theme_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Lagu (Home)'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
            onPressed: () => ref.read(themeProvider.notifier).toggle(),
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.music_note)),
            title: const Text('Bohemian Rhapsody'),
            subtitle: const Text('Queen'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/lyrics'),
          ),
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.analytics)),
            title: const Text('Statistik Lagu'),
            subtitle: const Text('Data performa lagu (Simulasi API Async)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/stats'),
          ),
        ],
      ),
    );
  }
}
