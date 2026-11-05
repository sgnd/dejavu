---
title: "BERITA ACARA SERAH TERIMA PEKERJAAN"
short-title: "Berita Acara Serah Terima"
lang: id
region: ID
docnumber: "001/BAST/NUSA/XI/2026"
version: "1.0"
date: "4 November 2026"
classification: "TERBATAS"
labels: {page: "Halaman", of: "dari", toc: "Daftar Isi"}
kop:
  name: "PT Nusantara Teknologi"
  address: "Jl. Gatot Subroto No. 9, Jakarta"
signatories:
  - {role: "PIHAK PERTAMA", company: "PT Nusantara Teknologi", name: "Rina Wijaya", title: "Project Manager", meterai: false}

  - {role: "PIHAK KEDUA", company: "PT Maju Bersama", name: "Siti Rahma", title: "Kepala Infrastruktur", meterai: true}

meterai-label: "Meterai Rp10.000"
mengetahui-label: "Mengetahui"
mengetahui-count: 1
mengetahui:
  - {name: "Hendra Gunawan", title: "Direktur TI", company: "PT Maju Bersama"}
---

```{=typst}
#align(center)[
```

**BERITA ACARA SERAH TERIMA PEKERJAAN**\
Nomor: 001/BAST/NUSA/XI/2026

```{=typst}
]
```

Dasar: Pembangunan Platform Aplikasi, nomor SPK-017/MAJU/IX/2026, tanggal 1 September 2026.

Pada hari ini, Rabu, tanggal empat bulan November tahun dua ribu dua puluh enam, bertempat di Jakarta, kami yang bertanda tangan di bawah ini:

1. **Rina Wijaya**, jabatan Project Manager, dalam hal ini bertindak untuk dan atas nama **PT Nusantara Teknologi**, beralamat di Jl. Gatot Subroto No. 9, Jakarta, selanjutnya disebut **PIHAK PERTAMA**.
2. **Siti Rahma**, jabatan Kepala Infrastruktur, dalam hal ini bertindak untuk dan atas nama **PT Maju Bersama**, beralamat di Jl. Sudirman No. 1, Jakarta, selanjutnya disebut **PIHAK KEDUA**.

## 1. Yang diserahterimakan {#bast-items}

PIHAK PERTAMA menyerahkan kepada PIHAK KEDUA, dan PIHAK KEDUA menerima dari PIHAK PERTAMA, pekerjaan dan barang-barang dalam tabel di bawah, dalam kondisi sebagaimana tercantum di dalamnya.
Sistem diserahkan dalam keadaan baik dan berfungsi: uji terima tanggal 2026-11-04 lulus tanpa kegagalan (Lampiran 1).

