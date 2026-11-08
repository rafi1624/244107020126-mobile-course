/// Domain Entity: CampusNotification
/// Murni Dart untuk merepresentasikan notifikasi kampus.
class CampusNotification {
  const CampusNotification({
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

