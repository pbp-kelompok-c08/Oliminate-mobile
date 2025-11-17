# Oliminate
Nama Anggota :
1. Adjie M. Usman (2406423313)
2. Muhammad Azka Awliya (2406431510)
3. Abigail Namaratonggi Pasaribu (2406495773)
4. Felesia Junelus (2406354152)
5. Ahmad Wasis Shofiyulloh (2406362646)

## Link Figma
link : https://www.figma.com/design/3abL2ZjytH35pEF783gCFx/Oliminate-mobile?node-id=0-1&p=f&t=kh8IlqZyT6hccBoy-0

## Link 
belum ada

## Link Dataset
link : https://docs.google.com/spreadsheets/d/1zP3dnLrexYkfGR_FgusvkO_6FrLa1QWGLN8b299nvts/edit

## Tentang Produk

Oliminate adalah aplikasi yang dirancang untuk membantu event organizer dalam mengelola perlombaan secara efisien dan terintegrasi.  
Produk ini dibuat oleh Kelompok C08 dengan tujuan mempermudah pengelolaan event kompetisi, mulai dari penjadwalan, penjualan tiket, hingga pengalaman menonton secara langsung maupun daring.

##
User role : 
- Pengguna :
1. Bisa ngatur user profile
2. Bisa ngelihat schedule
3. Bisa beli tiket
4. Bisa beli merchandise
5. Bisa mereview
- Panitia : 
1. Bisa ngatur user profile
2. Bisa menambahkan schedule
3. Bisa menjual tiket
4. Bisa menjual merchandise
5. Bisa melihat review
## Tujuan

- Mempermudah panitia dalam mengatur jadwal pertandingan setiap tim.
- Menyediakan pengalaman pembelian tiket yang praktis dan modern.
- Menyediakan halaman utama (main page) yang berfungsi sebagai pusat informasi.

## Fitur Utama
Fitur Utama (sesuai PBI)
1. Scheduling (Adjie)

Panitia dapat membuat jadwal pertandingan dengan tanggal, jam, lokasi, dan cabang olahraga, serta menambahkan peserta/tim yang akan bertanding.

User dapat melihat jadwal dan daftar peserta yang bertanding secara real-time.

2. Ticketing (Felesia)

User dapat memilih event dan jumlah tiket yang ingin dibeli melalui sistem pembelian online.

Mendukung berbagai metode pembayaran (e-wallet, transfer, dan lainnya).

Setiap tiket memiliki kode QR unik yang dapat dipindai untuk verifikasi di pintu masuk.

Panitia dapat melakukan validasi tiket secara cepat melalui pemindaian QR Code.

User dapat melihat riwayat tiket yang telah dibeli sebelumnya.

3. Reviews & Rating (Abigail)

User dapat memberikan rating (bintang/angka) dan menulis review singkat terhadap event.

Sistem menampilkan rata-rata rating untuk setiap event agar user dapat menilai kualitasnya.

Panitia dapat melihat seluruh review dan umpan balik untuk evaluasi event berikutnya.

4. User Profile (Azka)

User dapat membuat dan memperbarui profil pribadi (nama, email, foto, fakultas/jurusan).

Menampilkan daftar lomba yang diikuti, tiket yang dimiliki, serta riwayat aktivitas user.

Sistem menyediakan fitur achievement/badge untuk menampilkan pencapaian user berdasarkan partisipasi atau kemenangan.

5. Merchandise (Wasis)

Menampilkan katalog merchandise resmi dengan foto, deskripsi, dan harga.

User dapat menambahkan barang ke keranjang dan melakukan checkout dengan mudah.

Sistem menyediakan pembayaran merchandise secara online.

Panitia dapat mengatur stok, harga, dan deskripsi produk melalui dashboard.

User dapat melihat riwayat pembelian merchandise sebelumnya.

6. Main Page (Azka)

Halaman utama menampilkan banner event utama, jadwal, dan berita terkini.

Menyediakan daftar cabang olahraga aktif dan highlight pertandingan.

Dilengkapi shortcut ke fitur utama seperti jadwal, tiket, review, merchandise, dan profil user.

Tersedia halaman About & Contact untuk mengenal panitia dan menghubungi mereka.

## Integrasi dengan website
Berikut adalah langkah-langkah yang akan dilakukan untuk mengintegrasikan aplikasi dengan server web:

1. Mengimplementasikan sebuah wrapper class dengan menggunakan library HTTP dan MAP untuk mendukung penggunaan cookie-based authentication pada aplikasi.
2. Mengimplementasikan REST API pada Django (views.py) dengan menggunakan JsonResponse atau Django JSON Serializer.
3. Mengimplementasikan desain front-end untuk aplikasi berdasarkan desain website yang sudah ada sebelumnya.
4. Melakukan integrasi antara front-end dengan back-end dengan menggunakan konsep asynchronous HTTP.