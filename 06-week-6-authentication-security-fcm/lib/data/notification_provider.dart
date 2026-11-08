import 'package:flutter_riverpod/flutter_riverpod.dart';

class CampusNotification {
  CampusNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.receivedAt,
    this.route,
    this.data = const {},
  });

  final String id;
  final String title;
  final String body;
  final DateTime receivedAt;
  final String? route;
  final Map<String, dynamic> data;
}

class NotificationNotifier extends Notifier<List<CampusNotification>> {
  @override
  List<CampusNotification> build() {
    // Daftar notifikasi awal untuk demo
    return [
      CampusNotification(
        id: 'notif-1',
        title: 'Materi Week 6 Terbit',
        body: 'Materi modul Authentication, Security & FCM sudah diunggah ke sistem.',
        receivedAt: DateTime.now().subtract(const Duration(minutes: 5)),
        route: '/pengumuman/week-6',
      ),
      CampusNotification(
        id: 'notif-2',
        title: 'Pengingat Presensi Kuliah',
        body: 'Silakan isi presensi kehadiran untuk perkuliahan hari ini.',
        receivedAt: DateTime.now().subtract(const Duration(minutes: 25)),
        route: '/pengumuman/presensi',
      ),
      CampusNotification(
        id: 'notif-3',
        title: 'Pengumuman Akademik',
        body: 'Jadwal Ujian Tengah Semester (UTS) telah dirilis.',
        receivedAt: DateTime.now().subtract(const Duration(hours: 2)),
        route: '/pengumuman/uts',
      ),
    ];
  }

  /// Tambah notifikasi baru ke daftar (di paling atas)
  void addNotification(CampusNotification notification) {
    state = [notification, ...state];
  }

  /// Ketika dibaca / diklik, notifikasi langsung menghilang dari list
  void markAsReadAndRemove(String id) {
    state = state.where((item) => item.id != id).toList();
  }

  /// Bersihkan semua notifikasi
  void clearAll() {
    state = [];
  }
}

final notificationListProvider =
    NotifierProvider<NotificationNotifier, List<CampusNotification>>(
  NotificationNotifier.new,
);
