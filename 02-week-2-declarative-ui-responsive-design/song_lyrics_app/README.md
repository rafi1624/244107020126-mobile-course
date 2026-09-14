# Song Lyrics App

Ini adalah proyek tugas akhir untuk Week 2: Declarative UI & Responsive Design. Aplikasi ini menampilkan lirik lagu "Bohemian Rhapsody" - Queen dengan fitur *responsive layout* dan *dark mode toggle*.

## Fitur
- **Declarative UI**: Dibangun menggunakan widget dasar seperti `Container`, `Row`, `Column`, `Expanded`.
- **Responsive Layout**:
  - Tampilan 1 kolom untuk ukuran layar sempit (< 700px).
  - Tampilan 2 kolom untuk ukuran layar lebar (>= 700px) menggunakan `LayoutBuilder` dan `GridView`.
- **Tema Terang & Gelap**: Menggunakan `StatefulWidget` dan `CupertinoSwitch` untuk mengganti mode, dipadukan dengan `ThemeMode`.
- **Aksesibilitas**: Penggunaan widget `Semantics` pada tombol pengganti tema agar mudah dideteksi oleh *screen reader*.

---

## AI Prompt Challenge & Refleksi

### 1. Perbandingan Layout: GridView vs LayoutBuilder + Column
**Pertanyaan**: Bandingkan dua tata letak dashboard akademik untuk Flutter: versi `GridView` dan versi `LayoutBuilder` + `Column`. Jelaskan trade-off responsif dan aksesibilitasnya.
**Keputusan & Alasan**:
Pada proyek ini saya menggunakan kombinasi `LayoutBuilder` dan `GridView` untuk fleksibilitas maksimal.
- `GridView` memberikan *grid* otomatis dengan `crossAxisCount` yang dapat kita ubah secara dinamis berdasarkan parameter constraints dari `LayoutBuilder`.
- Menggunakan `Column` + `Row` dengan kalkulasi manual lebih rumit dan rentan terjadi *overflow* jika data tidak konsisten ukurannya, sedangkan `GridView` menyusunnya lebih rapi. Namun, untuk layar yang *sangat panjang*, struktur `Column` dengan `SingleChildScrollView` terkadang lebih mudah dikelola urutan pembacaan aksesibilitasnya dibandingkan Grid.

### 2. Penguatan Konsep: Kapan Expanded Menyebabkan Overflow
**Pertanyaan**: Jelaskan kapan penggunaan `Expanded` justru menyebabkan overflow di dalam `Row`, beri contoh kode yang gagal dan perbaikannya.
**Keputusan & Alasan**:
`Expanded` *seharusnya* mencegah *overflow* dengan memakan ruang tersisa. Namun, hal ini bisa gagal jika parent di atas `Row` tersebut tidak memiliki batas ukuran yang pasti, contohnya ketika `Row` yang berisi `Expanded` berada di dalam sebuah `SingleChildScrollView` horizontal (seperti `Row` di dalam `Row` yang bisa *scroll*).
*Perbaikan*: `Expanded` harus selalu berada di dalam Flex container (seperti `Row` atau `Column`) yang ukuran *cross/main axis*-nya terdefinisi. Dalam tugas ini, kita memastikannya berjalan dengan baik karena `Expanded` digunakan di dalam ukuran Card yang sudah fix di dalam Grid.

### 3. Verification & Aksesibilitas
**Pertanyaan**: Periksa kembali rekomendasi layout di atas: apakah tetap responsif di bawah 600px, apakah mengurangi aksesibilitas?
**Keputusan & Alasan**:
Rekomendasi yang dijalankan telah lolos verifikasi `flutter test`. Layout dengan `GridView` tetap berjalan sangat baik di bawah 600px (menjadi 1 kolom). Untuk aksesibilitas, kita menggunakan `Semantics` pada switch, serta hierarki `Theme.of(context)` agar kontras warna terang/gelap tetap memenuhi standar keterbacaan (*readability*).

---

## Testing
Gunakan perintah berikut untuk menjalankan *widget test*:
```bash
flutter test
```
Kedua pengujian layar lebar (2 kolom) dan layar sempit (1 kolom) akan berjalan sukses tanpa error.
