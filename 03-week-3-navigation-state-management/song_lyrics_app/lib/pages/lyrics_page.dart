import 'package:flutter/material.dart';

class LyricsPage extends StatelessWidget {
  const LyricsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Scrollbar(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: const Text('Bohemian Rhapsody - Queen'),
              floating: true,
              pinned: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Opsi Lirik', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            ListTile(
                              leading: const Icon(Icons.share),
                              title: const Text('Bagikan'),
                              onTap: () => Navigator.pop(context),
                            ),
                            ListTile(
                              leading: const Icon(Icons.favorite_border),
                              title: const Text('Simpan ke Favorit'),
                              onTap: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 700;
                  return Padding(
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
                                flex: 2,
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
            ),
          ],
        ),
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
          SizedBox(
            height: 300,
            child: PageView(
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
                Image.network(
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e7/Queen_Bohemian_Rhapsody.jpg/300px-Queen_Bohemian_Rhapsody.jpg',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 300,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image, size: 80, color: Colors.grey),
                  ),
                ),
                Image.network(
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Queen_1976.jpg/800px-Queen_1976.jpg',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 300,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.group, size: 80, color: Colors.grey),
                  ),
                ),
              ],
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
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    ActionChip(
                      label: const Text('Rock'),
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Genre Rock dipilih!')),
                      ),
                    ),
                    ActionChip(
                      label: const Text('Progressive Rock'),
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Genre Progressive Rock dipilih!')),
                      ),
                    ),
                    ActionChip(
                      label: const Text('1975'),
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tahun 1975 dipilih!')),
                      ),
                    ),
                    ActionChip(
                      label: const Text('Classic'),
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Genre Classic dipilih!')),
                      ),
                    ),
                  ],
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
