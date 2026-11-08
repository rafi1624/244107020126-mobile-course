import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/campus_notification.dart';
import '../../main.dart' show channel, flutterLocalNotificationsPlugin;
import '../providers/app_providers.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String? _apiTestResult;
  bool _isTestingApi = false;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _notifSectionKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _testProtectedApi() async {
    setState(() {
      _isTestingApi = true;
      _apiTestResult = null;
    });

    try {
      // Clean Architecture: Memanggil Domain UseCase, BUKAN memanggil Dio langsung dari Widget!
      final profile = await ref.read(getProfileUseCaseProvider).execute();
      if (mounted) {
        setState(() {
          _apiTestResult = 'Profil Diterima dari UseCase:\n'
              'ID: ${profile.id}\n'
              'Nama: ${profile.name}\n'
              'Email: ${profile.email}\n'
              'Data: ${profile.rawAttributes}';
          _isTestingApi = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _apiTestResult = 'Gagal memanggil API: $e';
          _isTestingApi = false;
        });
      }
    }
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text(
          'Token di secure storage akan dihapus dan Anda akan dialihkan ke halaman login.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authStateProvider.notifier).logout();
    }
  }

  /// Menampilkan dialog detail notifikasi dan otomatis menghapusnya dari daftar (sudah dibaca)
  Future<void> _readAndDismissNotification(CampusNotification notif) async {
    final shouldOpenRoute = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.mark_email_read_rounded, color: Colors.indigo),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                notif.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notif.body,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 12),
            Text(
              'Diterima: ${_formatDateTime(notif.receivedAt)}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            if (notif.route != null && notif.route!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Rute: ${notif.route}',
                  style: const TextStyle(fontSize: 11, color: Colors.indigo),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Tutup (Selesai Dibaca)'),
          ),
          if (notif.route != null && notif.route!.isNotEmpty)
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Buka Rute'),
            ),
        ],
      ),
    );

    // Otomatis hapus notifikasi dari daftar karena sudah dibaca
    ref.read(notificationListProvider.notifier).markAsReadAndRemove(notif.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Notifikasi "${notif.title}" telah dibaca dan menghilang.'),
          backgroundColor: Colors.teal,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    if (shouldOpenRoute == true && notif.route != null && notif.route!.isNotEmpty) {
      if (mounted) {
        context.push(notif.route!);
      }
    }
  }

  /// Membuat simulasi notifikasi masuk untuk pengujian langsung
  void _simulateIncomingNotification() {
    final now = DateTime.now();
    final dummyTitles = [
      'Tugas Pemrograman Mobile Dinilai',
      'Pengumuman Beasiswa Kampus',
      'Pemeliharaan Server Akademik',
      'Jadwal Kuliah Pengganti',
    ];
    final dummyBodies = [
      'Nilai tugas praktikum Anda sudah diunggah oleh dosen pengampu.',
      'Pendaftaran beasiswa semester ganjil dibuka hingga akhir bulan.',
      'Sistem informasi akademik akan offline selama 30 menit malam ini.',
      'Kuliah pengganti Pemrograman Mobile akan dilaksanakan hari Jumat pukul 09.00.',
    ];
    final index = now.second % dummyTitles.length;

    final newNotif = CampusNotification(
      id: 'sim-${now.millisecondsSinceEpoch}',
      title: dummyTitles[index],
      body: dummyBodies[index],
      receivedAt: now,
      route: '/pengumuman/${now.second}',
    );

    ref.read(notificationListProvider.notifier).addNotification(newNotif);

    // Mainkan suara notifikasi sistem via local notification
    flutterLocalNotificationsPlugin.show(
      id: now.millisecondsSinceEpoch ~/ 1000,
      title: newNotif.title,
      body: newNotif.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Notifikasi baru diterima: "${newNotif.title}"'),
          backgroundColor: Colors.indigo,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  String _formatDateTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _scrollToNotifications() {
    Scrollable.ensureVisible(
      _notifSectionKey.currentContext!,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final fcmToken = ref.watch(fcmTokenProvider);
    final notifications = ref.watch(notificationListProvider);
    final tokenInfoAsync = ref.watch(tokenInfoProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Dashboard Mahasiswa (Clean Arch)'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          // Bell Icon with Unread Count Badge
          IconButton(
            tooltip: 'Notifikasi Kampus',
            icon: Badge(
              isLabelVisible: notifications.isNotEmpty,
              label: Text(
                '${notifications.length}',
                style: const TextStyle(fontSize: 10),
              ),
              child: const Icon(Icons.notifications_outlined),
            ),
            onPressed: _scrollToNotifications,
          ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout_rounded, color: Colors.red),
            onPressed: _confirmLogout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(tokenInfoProvider),
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16.0),
          children: [
            // User Profile Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.indigo.shade100,
                      child: Icon(
                        Icons.person,
                        size: 36,
                        color: Colors.indigo.shade800,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: tokenInfoAsync.when(
                        data: (info) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              info.name ?? 'Mahasiswa',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              info.email ?? 'email@kampus.id',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.green.shade200),
                              ),
                              child: const Text(
                                'Status: Clean Architecture Domain Bound',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        loading: () => const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                        error: (_, _) => const Text('Gagal memuat profil'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ==========================================
            // CARD DAFTAR NOTIFIKASI KAMPUS (LIST)
            // ==========================================
            Card(
              key: _notifSectionKey,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.mark_chat_unread_rounded, color: Colors.indigo),
                            const SizedBox(width: 8),
                            const Text(
                              'Daftar Notifikasi',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: notifications.isNotEmpty
                                    ? Colors.red.shade100
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${notifications.length}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: notifications.isNotEmpty
                                  ? Colors.red.shade900
                                  : Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          onPressed: _simulateIncomingNotification,
                          icon: const Icon(Icons.add_alert_rounded, size: 16),
                          label: const Text(
                            '+ Notif Masuk',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ketuk atau geser notifikasi untuk membacanya. Menggunakan Domain Entity CampusNotification.',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                    const Divider(height: 20),

                    // Tampilan List Notifikasi
                    if (notifications.isEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.mark_email_read_outlined,
                                size: 48,
                                color: Colors.green.shade400,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Semua notifikasi telah dibaca!',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Daftar kosong karena notifikasi menghilang saat dibaca.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                onPressed: _simulateIncomingNotification,
                                icon: const Icon(Icons.refresh, size: 16),
                                label: const Text('Buat Contoh Notifikasi'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: notifications.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final notif = notifications[index];
                          return Dismissible(
                            key: ValueKey(notif.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.teal,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(Icons.check, color: Colors.white),
                                  SizedBox(width: 6),
                                  Text(
                                    'Sudah Dibaca',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onDismissed: (_) {
                              ref
                                  .read(notificationListProvider.notifier)
                                  .markAsReadAndRemove(notif.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Notifikasi "${notif.title}" dibaca dan menghilang.',
                                  ),
                                  backgroundColor: Colors.teal,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            child: Material(
                              color: Colors.indigo.shade50.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => _readAndDismissNotification(notif),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.indigo.shade100,
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.indigo.shade100,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.notifications_active_rounded,
                                          size: 18,
                                          color: Colors.indigo.shade900,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    notif.title,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  _formatDateTime(notif.receivedAt),
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              notif.body,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade800,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                if (notif.route != null)
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.indigo.shade50,
                                                      borderRadius:
                                                          BorderRadius.circular(4),
                                                    ),
                                                    child: Text(
                                                      notif.route!,
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color:
                                                            Colors.indigo.shade800,
                                                      ),
                                                    ),
                                                  )
                                                else
                                                  const SizedBox(),
                                                const Text(
                                                  'Ketuk untuk baca ➔',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.indigo,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () {
                            ref
                                .read(notificationListProvider.notifier)
                                .clearAll();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Semua notifikasi telah dibaca.'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.done_all, size: 16),
                          label: const Text(
                            'Tandai Semua Sudah Dibaca',
                            style: TextStyle(fontSize: 11),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Token Security Storage Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.security, color: Colors.indigo),
                        SizedBox(width: 8),
                        Text(
                          'Keamanan Token (Clean Architecture: Data Layer)',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    tokenInfoAsync.when(
                      data: (info) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Access Token (Melalui TokenRepository Abstraksi):',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: SelectableText(
                              info.accessToken ?? 'Belum ada access token',
                              style: const TextStyle(
                                fontSize: 11,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Refresh Token:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: SelectableText(
                              info.refreshToken ?? 'Belum ada refresh token',
                              style: const TextStyle(
                                fontSize: 11,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                      ),
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (err, _) => Text('Error loading tokens: $err'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Test Dio Interceptor via UseCase (NOT direct Dio in Widget!)
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.layers_rounded, color: Colors.teal),
                        SizedBox(width: 8),
                        Text(
                          'Uji Interaksi Melalui Domain UseCase',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Widget memanggil GetProfileUseCase. UseCase meminta data ke AuthRepositoryImpl yang menyertakan Bearer token secara transparan. Presentation bebas dari impor Dio.',
                      style: TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _isTestingApi ? null : _testProtectedApi,
                      icon: _isTestingApi
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send_rounded),
                      label: const Text('Eksekusi GetProfileUseCase'),
                    ),
                    if (_apiTestResult != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.teal.shade200),
                        ),
                        child: SelectableText(
                          _apiTestResult!,
                          style: const TextStyle(
                            fontSize: 11,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Firebase Cloud Messaging (FCM) Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.notifications_active, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'Firebase Cloud Messaging (FCM)',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    const Text(
                      'Perangkat terdaftar pada topik: pengumuman-kampus',
                      style: TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Device FCM Token:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        if (fcmToken != null)
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            icon: const Icon(Icons.copy, size: 14),
                            label: const Text('Salin', style: TextStyle(fontSize: 12)),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: fcmToken));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('FCM Token berhasil disalin!'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectableText(
                        fcmToken ?? 'Menunggu inisialisasi FCM...',
                        style: const TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

