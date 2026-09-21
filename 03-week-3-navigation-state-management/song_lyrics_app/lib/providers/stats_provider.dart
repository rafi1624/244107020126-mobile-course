import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatsNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    return _fetchStats();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchStats());
  }

  Future<List<String>> _fetchStats() async {
    // Simulasi delay jaringan (2 detik)
    await Future.delayed(const Duration(seconds: 2));
    
    // Simulasi kegagalan sesekali (kira-kira 30% peluang gagal jika diklik berdasarkan detik)
    if (DateTime.now().second % 3 == 0) {
      throw Exception('Gagal terhubung ke server (Simulasi Error)');
    }
    
    return [
      'Total Streaming: 2.5 Miliar+',
      'Peringkat Billboard: #1',
      'Penghargaan: Grammy Hall of Fame',
      'Tahun Rilis: 1975'
    ];
  }
}

final statsProvider = AsyncNotifierProvider<StatsNotifier, List<String>>(StatsNotifier.new);
