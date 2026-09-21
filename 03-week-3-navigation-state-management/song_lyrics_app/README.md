# Song Lyrics App - Week 3 (Navigation & State Management)

Ini adalah kelanjutan proyek aplikasi *Song Lyrics* untuk Week 3. Proyek ini mengintegrasikan navigasi deklaratif menggunakan **GoRouter** dan *state management* menggunakan **Riverpod**.

## Fitur Baru (Week 3)
1. **Multi-Page Navigation (GoRouter)**
   - `/` (Home): Menampilkan daftar menu (Lirik Lagu & Statistik).
   - `/lyrics` (Detail Lirik): Halaman responsif dari minggu ke-2.
   - `/stats` (Statistik Async): Halaman simulasi data asinkron.
2. **State Management (Riverpod)**
   - `ProviderScope` membungkus root aplikasi (`main.dart`).
   - `themeProvider` (`NotifierProvider`): Digunakan untuk mengatur mode terang/gelap secara terpusat tanpa bergantung pada `StatefulWidget` lokal.
3. **AsyncValue Handling**
   - `statsProvider` (`AsyncNotifierProvider`): Mengambil data metrik lagu palsu dengan *delay* 2 detik dan peluang kegagalan (simulasi *error*).
   - UI `StatsPage` menangani state `.when(loading, error, data)` sesuai dengan kaidah UI yang aman.

---

## AI Challenge & Verification Checklist

**Skenario Prompt:**
Minta AI membuat halaman `StatsPage` dengan `AsyncNotifierProvider` untuk simulasi loading statistik (dengan peluang error), lalu verifikasi strukturnya.

**Checklist Verifikasi:**
- [x] **Apakah state diubah secara immutable?** Ya, `AsyncNotifier` mengembalikan `Future<List<String>>` baru di method `_fetchStats()` dan menggunakan `AsyncValue.guard()` untuk mengubah state tanpa mutasi objek lama.
- [x] **Apakah ref.watch hanya dipakai di dalam build?** Ya, di `StatsPage` baris 11, `ref.watch` dipanggil di dalam fungsi `build`, dan pada tombol retry, saya pastikan menggunakan `ref.read` untuk memanggil method `refresh()`.
- [x] **Apakah ketiga state AsyncValue ditangani?** Ya, `statsAsync.when(...)` memberikan balasan UI untuk kondisi `loading` (CircularProgressIndicator), `error` (Pesan dan tombol Coba Lagi), dan `data` (ListView).
- [x] **Apakah provider memakai versi Riverpod terbaru?** Ya, menghindari pemakaian `StateNotifier` yang usang dan sepenuhnya memakai kelas `AsyncNotifier` (Riverpod 2.x/3.x).
- [x] **Apakah hasil AI lolos tanpa warning?** Ya, `flutter analyze` tidak menemukan masalah dan `flutter test` lulus verifikasi perpindahan *route*.

## Refleksi
- **Kapan `setState` masih cukup, dan kapan state harus naik ke Riverpod?**
  `setState` cukup untuk animasi UI yang murni lokal (seperti teks di-*expand*). State harus naik ke Riverpod (seperti mode Gelap di proyek ini) ketika datanya dibutuhkan di lebih dari satu halaman, atau untuk memisahkan *business logic* dari UI agar lebih mudah di-*test*.
- **Apa perbedaan `context.go` dan `context.push`?**
  `context.go` mengganti seluruh tumpukan navigasi sesuai dengan rute URL (cocok untuk tab atau root menu), sementara `context.push` hanya menumpuk halaman baru di atas halaman saat ini (cocok untuk *drilling* / masuk lebih dalam agar tombol Back sistem berfungsi dengan natural).
- **Bagaimana `AsyncValue` mencegah bug?**
  Pendekatan konvensional dengan banyak `bool` (seperti `isLoading` dan `hasError`) rentan mengalami status ganda atau terlewat. `AsyncValue` dengan metode `.when()` *memaksa* *developer* menangani 3 state tersebut secara mutlak, sehingga UI tidak mungkin *blank* jika terjadi koneksi putus.

## Menjalankan Aplikasi
```bash
flutter run
```
Untuk menguji UI Error di halaman Statistik, cobalah klik "Coba Lagi" berkali-kali, karena ada peluang 30% akan disimulasikan sebagai kegagalan berdasarkan genap-ganjil detik.
