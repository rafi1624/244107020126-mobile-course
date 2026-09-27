import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/stats_provider.dart';

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Statistik Lagu'),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Hapus Data'),
                    content: const Text('Apakah Anda yakin ingin mereset/menghapus semua data statistik?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Batal'),
                      ),
                      FilledButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Data berhasil dihapus!')),
                          );
                        },
                        child: const Text('Hapus'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.list), text: 'Data'),
              Tab(icon: Icon(Icons.bar_chart), text: 'Visualisasi'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Daftar Statistik (Reorderable)
            statsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Terjadi kesalahan:\n$err', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                      onPressed: () => ref.read(statsProvider.notifier).refresh(),
                    ),
                  ],
                ),
              ),
              data: (stats) => ReorderableListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: stats.length,
                onReorder: (oldIndex, newIndex) => ref.read(statsProvider.notifier).reorder(oldIndex, newIndex),
                itemBuilder: (context, index) => Card(
                  key: ValueKey(stats[index]),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.show_chart)),
                    title: Text(stats[index]),
                    trailing: const Icon(Icons.drag_handle),
                  ),
                ),
              ),
            ),
            // Tab 2: Visualisasi (Coming Soon)
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.insert_chart_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Visualisasi Grafik\nAkan Datang', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
