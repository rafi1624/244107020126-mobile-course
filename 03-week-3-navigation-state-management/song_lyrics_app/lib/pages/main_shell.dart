import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import 'about_page.dart';

class MainShell extends ConsumerWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/lyrics')) return 1;
    if (location.startsWith('/stats')) return 2;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/lyrics');
        break;
      case 2:
        context.go('/stats');
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = _calculateSelectedIndex(context);
    final isDark = ref.watch(themeProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 700;

        return Scaffold(
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  child: const Text('Menu Aplikasi', style: TextStyle(fontSize: 24)),
                ),
                ListTile(
                  leading: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
                  title: const Text('Ganti Tema'),
                  onTap: () => ref.read(themeProvider.notifier).toggle(),
                ),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('Tentang Aplikasi'),
                  onTap: () {
                    // Close the drawer first
                    Navigator.pop(context);
                    // Custom transition using PageRouteBuilder
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => const AboutPage(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.easeInOut;

                          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                          return SlideTransition(
                            position: animation.drive(tween),
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          body: isWide
              ? Row(
                  children: [
                    NavigationRail(
                      selectedIndex: currentIndex,
                      onDestinationSelected: (index) => _onItemTapped(index, context),
                      labelType: NavigationRailLabelType.all,
                      destinations: const [
                        NavigationRailDestination(
                          icon: Icon(Icons.home),
                          label: Text('Home'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.music_note),
                          label: Text('Lyrics'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.analytics),
                          label: Text('Stats'),
                        ),
                      ],
                    ),
                    const VerticalDivider(thickness: 1, width: 1),
                    Expanded(child: child),
                  ],
                )
              : child,
          bottomNavigationBar: isWide
              ? null
              : BottomNavigationBar(
                  currentIndex: currentIndex,
                  onTap: (index) => _onItemTapped(index, context),
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.music_note),
                      label: 'Lyrics',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.analytics),
                      label: 'Stats',
                    ),
                  ],
                ),
        );
      },
    );
  }
}
