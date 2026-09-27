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
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          ClipRect(
            child: Banner(
              message: 'HOT',
              location: BannerLocation.topEnd,
              color: Colors.red,
              child: Card(
                elevation: 4,
                child: InkWell(
                  onTap: () => context.go('/lyrics'),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Tooltip(
                          message: 'Lihat lirik Bohemian Rhapsody',
                          child: CircleAvatar(radius: 30, child: Icon(Icons.music_note, size: 30)),
                        ),
                        SizedBox(height: 16),
                        Text('Lirik Lagu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(height: 8),
                        Text('Bohemian Rhapsody', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Card(
            elevation: 4,
            child: InkWell(
              onTap: () => context.go('/stats'),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Tooltip(
                      message: 'Lihat performa lagu',
                      child: CircleAvatar(radius: 30, child: Icon(Icons.analytics, size: 30)),
                    ),
                    SizedBox(height: 16),
                    Text('Statistik', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 8),
                    Text('Data Performa', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
                    SizedBox(height: 16),
                    LinearProgressIndicator(value: 0.7),
                  ],
                ),
              ),
            ),
          ),
          Card(
            elevation: 4,
            child: InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Konfirmasi'),
                    content: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Apakah Anda ingin menyinkronkan data?'),
                        SizedBox(height: 16),
                        CircularProgressIndicator(),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Sinkronisasi berhasil dimulai')),
                          );
                        },
                        child: const Text('Ya'),
                      ),
                    ],
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Tooltip(
                      message: 'Tampilkan Dialog',
                      child: CircleAvatar(radius: 30, child: Icon(Icons.sync, size: 30)),
                    ),
                    SizedBox(height: 16),
                    Text('Sinkronisasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 8),
                    Text('Demo Dialog & Progress', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
          Card(
            elevation: 4,
            child: InkWell(
              onTap: () => context.go('/animation'),
              borderRadius: BorderRadius.circular(12),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Tooltip(
                      message: 'Lihat Demo Animasi',
                      child: Hero(
                        tag: 'animation_hero_tag',
                        child: CircleAvatar(radius: 30, child: Icon(Icons.animation, size: 30)),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text('Animasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 8),
                    Text('Demo Widget Animasi', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
          Card(
            elevation: 4,
            child: InkWell(
              onTap: () => context.go('/async-state'),
              borderRadius: BorderRadius.circular(12),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Tooltip(
                      message: 'Lihat Demo Async & State',
                      child: CircleAvatar(radius: 30, child: Icon(Icons.sync_alt, size: 30)),
                    ),
                    SizedBox(height: 16),
                    Text('Async & State', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 8),
                    Text('Demo Stream, Future, dll', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
          Card(
            elevation: 4,
            child: InkWell(
              onTap: () => context.go('/camera'),
              borderRadius: BorderRadius.circular(12),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Tooltip(
                      message: 'Buka Kamera',
                      child: CircleAvatar(radius: 30, child: Icon(Icons.camera_alt, size: 30)),
                    ),
                    SizedBox(height: 16),
                    Text('Kamera', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 8),
                    Text('Demo Plugin Kamera', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
          Card(
            elevation: 4,
            child: InkWell(
              onTap: () => context.go('/qr-scanner'),
              borderRadius: BorderRadius.circular(12),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Tooltip(
                      message: 'Buka QR Scanner',
                      child: CircleAvatar(radius: 30, child: Icon(Icons.qr_code_scanner, size: 30)),
                    ),
                    SizedBox(height: 16),
                    Text('QR Scanner', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 8),
                    Text('Kamera + Overlay', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
