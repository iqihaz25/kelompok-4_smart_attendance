# ARSITEKTUR

<img width="1600" height="1538" alt="image" src="https://github.com/user-attachments/assets/218f695d-f19f-4443-9dc4-38868d4c19c7" />
1. INNER CORE: DOMAIN LAYER (Lapisan Inti Dalam)Domain Layer berada di posisi paling dalam (Inner Core) dan bertugas sebagai pusat dari seluruh aturan bisnis inti aplikasi. Lapisan ini sangat murni dan tidak akan berubah meskipun Anda mengganti jenis database atau framework UI.  Di dalam diagram, lapisan ini memuat dua komponen utama:  Entities: Merupakan objek data murni konseptual dari aplikasi. Contoh konkretnya adalah class User (menyimpan data profil karyawan) dan AttendanceRecord (struktur data rekapan absensi).  Use Cases: Berisi fungsi atau alur tindakan spesifik yang dapat dilakukan oleh pengguna. Di sini terdapat DoClockIn (logika untuk melakukan absen masuk) dan ValidateLocation (logika untuk memvalidasi posisi perimeter koordinat karyawan). Lapisan ini hanya berisi instruksi bisnis abstrak murni.  
2. OUTER LAYERS: DATA LAYER (Lapisan Infrastruktur Data)Data Layer berada di lapisan luar (Outer Layers) yang bertanggung jawab atas pemrosesan data, operasi jaringan, serta integrasi komponen hardware perangkat.  Sesuai petunjuk panah "Implements / Mengalir ke Dalam", lapisan ini bertugas mengimplementasikan kontrak atau repository interface yang diminta oleh Domain Layer. Di sinilah tempat terjadinya interaksi dengan library eksternal:  Firestore API: Menangani proses Create, Read, Update, Delete (CRUD) data absensi dan izin langsung ke cloud database Firebase Firestore.  Geolocator (GPS): Mengambil data koordinat lintang (latitude) dan bujur (longitude) dari perangkat keras GPS smartphone secara real-time untuk validasi geofencing.  ML Kit SDK: Memanggil fungsi Machine Learning lokal (on-device) milik Google untuk memproses pemindaian wajah (Face Detection) dan verifikasi keaktifan wajah (Liveness Check) saat selfie camera terbuka.  
3. OUTER LAYERS: PRESENTATION LAYER (Lapisan Antarmuka)Presentation Layer berfokus sepenuhnya pada segala sesuatu yang berkaitan dengan apa yang dilihat dan berinteraksi langsung dengan pengguna di layar smartphone mereka.  Sesuai petunjuk panah "Observes & Calls / Mengalir ke Dalam", lapisan ini bertugas mengomunikasikan aksi klik atau input dari pengguna untuk memanggil Use Cases yang berada di Domain Layer. Lapisan ini terdiri dari:  UI Components (DashboardScreen): Merupakan kumpulan widget tampilan antarmuka (seperti halaman tombol absen, preview kamera, dan tata letak menu).  State Management (Provider State): Bertindak sebagai pengontrol logika tampilan (Controller/ViewModel). Provider bertugas memegang status status aplikasi (seperti indikator loading saat memproses GPS) dan memicu render ulang UI secara efisien hanya pada bagian yang membutuhkan pembaruan data.  Mengapa Desain Arsitektur Ini Sangat Kuat?Dengan struktur seperti ini, kode aplikasi Anda menjadi sangat rapi dan memiliki tingkat pemisahan tanggung jawab yang tinggi (Loose Coupling). Jika suatu hari Anda ingin mengganti database dari Firebase Firestore ke database SQL lokal, atau mengubah state management dari Provider ke Riverpod, Anda hanya perlu merombak kode di bagian Outer Layers saja, tanpa perlu menyentuh atau merusak logika bisnis utama absensi yang ada di dalam Domain Layer. 
## ER Diagram
<img width="1600" height="924" alt="image" src="https://github.com/user-attachments/assets/e26c7e6e-9e78-4d0c-bc93-036ae6ae54b9" />
1. Penjelasan Entitas (Koleksi Database)
A. Entitas users (Data Master Karyawan)
Entitas ini berfungsi sebagai tabel master untuk menyimpan profil dan informasi identitas digital dari setiap karyawan maupun admin.

