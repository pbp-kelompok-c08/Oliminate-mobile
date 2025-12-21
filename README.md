# Oliminate

## Anggota Kelompok
1. Adjie M. Usman (2406423313)
2. Muhammad Azka Awliya (2406431510)
3. Abigail Namaratonggi Pasaribu (2406495773)
4. Felesia Junelus (2406354152)
5. Ahmad Wasis Shofiyulloh (2406362646)

## Tautan Desain
**Figma:** [Desain Oliminate Mobile](https://www.figma.com/design/3abL2ZjytH35pEF783gCFx/Oliminate-mobile?node-id=0-1&p=f&t=kh8IlqZyT6hccBoy-0)

## Tautan Aplikasi
[![Build Status](https://app.bitrise.io/app/ce11d9f1-862a-4cdd-a1e8-2bf9117c6e27/status.svg?token=fI3b0-u_ry1JLn15RZLE0g&branch=main)](https://app.bitrise.io/app/ce11d9f1-862a-4cdd-a1e8-2bf9117c6e27)
Download Bitrise : https://app.bitrise.io/app/ce11d9f1-862a-4cdd-a1e8-2bf9117c6e27/installable-artifacts/72a7d0139dd44580/public-install-page/432f9d331c4ba26e75d2d82f0d14438f

Download github : https://github.com/pbp-kelompok-c08/Oliminate-mobile/releases/latest/download/oliminate.apk

## Tautan Dataset
**Google Sheets:** [Dataset Oliminate](https://docs.google.com/spreadsheets/d/1zP3dnLrexYkfGR_FgusvkO_6FrLa1QWGLN8b299nvts/edit)

---

## Tentang Produk

Oliminate adalah aplikasi *event management* yang dirancang khusus untuk membantu penyelenggara kompetisi olahraga. Aplikasi ini menyediakan solusi lengkap mulai dari pembuatan jadwal pertandingan, penjualan tiket secara *online*, pengelolaan *merchandise* resmi, hingga sistem ulasan dan penilaian acara. Produk ini dikembangkan oleh Kelompok C08 sebagai proyek tugas kelompok mata kuliah Pemrograman Berbasis Platform (PBP) Fakultas Ilmu Komputer Universitas Indonesia.

---

## Peran Pengguna

### Pengguna
1. Dapat mengatur profil pengguna.
2. Dapat melihat jadwal pertandingan.
3. Dapat membeli tiket.
4. Dapat membeli suvenir.
5. Dapat memberikan ulasan.

### Panitia
1. Dapat mengatur profil pengguna.
2. Dapat menambahkan jadwal pertandingan.
3. Dapat menjual tiket.
4. Dapat menjual suvenir.
5. Dapat melihat ulasan.

---

## Tujuan Aplikasi

- Mempermudah panitia dalam membuat dan mengelola jadwal pertandingan (*scheduling*).
- Menyediakan sistem pembelian tiket yang praktis dengan verifikasi kode QR.
- Memfasilitasi penjualan *merchandise* resmi kompetisi secara *online*.
- Memberikan wadah bagi pengguna untuk memberikan ulasan dan penilaian terhadap acara.
- Menyediakan halaman utama yang informatif sebagai pusat navigasi aplikasi.

---

## Fitur Utama

### 1. *Scheduling* — Penjadwalan (Adjie)

- Panitia dapat membuat jadwal pertandingan dengan informasi tanggal, waktu, lokasi, dan cabang olahraga.
- Panitia dapat menandai status pertandingan (*upcoming*, *completed*, atau *reviewable*).
- Pengguna dapat melihat daftar jadwal pertandingan dan melakukan *filter* berdasarkan status.
- Tersedia halaman detail untuk melihat informasi lengkap setiap pertandingan.

### 2. *Ticketing* — Pembelian Tiket (Felesia)

- Pengguna dapat membeli tiket pertandingan melalui sistem pembelian *online*.
- Mendukung berbagai metode pembayaran.
- Setiap tiket memiliki kode QR unik untuk verifikasi di pintu masuk.
- Panitia dapat memindai kode QR untuk validasi tiket pengguna.
- Pengguna dapat melihat riwayat tiket dan status pembayaran (*paid* atau *unpaid*).
- Panitia dapat mengatur harga tiket untuk setiap jadwal pertandingan.

### 3. *Review* — Ulasan dan Penilaian (Abigail)

- Pengguna dapat memberikan penilaian bintang (1-5) dan menulis ulasan terhadap pertandingan yang sudah selesai.
- Sistem menampilkan rata-rata penilaian dan jumlah ulasan untuk setiap acara.
- Pengguna dapat melihat daftar *event* berdasarkan popularitas ulasan.
- Panitia dapat melihat seluruh ulasan sebagai bahan evaluasi.

### 4. *User Profile* — Profil Pengguna (Azka)

- Pengguna dapat melihat dan mengubah profil pribadi (nama pengguna, nama depan, nama belakang, surel, dan fakultas).
- Tersedia tombol *logout* untuk keluar dari akun.
- Tampilan profil yang modern dengan desain *card-based*.

### 5. *Merchandise* — Penjualan Suvenir (Wasis)

- Menampilkan katalog *merchandise* resmi dengan foto, deskripsi, harga, dan stok.
- Pengguna dapat menambahkan barang ke keranjang (*cart*) dan melakukan *checkout*.
- Panitia dapat menambah, mengubah, dan menghapus produk melalui *form* khusus.
- Sistem menampilkan riwayat pembelian dengan kode QR sebagai bukti transaksi.

### 6. *Main Page* — Halaman Utama (Azka)

- Menampilkan *hero section* dengan ucapan selamat datang dan informasi singkat aplikasi.
- Menyediakan *preview* jadwal pertandingan terbaru.
- Dilengkapi tombol pintasan ke fitur Tiket dan Ulasan.

---

## Integrasi dengan Situs Web

Aplikasi *mobile* Oliminate terintegrasi dengan *backend* Django yang sudah di-*deploy* di server. Berikut adalah langkah-langkah yang dilakukan untuk mengintegrasikan aplikasi:

1. Mengimplementasikan *wrapper class* pada `AuthRepository` dengan menggunakan pustaka `http` untuk menangani autentikasi berbasis *cookie* dan *session*.
2. Mengimplementasikan *REST API* pada Django dengan *endpoint* JSON untuk setiap fitur (*scheduling*, *ticketing*, *merchandise*, *review*, dan *user profile*).
3. Mengimplementasikan desain *frontend* Flutter berdasarkan desain situs web yang sudah ada dengan konsistensi warna dan tata letak.
4. Melakukan integrasi *frontend* dengan *backend* menggunakan konsep *asynchronous HTTP request* dengan `Future` dan `async/await`.