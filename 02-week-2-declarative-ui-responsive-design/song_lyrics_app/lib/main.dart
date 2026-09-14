import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() => runApp(const SongLyricsApp());

class SongLyricsApp extends StatefulWidget {
  const SongLyricsApp({super.key});

  @override
  State<SongLyricsApp> createState() => _SongLyricsAppState();
}

class _SongLyricsAppState extends State<SongLyricsApp> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Song Lyrics',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.deepPurple,
      ),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: LyricsPage(
        isDark: isDark,
        onDarkChanged: (value) => setState(() => isDark = value),
      ),
    );
  }
}

class LyricsPage extends StatelessWidget {
  const LyricsPage({
    required this.isDark,
    required this.onDarkChanged,
    super.key,
  });

  final bool isDark;
  final ValueChanged<bool> onDarkChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bohemian Rhapsody - Queen'),
        actions: [
          Row(
            children: [
              Icon(isDark ? Icons.dark_mode : Icons.light_mode),
              const SizedBox(width: 4),
              Semantics(
                label: 'Toggle Dark Mode',
                child: CupertinoSwitch(
                  value: isDark,
                  onChanged: onDarkChanged,
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 700;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Expanded(
                        flex: 1,
                        child: AlbumCoverCard(),
                      ),
                      SizedBox(width: 24),
                      Expanded(
                        flex: 2, // Lirik butuh tempat lebih luas
                        child: FullLyricsCard(),
                      ),
                    ],
                  )
                : Column(
                    children: const [
                      AlbumCoverCard(),
                      SizedBox(height: 24),
                      FullLyricsCard(),
                    ],
                  ),
          );
        },
      ),
    );
  }
}

class AlbumCoverCard extends StatelessWidget {
  const AlbumCoverCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Image.network(
            'https://upload.wikimedia.org/wikipedia/en/9/9f/Bohemian_Rhapsody.png',
            fit: BoxFit.cover,
            width: double.infinity,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 300,
              color: Colors.grey.shade300,
              child: const Icon(Icons.music_note, size: 80, color: Colors.grey),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  'A Night at the Opera',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Queen (1975)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FullLyricsCard extends StatelessWidget {
  const FullLyricsCard({super.key});

  @override
  Widget build(BuildContext context) {
    const String fullLyrics = '''
Is this the real life?
Is this just fantasy?
Caught in a landslide,
No escape from reality.

Open your eyes,
Look up to the skies and see,
I'm just a poor boy, I need no sympathy,
Because I'm easy come, easy go,
Little high, little low.

Mama, just killed a man,
Put a gun against his head,
Pulled my trigger, now he's dead.
Mama, life had just begun,
But now I've gone and thrown it all away.

Mama, ooh,
Didn't mean to make you cry,
If I'm not back again this time tomorrow,
Carry on, carry on as if nothing really matters.

Too late, my time has come,
Sends shivers down my spine,
Body's aching all the time.
Goodbye, everybody, I've got to go,
Gotta leave you all behind and face the truth.

Nothing really matters,
Anyone can see,
Nothing really matters,
Nothing really matters to me.
''';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lyrics, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Full Lyrics',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
            const Divider(height: 32),
            Text(
              fullLyrics,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
