import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AnnouncementPage extends StatelessWidget {
  const AnnouncementPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pengumuman Kampus'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.campaign, color: Colors.indigo, size: 28),
                        const SizedBox(width: 8),
                        Text(
                          'Pengumuman #$id',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    const Text(
                      'Halaman ini dibuka otomatis melalui Deep Linking Firebase Cloud Messaging (FCM payload route: /pengumuman/:id).',
                      style: TextStyle(fontSize: 14, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.home),
                label: const Text('Kembali ke Dashboard'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