| No    | Uraian                     | Jumlah dan spesifikasi                                       | Kondisi         | Keterangan                                    |
|:------|:---------------------------|:-------------------------------------------------------------|:----------------|:----------------------------------------------|
| 1 | Sistem (Produksi) | Cluster Docker Swarm berisi 9 server (data1, data2, data3, manager1, manager2, manager3, worker1, worker2, worker3), domain nusa.example.co.id, dipasang dengan ansibro 1.2.0 | Baik dan berfungsi | Instalasi terakhir 2026-11-03 |
| 2 | Aplikasi | authelia 4.39.28, garage v2.5.0, portainer 2.45.3, postgres 18 (Spilo 4.1-p2), redis 8.10.3, traefik v3.7.17, uptimekuma 2.5.8, victoria v1.155.0 | Baik dan berfungsi | Rincian di bab 4 dokumentasi teknis |
| 3 | Panduan akses laptop (Linux) (bahasa Inggris) | `en/maju-laptop-guide-linux.pdf`, versi 1.0 | Lengkap | SHA-<size> `<sha<size>>` (Lampiran 3) |
| 4 | Panduan akses laptop (macOS) (bahasa Inggris) | `en/maju-laptop-guide-macos.pdf`, versi 1.0 | Lengkap | SHA-<size> `<sha<size>>` (Lampiran 3) |
| 5 | Panduan akses laptop (Windows) (bahasa Inggris) | `en/maju-laptop-guide-windows.pdf`, versi 1.0 | Lengkap | SHA-<size> `<sha<size>>` (Lampiran 3) |
| 6 | Dokumentasi teknis (bahasa Inggris) | `en/maju-technical-documentation.pdf`, versi 1.0 | Lengkap | SHA-<size> `<sha<size>>` (Lampiran 3) |
| 7 | Dokumentasi teknis | `id/maju-dokumentasi-teknis.pdf`, versi 1.0 | Lengkap | SHA-<size> `<sha<size>>` (Lampiran 3) |
| 8 | Panduan akses laptop (Linux) | `id/maju-panduan-laptop-linux.pdf`, versi 1.0 | Lengkap | SHA-<size> `<sha<size>>` (Lampiran 3) |
| 9 | Panduan akses laptop (macOS) | `id/maju-panduan-laptop-macos.pdf`, versi 1.0 | Lengkap | SHA-<size> `<sha<size>>` (Lampiran 3) |
| 10 | Panduan akses laptop (Windows) | `id/maju-panduan-laptop-windows.pdf`, versi 1.0 | Lengkap | SHA-<size> `<sha<size>>` (Lampiran 3) |
| 11 | Pengaturan SSH untuk laptop | `ssh_config.txt` | Lengkap | SHA-256 `<sha256>` (Lampiran 3) |
| 12 | File kredensial (terenkripsi) | `maju-kredensial.kdbx`, <size> byte; diserahkan melalui USB diserahkan langsung pada 4 November <size> | Lengkap, terenkripsi | SHA-<size> `<sha<size>>` (Lampiran 3). Kata sandi pembuka disampaikan terpisah melalui telepon kepada Siti Rahma. Dokumen ini dan dokumen teknis tidak memuat kata sandi. |
| 13 | Domain dan DNS | nusa.example.co.id; DNS: DNS publik di Cloudflare | Digunakan | Pemilik domain: PT Maju Bersama |
| 14 | Repositori backup | restic, s3 di s3.example.com, setiap malam pukul 02:00 (UTC) | Digunakan | Kata sandinya ada di file kredensial, grup "05 Pemulihan (darurat)" |
| 15 | Akun | Hanya nama, tanpa nilai: lihat Lampiran 2 | Diserahkan | Nilainya hanya ada di file kredensial |

## 2. Kewajiban setelah serah terima {#bast-duties}

1. PIHAK KEDUA mengganti semua kata sandi yang dipakai orang (Lampiran 2) dalam waktu 7 (tujuh) hari sejak tanggal berita acara ini, sebagaimana dijelaskan dalam bab 6 dan Lampiran E dokumentasi teknis, serta mengganti frasa sandi pembuka file kredensial. PIHAK KEDUA menyimpan file kredensial sebagai catatan akun.
2. Pada 4 Desember 2026, kunci SSH dan alamat internet milik PIHAK PERTAMA dihapus dari server dan dari daftar izin (allow-list).
3. PIHAK KEDUA menyimpan catatan installer (folder state/ milik ansibro), dari file kredensial, grup "06 Internal (menjalankan ulang ansibro)". PIHAK PERTAMA menghapus salinannya sendiri setelah disepakati para pihak.

## 3. Garansi dan pemeliharaan {#bast-warranty}

- Masa garansi: 3 (tiga) bulan, sampai 4 Februari 2027.
- Lingkup: Perbaikan kesalahan konfigurasi dari pekerjaan ini.
- Jam layanan: Senin-Jumat 09.00-17.00 WIB. Waktu tanggap: Respons dalam 4 jam kerja.
- Sejak tanggal berita acara ini, risiko atas sistem beralih kepada PIHAK KEDUA.

| Nama                       | Peran                    | Telepon                  | Email                            |
|:---------------------------|:-------------------------|:-------------------------|:---------------------------------|
| Rina Wijaya | Project Manager | \+62 812 0000 1111 | rina\@nusa.example |

## 4. Uji terima {#bast-acceptance}

Uji terima dijalankan pada 2026-11-04: 9 lulus, 0 gagal, 1 dilewati.
Uji pemulihan (restore) terakhir: 2 November 2026.

## 5. Catatan {#bast-notes}

- Masalah yang diketahui: Notifikasi Uptime Kuma diatur klien setelah serah terima.
- Hal terbuka: Daftar izin ssh.allow_from kosong: terbuka untuk siapa saja.
- Hal terbuka: Halaman web tidak memakai sertifikat tepercaya (selfsigned): browser menampilkan peringatan.
- Hal terbuka: Notifikasi Uptime Kuma harus diatur secara manual.
- Hal terbuka: Masih ada file kata sandi dari aplikasi yang sudah dihapus (swarmpit_admin); file itu disimpan di file kredensial, grup "07 Lama (aplikasi yang sudah dihapus)".
- Tidak termasuk pekerjaan: Aplikasi bisnis milik klien

