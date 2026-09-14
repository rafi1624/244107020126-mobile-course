import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:song_lyrics_app/main.dart';

void main() {
  testWidgets('Lyrics App satu kolom di layar sempit', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const SongLyricsApp());

    // Pada layar 400px, Album Cover dan Full Lyrics berada pada Column (1 kolom)
    // Lebar kartu FullLyricsCard harus hampir sama dengan lebar layar (kurang dari 400)
    final width = tester.getSize(find.byType(FullLyricsCard)).width;
    expect(width, lessThan(400));
  });

  testWidgets('Lyrics App dua kolom di layar lebar', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const SongLyricsApp());

    // Pada layar 1200px, Album (flex 1) dan Lyrics (flex 2) berada pada Row
    // Lebar kartu FullLyricsCard (flex 2) harus mengambil porsi besar (> 500)
    final lyricsWidth = tester.getSize(find.byType(FullLyricsCard)).width;
    expect(lyricsWidth, greaterThan(500));
  });
}
