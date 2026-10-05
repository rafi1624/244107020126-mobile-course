import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/sync.dart';
import '../providers/note_providers.dart';
import '../providers/offline_providers.dart';
import '../widgets/note_form_dialog.dart';
import 'posts_page.dart';
import 'settings_page.dart';

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesProvider);
    final dirtyCountAsync = ref.watch(dirtyCountProvider);
    final offline = ref.watch(forceOfflineProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Offline'),
        actions: [
          IconButton(
            tooltip: offline ? 'Beralih ke Online' : 'Simulasi Offline',
            icon: Icon(offline ? Icons.cloud_off : Icons.cloud_done),
            onPressed: () => ref.read(forceOfflineProvider.notifier).toggle(),
          ),
          IconButton(
            tooltip: 'Posts (cache-first)',
            icon: const Icon(Icons.article_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PostsPage()),
            ),
          ),
          IconButton(
            tooltip: 'Sinkronkan',
            icon: const Icon(Icons.sync),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              try {
                final count = await ref.read(noteActionsProvider).sync();
                messenger.showSnackBar(SnackBar(
                  content: Text(count == 0
                      ? 'Semua catatan sudah tersinkron'
                      : '$count catatan berhasil disinkronkan'),
                ));
              } on OfflineException catch (e) {
                messenger.showSnackBar(SnackBar(content: Text(e.message)));
              }
            },
          ),
          IconButton(
            tooltip: 'Pengaturan',
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (offline)
            Container(
              width: double.infinity,
              color: Colors.orange.shade100,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: const Row(
                children: [
                  Icon(Icons.wifi_off, size: 20, color: Colors.deepOrange),
                  SizedBox(width: 8),
                  Text(
                    'Mode offline aktif (simulasi)',
                    style: TextStyle(color: Colors.black87),
                  ),
                ],
              ),
            ),
          dirtyCountAsync.maybeWhen(
            data: (count) => count > 0
                ? Container(
                    width: double.infinity,
                    color: Colors.amber.shade100,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Text(
                      '$count catatan belum tersinkron (dirty)',
                      style: TextStyle(
                        color: Colors.brown.shade800,
                        fontSize: 12,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
          Expanded(
            child: notesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _ErrorView(
                error: e,
                onRetry: () => ref.invalidate(notesProvider),
              ),
              data: (notes) {
                if (notes.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada catatan.\nTekan tombol + untuk menambahkan.',
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return ListTile(
                      title: Text(note.title),
                      subtitle: Text(
                        note.body.isEmpty ? '(Tidak ada isi)' : note.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (note.dirty)
                            const Tooltip(
                              message: 'Belum disinkronkan',
                              child: Icon(Icons.cloud_upload_outlined,
                                  color: Colors.orange),
                            ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => ref
                                .read(noteActionsProvider)
                                .delete(note.id!),
                          ),
                        ],
                      ),
                      onTap: () async {
                        final result = await showDialog<NoteFormResult>(
                          context: context,
                          builder: (_) => NoteFormDialog(initial: note),
                        );
                        if (result != null) {
                          ref.read(noteActionsProvider).update(
                                note.copyWith(
                                  title: result.title,
                                  body: result.body,
                                ),
                              );
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showDialog<NoteFormResult>(
            context: context,
            builder: (_) => const NoteFormDialog(),
          );
          if (result != null) {
            ref.read(noteActionsProvider).add(result.title, result.body);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Terjadi kesalahan: $error', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