```{=typst}
#block(breakable: false)[
```

## 6. Penutup {#bast-closing}

Demikian berita acara ini dibuat dengan sebenarnya dalam rangkap 2 (dua), masing-masing mempunyai kekuatan hukum yang sama. Berita acara ini juga dibuat dalam bahasa Inggris. Dalam hal terdapat perbedaan penafsiran, versi Bahasa Indonesia yang berlaku.

```{=typst}
#signatures()
```

```{=typst}
]
```

```{=typst}
#pagebreak()
```

## Lampiran 1. Daftar periksa uji terima {#bast-annex-checklist}

Dikerjakan bersama saat sesi serah terima. Setiap pihak membubuhkan paraf di setiap baris.

| □ | Butir                                  | Cara memeriksa                                           | Hasil      | Paraf Pihak I | Paraf Pihak II |
|:--|:---------------------------------------|:---------------------------------------------------------|:-----------|:-----------|:-----------|
| □ | <https://authelia.nusa.example.co.id/> terbuka | Buka di browser (peringatan sertifikat memang akan muncul) | | | |
| □ | <https://portainer.nusa.example.co.id/> terbuka | Buka di browser (peringatan sertifikat memang akan muncul) | | | |
| □ | <https://traefik.nusa.example.co.id/dashboard/> terbuka | Buka di browser (peringatan sertifikat memang akan muncul) | | | |
| □ | <https://uptimekuma.nusa.example.co.id/> terbuka | Buka di browser (peringatan sertifikat memang akan muncul) | | | |
| □ | <https://grafana.nusa.example.co.id/> terbuka | Buka di browser (peringatan sertifikat memang akan muncul) | | | |
| □ | <https://alertmanager.nusa.example.co.id/> terbuka | Buka di browser (peringatan sertifikat memang akan muncul) | | | |
| □ | <https://metrics.nusa.example.co.id/vmui> terbuka | Buka di browser (peringatan sertifikat memang akan muncul) | | | |
| □ | <https://logs.nusa.example.co.id/select/vmui> terbuka | Buka di browser (peringatan sertifikat memang akan muncul) | | | |
| □ | Setiap login berhasil | Login dengan setiap entri web di Lampiran 2 | | | |
| □ | 2FA terpasang di ponsel PIHAK KEDUA | Login ke halaman admin dengan kode 6 angka | | | |
| □ | File kredensial terbuka, SHA-256 cocok | Bandingkan dengan Lampiran 3, lalu buka dengan frasa sandi | | | |
| □ | Akses laptop: Budi Santoso | Halaman web, SSH dan tunnel dari Windows | | | |
| □ | Akses laptop: Siti Rahma | Halaman web dari macOS | | | |
| □ | Akses laptop: Joko Prasetyo | Halaman web, SSH, tunnel dan installer dari Linux | | | |
| □ | Kunci SSH PIHAK KEDUA terpasang di setiap server | `ssh maju-<server>` berhasil untuk setiap server | | | |
| □ | Alamat PIHAK KEDUA diizinkan | Halaman admin dan SSH terbuka dari alamat PIHAK KEDUA | | | |
| □ | Ada backup yang berumur kurang dari 26 jam | `sudo ansibro-backup snapshots` di salah satu server | | | |
| □ | Uji pemulihan (restore) | Dilakukan pada 2026-11-02 | | | |
| □ | Peringatan uji diterima | Peringatan sampai di saluran yang disepakati | | | |
| □ | Notifikasi diatur di Uptime Kuma | Pengaturan notifikasi tiap aplikasi menunjukkan sebuah saluran | | | |
| □ | Uji sistem (check.py) | `.venv/bin/python tests/check.py` | 9 PASS / 0 FAIL / 1 SKIP | | |

```{=typst}
#pagebreak()
```

## Lampiran 2. Daftar akun {#bast-annex-accounts}

Nama-nama akun di file kredensial **maju-kredensial.kdbx**. Tidak ada kata sandi yang ditulis di sini. Alamatnya tercantum di setiap entri.