user_id (PK - Primary Key): Berupa string unik yang didapatkan langsung dari UID Firebase Authentication saat pengguna mendaftar atau masuk log pertama kali.

nik: String Nomor Induk Karyawan untuk pencatatan internal pabrik.

employee_name: Nama lengkap karyawan.

department: Divisi atau unit kerja karyawan (misal: Produksi A, QC, Logistik).

role: Hak akses pengguna dalam aplikasi, dibedakan menjadi USER (Karyawan) atau ADMIN (HRD).

face_embedding: String hasil enkripsi kode matematika vektor wajah yang diekstrak oleh ML Kit SDK lokal untuk digunakan sebagai pencocokan biometrik.

B. Entitas attendance_logs (Catatan Absensi)
Entitas ini menyimpan data log riwayat kehadiran harian yang dikirim oleh perangkat karyawan.

id (PK): ID unik dokumen yang di-generate secara otomatis oleh Firebase Firestore.

userId (FK - Foreign Key): Kunci tamu yang mereferensikan field user_id dari entitas users, memastikan catatan absen ini milik karyawan yang tepat.

status: Status kehadiran yang bernilai antara Tepat Waktu, Terlambat, atau Dicurigai (jika terkena flag sistem anti-fraud).

locationCoords: Koordinat spasial (Latitude, Longitude) posisi perangkat saat melakukan clock-in atau clock-out.

time (Timestamp): Catatan waktu riil server saat absensi dikirim.

anomalyReason: Teks keterangan yang otomatis terisi jika status absensi divonis Dicurigai (misal: "Terdeteksi Mock GPS" atau "Wajah tidak cocok").

C. Entitas leave_requests (Pengajuan Izin / Cuti)
Entitas ini memuat berkas digital ketika karyawan mengajukan permohonan untuk tidak hadir kerja.

request_id (PK): ID pengajuan unik yang di-generate otomatis oleh sistem.

user_id (FK): Kunci tamu yang menghubungkan dokumen izin ini ke pemilik akun di entitas users.

leave_type: Kategori permohonan, dibatasi pada pilihan Sakit, Cuti, atau Izin.

status: Kondisi persetujuan dari tim HRD, bergerak dari PENDING, APPROVED, hingga REJECTED.

start_date & end_date (Timestamp): Rentang tanggal mulai dan berakhirnya masa izin kerja.

attachment_url: Tautan URL publik file gambar (seperti foto surat keterangan dokter) yang diunggah ke Firebase Storage.

2. Penjelasan Relasi Antar-Entitas (Hubungan Data)
Hubungan antartabel pada diagram  menggunakan notasi Crow's Foot untuk mendefinisikan kardinalitas relasi:

1. Hubungan users dengan attendance_logs (has many)
Kardinalitas: One-to-Many (||--o{)

Penjelasan: Satu karyawan (users) dapat memiliki banyak catatan log kehadiran (attendance_logs) seiring berjalannya hari kerja. Sebaliknya, satu dokumen log absensi tertentu hanya dapat dimiliki oleh tepat satu orang karyawan saja melalui validasi userId (FK).

2. Hubungan users dengan leave_requests (submits)
Kardinalitas: One-to-Many (||--o{)

Penjelasan: Satu karyawan (users) dapat mengajukan atau mengirimkan (submits) lebih dari satu permohonan izin/cuti (leave_requests) selama periode mereka bekerja di perusahaan. Tiap satu dokumen permohonan izin yang masuk ke dashboard admin hanya mereferensikan satu akun karyawan pengaju via token user_id (FK).

 Keuntungan Skema Database Ini
Struktur ERD ini sangat efisien untuk diterapkan pada NoSQL Firestore karena:

Query Cepat: Pemisahan koleksi attendance_logs dan leave_requests dari data master users membuat database tetap ringan. Admin bisa memanggil ribuan data log absen bulanan secara cepat tanpa perlu ikut membebani memori dengan menarik data profil detail user berulang-ulang.

Keamanan Terjamin: Relasi berbasis Foreign Key (userId/user_id) ini memudahkan Anda dalam menulis aturan keamanan Firestore Security Rules. Anda bisa memblokir akses baca data secara instan jika request.auth.uid pengguna dari HP mencoba mengakses dokumen yang isi FK-nya tidak cocok dengan ID mereka sendiri.

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
