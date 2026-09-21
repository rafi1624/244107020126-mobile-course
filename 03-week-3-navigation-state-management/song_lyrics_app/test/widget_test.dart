import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:song_lyrics_app/main.dart';
import 'package:song_lyrics_app/pages/home_page.dart';
import 'package:song_lyrics_app/pages/lyrics_page.dart';

void main() {
  testWidgets('Routing dan Navigasi Dasar', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: SongLyricsApp()));
    
    // Verifikasi HomePage muncul
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('Bohemian Rhapsody'), findsOneWidget);

    // Tap pada lagu untuk navigasi ke LyricsPage
    await tester.tap(find.text('Bohemian Rhapsody'));
    await tester.pumpAndSettle(); // Tunggu animasi transisi rute selesai

    // Verifikasi sudah pindah ke halaman Lirik
    expect(find.byType(LyricsPage), findsOneWidget);
    expect(find.text('A Night at the Opera'), findsOneWidget);
  });
}
