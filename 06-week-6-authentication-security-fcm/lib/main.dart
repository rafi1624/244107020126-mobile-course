import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/auth_provider.dart';
import 'data/notification_provider.dart';
import 'messaging/push_service.dart';

// Channel notifikasi penting untuk Android
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'Notifikasi Penting Kampus',
  description: 'Channel ini digunakan untuk notifikasi penting perkuliahan.',
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? fcmToken;
  try {
    // 1. Inisialisasi Firebase
    await Firebase.initializeApp();

    // 2. Set background messaging handler
    registerBackgroundHandler();

    // 3. Minta izin notifikasi
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('Status izin notifikasi: ${settings.authorizationStatus}');

    // 4. Inisialisasi notifikasi lokal untuk foreground
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 5. Dapatkan FCM Token perangkat
    try {
      fcmToken = await messaging.getToken();
      debugPrint('FCM Token: $fcmToken');
    } catch (e) {
      debugPrint('Tidak dapat mengambil FCM token: $e');
    }
  } catch (e) {
    debugPrint('Firebase init bypassed/failed: $e');
  }

  // Siapkan container ProviderScope
  final container = ProviderContainer(
    overrides: [
      if (fcmToken != null)
        fcmTokenProvider.overrideWith((ref) => fcmToken),
    ],
  );

  // Tangani pesan saat aplikasi sedang terbuka (foreground)
  try {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      final android = message.notification?.android;

      // 1. Otomatis tambahkan notifikasi yang masuk ke dalam list notifikasi aplikasi
      container.read(notificationListProvider.notifier).addNotification(
            CampusNotification(
              id: message.messageId ??
                  DateTime.now().millisecondsSinceEpoch.toString(),
              title: notification?.title ?? 'Pengumuman Baru',
              body: notification?.body ?? '',
              receivedAt: DateTime.now(),
              route: message.data['route'],
              data: message.data,
            ),
          );

      // 2. Tampilkan banner sistem lokal
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          id: notification.hashCode,
          title: notification.title,
          body: notification.body,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: android.smallIcon ?? '@mipmap/ic_launcher',
            ),
          ),
        );
      }
    });
  } catch (_) {}

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Auth API & FCM Kampus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
