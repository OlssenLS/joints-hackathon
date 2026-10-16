# LanSIAP

Prototype Flutter responsif untuk pendampingan lansia dan keluarga. Alurnya mengikuti sitemap dan user flow JOINTS: onboarding, dua peran, beranda pendamping, jadwal obat, pemantauan vital, alert, dokumen, laporan, dan mode lansia.

Visual LanSIAP memakai ilustrasi editorial orisinal, biru langit, teal gelap, dan aksen aprikot. Ilustrasi utama dibuat khusus untuk project ini dan tersimpan di `assets/images/care_family_editorial.png`.

## Menjalankan di VS Code

1. Pasang Flutter SDK serta extension **Flutter** dan **Dart**.
2. Buka folder ini (folder yang berisi `pubspec.yaml`).
3. Jalankan `flutter pub get`.
4. Pilih device di status bar VS Code.
5. Tekan `F5`, atau jalankan `flutter run -d chrome`.

## Struktur

- `lib/main.dart`: tema, onboarding, navigasi, jadwal, monitor, dokumen, laporan, dan mode lansia.
- `lib/creative_home.dart`: beranda pendamping dan interaksi tugas obat.
- `assets/`: ilustrasi dan font yang dipaketkan lokal.
- `android/`, `ios/`, `web/`: target platform Flutter.

Data vital dan akun saat ini adalah demo lokal. Tambah kegiatan dan konfirmasi obat aktif selama sesi aplikasi; data tersebut belum tersimpan setelah aplikasi ditutup. Panggilan telepon dan SOS saat ini berupa alur konfirmasi demo, belum terhubung ke perangkat atau layanan darurat.
