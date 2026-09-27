import 'package:flutter/material.dart';

class LyricsPage extends StatefulWidget {
  const LyricsPage({super.key});

  @override
  State<LyricsPage> createState() => _LyricsPageState();
}

class _LyricsPageState extends State<LyricsPage> {
  bool _isPlaying = false;
  bool _isFavorite = true;
  double _playbackProgress = 0.35;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Scrollbar(
        thumbVisibility: true,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: isDark ? const Color(0xFF0D0F1D) : theme.colorScheme.primary,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.music_note, color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Jemari Mengubah Dunia',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? const Color(0xFFEC4899) : Colors.white,
                  ),
                  tooltip: 'Favorit',
                  onPressed: () {
                    setState(() => _isFavorite = !_isFavorite);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_isFavorite ? 'Disimpan ke lagu favorit!' : 'Dihapus dari favorit.'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onPressed: () => _showOptionsSheet(context),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 760;
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: isWide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                flex: 2,
                                child: AlbumCoverCard(
                                  isPlaying: _isPlaying,
                                  isFavorite: _isFavorite,
                                  playbackProgress: _playbackProgress,
                                  onPlayPause: () => setState(() => _isPlaying = !_isPlaying),
                                  onSliderChanged: (val) => setState(() => _playbackProgress = val),
                                ),
                              ),
                              const SizedBox(width: 24),
                              const Expanded(
                                flex: 3,
                                child: FullLyricsCard(),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              AlbumCoverCard(
                                isPlaying: _isPlaying,
                                isFavorite: _isFavorite,
                                playbackProgress: _playbackProgress,
                                onPlayPause: () => setState(() => _isPlaying = !_isPlaying),
                                onSliderChanged: (val) => setState(() => _playbackProgress = val),
                              ),
                              const SizedBox(height: 24),
                              const FullLyricsCard(),
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

  void _showOptionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16192B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Opsi Pemutaran',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.share_outlined, color: Color(0xFF8B5CF6)),
              title: const Text('Bagikan Lirik', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tautan lirik berhasil disalin!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.speed, color: Color(0xFF06B6D4)),
              title: const Text('Kecepatan Vokal (1.0x)', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.font_download_outlined, color: Color(0xFF10B981)),
              title: const Text('Ukuran Teks Lirik', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

class AlbumCoverCard extends StatelessWidget {
  const AlbumCoverCard({
    super.key,
    required this.isPlaying,
    required this.isFavorite,
    required this.playbackProgress,
    required this.onPlayPause,
    required this.onSliderChanged,
  });

  final bool isPlaying;
  final bool isFavorite;
  final double playbackProgress;
  final VoidCallback onPlayPause;
  final ValueChanged<double> onSliderChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shadowColor: const Color(0xFF7C3AED).withOpacity(0.25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Album Art with glowing badge
          SizedBox(
            height: 320,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: PageView(
                    children: [
                      // Slide 1: Tech & Coding Art
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF4C1D95), Color(0xFF1E1B4B), Color(0xFF0F172A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(28),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF8B5CF6).withOpacity(0.5),
                                      blurRadius: 30,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.code_rounded,
                                  size: 72,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                '< Jemari Mengubah Dunia />',
                                style: TextStyle(
                                  color: Color(0xFF38BDF8),
                                  fontSize: 16,
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Slide 2: Kids Coding Vibe
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF047857), Color(0xFF0F766E), Color(0xFF111827)],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.rocket_launch_rounded, size: 80, color: Color(0xFF34D399)),
                              SizedBox(height: 12),
                              Text(
                                'Kreator Masa Depan',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Ceria • Bersemangat • Kids Pop',
                                style: TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Badge "Kids Pop"
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFEC4899), width: 1.2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.bolt, color: Color(0xFFFBBF24), size: 14),
                        SizedBox(width: 4),
                        Text(
                          'KIDS POP',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Metadata & Tags
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Jemari Mengubah Dunia',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: const [
                    Icon(Icons.stars, color: Color(0xFFFBBF24), size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Irama: Ceria, Bersemangat & Penuh Energi',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildTag('Kids Pop', const Color(0xFFEC4899)),
                    _buildTag('Koding Ceria', const Color(0xFF8B5CF6)),
                    _buildTag('Edukasi', const Color(0xFF38BDF8)),
                    _buildTag('Masa Depan', const Color(0xFF10B981)),
                  ],
                ),

                const Divider(height: 32, color: Color(0xFF2E3352)),

                // Mini Audio Player Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('01:14', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                    Text('03:25', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                  ],
                ),
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 4,
                    activeTrackColor: const Color(0xFF8B5CF6),
                    inactiveTrackColor: const Color(0xFF2E3352),
                    thumbColor: const Color(0xFFC084FC),
                    overlayColor: const Color(0xFF8B5CF6).withOpacity(0.2),
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  ),
                  child: Slider(
                    value: playbackProgress,
                    onChanged: onSliderChanged,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shuffle, color: Color(0xFF94A3B8)),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 28),
                      onPressed: () {},
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(
                          isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                        onPressed: onPlayPause,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 28),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.repeat, color: Color(0xFF94A3B8)),
                      onPressed: () {},
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

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class FullLyricsCard extends StatelessWidget {
  const FullLyricsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shadowColor: const Color(0xFF0F172A).withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.lyrics, color: Color(0xFFA78BFA), size: 24),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Lirik Lengkap',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Jemari Mengubah Dunia • Kids Pop',
                      style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 36, color: Color(0xFF2E3352)),

            // Bait 1
            _buildSectionHeader('🌟 (Bait 1)', const Color(0xFF38BDF8)),
            const SizedBox(height: 8),
            _buildLyricsBlock(
              '''Mata binar lihat layar menyala
Banyak sekali ide di dalam kepala
Kita susun perintah baris per baris
Bikin game seru, gambar jadi manis
Jangan takut coba hal yang baru
Logika kita panduan yang jitu
Satu demi satu balok kita pasang
Masa depan cerah mulai membentang''',
            ),
            const SizedBox(height: 24),

            // Reff / Chorus (Highlighted)
            _buildChorusCard(
              '''Ayo kita koding sekarang juga!
Ciptakan dunia yang kita suka
Jangan menyerah kalau ada bug
Kita cari solusi, kita peluk erat
Koding itu seru, koding itu mudah
Jadi kreator masa depan indah
Klik dan ketik semua jadi nyata
Hebatnya kita koding bersama!''',
            ),
            const SizedBox(height: 24),

            // Bait 2
            _buildSectionHeader('💡 (Bait 2)', const Color(0xFF38BDF8)),
            const SizedBox(height: 8),
            _buildLyricsBlock(
              '''Jika program berhenti di tengah jalan
Itu bukan arti sebuah kegagalan
Mari cari di mana yang salah, kawan
Setiap error adalah pengalaman
Pakai perulangan agar lebih cepat
Bikin karakter melompat, melompat, lompat!
Logika berjalur if dan then yang seru
Semua jadi mudah dengan ilmu baru''',
            ),
            const SizedBox(height: 24),

            // Reff / Chorus (Highlighted)
            _buildChorusCard(
              '''Ayo kita koding sekarang juga!
Ciptakan dunia yang kita suka
Jangan menyerah kalau ada bug
Kita cari solusi, kita peluk erat
Koding itu seru, koding itu mudah
Jadi kreator masa depan indah
Klik dan ketik semua jadi nyata
Hebatnya kita koding bersama!''',
            ),
            const SizedBox(height: 24),

            // Jembatan / Bridge
            _buildBridgeCard(
              '''Dari nol dan satu kita buat karya
Membawa senyum untuk semua warga
Kalian adalah pembuat masa depan
Dengan jemari dan banyak harapan''',
            ),
            const SizedBox(height: 24),

            // Outro
            _buildOutroCard(
              '''Teruslah berkarya, teruslah mencoba
Koding itu seru, kita semua bisa!
Koding bersama, koding bersama…
Masa depan, kita yang punya!''',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLyricsBlock(String lyrics) {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Text(
        lyrics,
        style: const TextStyle(
          fontSize: 15,
          height: 1.8,
          color: Color(0xFFE2E8F0),
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildChorusCard(String lyrics) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF8B5CF6).withOpacity(0.18),
            const Color(0xFFEC4899).withOpacity(0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.flash_on_rounded, color: Color(0xFFFBBF24), size: 18),
              SizedBox(width: 6),
              Text(
                '🔥 (Reff / Chorus)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF472B6),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            lyrics,
            style: const TextStyle(
              fontSize: 15.5,
              height: 1.85,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBridgeCard(String lyrics) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0EA5E9).withOpacity(0.15),
            const Color(0xFF10B981).withOpacity(0.12),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF38BDF8).withOpacity(0.4),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.alt_route_rounded, color: Color(0xFF38BDF8), size: 18),
              SizedBox(width: 6),
              Text(
                '🌉 (Jembatan / Bridge)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF38BDF8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            lyrics,
            style: const TextStyle(
              fontSize: 15,
              height: 1.8,
              color: Color(0xFFE0F2FE),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutroCard(String lyrics) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B4B).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFA78BFA).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.flag_rounded, color: Color(0xFFA78BFA), size: 18),
              SizedBox(width: 6),
              Text(
                '🚀 (Outro)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFA78BFA),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            lyrics,
            style: const TextStyle(
              fontSize: 15,
              height: 1.8,
              color: Color(0xFFF1F5F9),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