| Aplikasi       | Pengguna      | Entri di file kredensial                        | Kegunaan                      | Cara menggantinya                     |
|:---------------|:--------------|:------------------------------------------------|:------------------------------|:--------------------------------------|
| authelia | admin | 01 Login web/Authelia | Untuk login orang | Di aplikasi, lalu di file |
| garage | GK… (access key) | 03 Penyimpanan S3/Garage S3 | Untuk login orang | Ubah file, jalankan installer |
| victoria | admin | 01 Login web/Grafana | Untuk login orang | Di aplikasi, lalu di file (belum diuji) |
| portainer | admin | 01 Login web/Portainer | Untuk login orang | Di aplikasi, lalu di file |
| postgres | postgres | 02 Database dan cache/PostgreSQL | Untuk login orang | Di aplikasi dan di file bersamaan (belum diuji) |
| redis | — | 02 Database dan cache/Redis | Untuk login orang | Ubah file, jalankan installer |
| registry | ansibro | 04 Infrastruktur/Image registry | Pemulihan (simpan baik-baik) | Di aplikasi dan di file bersamaan |
| backup | — | 05 Pemulihan (darurat)/Backup (restic) | Pemulihan (simpan baik-baik) | Di aplikasi dan di file bersamaan |
| traefik | admin | 01 Login web/Traefik | Untuk login orang | Ubah file, jalankan installer |
| uptimekuma | admin | 01 Login web/Uptime Kuma | Untuk login orang | Di aplikasi, lalu di file |
| config.yml | — | 05 Pemulihan (darurat)/config.yml backup.s3_access_key | Pemulihan (simpan baik-baik) | Di config.yml, jalankan installer |
| config.yml | — | 05 Pemulihan (darurat)/config.yml backup.s3_secret_key | Pemulihan (simpan baik-baik) | Di config.yml, jalankan installer |
| config.yml | — | 05 Pemulihan (darurat)/config.yml monitoring.webhook | Pemulihan (simpan baik-baik) | Di config.yml, jalankan installer |
| SSH | — | 04 Infrastruktur/SSH key (client) | Kunci SSH PIHAK KEDUA (lampiran) | Buat kunci baru, ganti di setiap server |
| ansibro | — | 06 Internal (menjalankan ulang ansibro)/ansibro installer files | Untuk menjalankan installer lagi (lampiran) | Tidak berlaku lagi setelah kata sandi diganti |

Grup "06 Internal (menjalankan ulang ansibro)" juga berisi 12 entri internal yang tidak pernah diketik orang, dan grup "07 Lama (aplikasi yang sudah dihapus)" berisi 1 entri dari aplikasi yang sudah dihapus. Bab 6 dokumentasi teknis menjelaskan cara mengganti masing-masing.

```{=typst}
#pagebreak()
```

## Lampiran 3. Daftar file yang diserahkan {#bast-annex-files}

Setiap file beserta ukuran dan kode SHA-256-nya (sidik jari isi file: perubahan sekecil apa pun menghasilkan kode lain). Kode milik berita acara ini sendiri ada di file SHA256SUMS.

| File                                         | Ukuran (byte)  | SHA-256                                  |
|:---------------------------------------------|:---------------|:-----------------------------------------|
| `en/maju-laptop-guide-linux.pdf` | <size> | `<sha<size>>` `<sha<size>>` |
| `en/maju-laptop-guide-macos.pdf` | <size> | `<sha<size>>` `<sha<size>>` |
| `en/maju-laptop-guide-windows.pdf` | <size> | `<sha<size>>` `<sha<size>>` |
| `en/maju-technical-documentation.pdf` | <size> | `<sha<size>>` `<sha<size>>` |
| `id/maju-dokumentasi-teknis.pdf` | <size> | `<sha<size>>` `<sha<size>>` |
| `id/maju-panduan-laptop-linux.pdf` | <size> | `<sha<size>>` `<sha<size>>` |
| `id/maju-panduan-laptop-macos.pdf` | <size> | `<sha<size>>` `<sha<size>>` |
| `id/maju-panduan-laptop-windows.pdf` | <size> | `<sha<size>>` `<sha<size>>` |
| `maju-kredensial.kdbx` | <size> | `<sha<size>>` `<sha<size>>` |
| `ssh_config.txt` | 2.148 | `<sha256>` `<sha256>` |

Cara memeriksa sebuah file: `Get-FileHash <file> -Algorithm SHA256` (Windows), `shasum -a 256 <file>` (macOS), `sha256sum <file>` (Linux).
