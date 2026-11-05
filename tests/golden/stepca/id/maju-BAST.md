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
  - {role: "PIHAK PERTAMA", company: "PT Maju Bersama", name: "Siti Rahma", title: "Kepala Infrastruktur", meterai: false}

  - {role: "PIHAK KEDUA", company: "PT Nusantara Teknologi", name: "Rina Wijaya", title: "Project Manager", meterai: false}

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

1. **Siti Rahma**, jabatan Kepala Infrastruktur, dalam hal ini bertindak untuk dan atas nama **PT Maju Bersama**, beralamat di Jl. Sudirman No. 1, Jakarta, selanjutnya disebut **PIHAK PERTAMA**.
2. **Rina Wijaya**, jabatan Project Manager, dalam hal ini bertindak untuk dan atas nama **PT Nusantara Teknologi**, beralamat di Jl. Gatot Subroto No. 9, Jakarta, selanjutnya disebut **PIHAK KEDUA**.

## 1. Yang diserahterimakan {#bast-items}

PIHAK KEDUA menyerahkan kepada PIHAK PERTAMA, dan PIHAK PERTAMA menerima dari PIHAK KEDUA, pekerjaan dan barang-barang dalam tabel di bawah, dalam kondisi sebagaimana tercantum di dalamnya.
Sistem belum diuji: uji terima belum dijalankan. Daftar pemeriksaannya ada di Lampiran 1.

| No    | Uraian                     | Jumlah dan spesifikasi                                       | Kondisi         | Keterangan                                    |
|:------|:---------------------------|:-------------------------------------------------------------|:----------------|:----------------------------------------------|
| 1 | Sistem (Produksi) | Cluster Docker Swarm berisi 2 server (app1, data1), domain apps.internal.example, dipasang dengan ansibro 1.2.0 | Belum diuji | Instalasi terakhir 2026-11-03 |
| 2 | Aplikasi | mariadb 11.8.9, rabbitmq 4.3.7-management, swarmpit 1.10, traefik v3.7.17, uptimekuma 2.5.8, valkey 9.1.3 | Belum diuji | Rincian di bab 4 dokumentasi teknis |
| 3 | Dokumentasi teknis | `id/maju-dokumentasi-teknis.pdf`, versi 1.0 | Lengkap | SHA-<size> `<sha<size>>` (Lampiran 3) |
| 4 | Panduan akses laptop (macOS) | `id/maju-panduan-laptop-macos.pdf`, versi 1.0 | Lengkap | SHA-<size> `<sha<size>>` (Lampiran 3) |
| 5 | Panduan akses laptop (Windows) | `id/maju-panduan-laptop-windows.pdf`, versi 1.0 | Lengkap | SHA-<size> `<sha<size>>` (Lampiran 3) |
| 6 | Otoritas sertifikat yang perlu dipercaya | `maju-ca.crt` | Lengkap | SHA-256 `<sha256>` (Lampiran 3) |
| 7 | Pengaturan SSH untuk laptop | `ssh_config.txt` | Lengkap | SHA-256 `<sha256>` (Lampiran 3) |
| 8 | File kredensial (terenkripsi) | `maju-kredensial.kdbx`, <size> byte; diserahkan melalui USB diserahkan langsung pada 4 November <size> | Lengkap, terenkripsi | SHA-<size> `<sha<size>>` (Lampiran 3). Kata sandi pembuka disampaikan terpisah melalui telepon kepada Siti Rahma. Dokumen ini dan dokumen teknis tidak memuat kata sandi. |
| 9 | Domain dan DNS | apps.internal.example; DNS: DNS perusahaan di Active Directory DNS | Digunakan | Pemilik domain: PT Maju Bersama |
| 10 | Repositori backup | restic, rest di backup.internal.example, setiap malam pukul 02:00 (Asia/Jakarta) | Digunakan | Kata sandinya ada di file kredensial, grup "05 Pemulihan (darurat)" |
| 11 | Akun | Hanya nama, tanpa nilai: lihat Lampiran 2 | Diserahkan | Nilainya hanya ada di file kredensial |

## 2. Kewajiban setelah serah terima {#bast-duties}

1. PIHAK PERTAMA mengganti semua kata sandi yang dipakai orang (Lampiran 2) dalam waktu 7 (tujuh) hari sejak tanggal berita acara ini, sebagaimana dijelaskan dalam bab 6 dan Lampiran E dokumentasi teknis, serta mengganti frasa sandi pembuka file kredensial. PIHAK PERTAMA menyimpan file kredensial sebagai catatan akun.
2. Pada 4 Desember 2026, kunci SSH dan alamat internet milik PIHAK KEDUA dihapus dari server dan dari daftar izin (allow-list).
3. PIHAK KEDUA menyimpan catatan installer (folder state/ milik ansibro), yang diperlukan untuk mengubah sistem di kemudian hari. Bila PIHAK PERTAMA mengganti kata sandi yang juga dipakai oleh installer, PIHAK PERTAMA mengirimkan nilai barunya kepada PIHAK KEDUA dalam file kredensial yang dienkripsi ulang; bila tidak, instalasi berikutnya akan membatalkan perubahan itu atau gagal. PIHAK PERTAMA juga memegang salinan catatan ini di file kredensial, sehingga dapat berganti penyedia kapan saja.

## 3. Garansi dan pemeliharaan {#bast-warranty}

- Masa garansi: 3 (tiga) bulan, sampai 4 Februari 2027.
- Lingkup: Perbaikan kesalahan konfigurasi dari pekerjaan ini.
- Jam layanan: Senin-Jumat 09.00-17.00 WIB. Waktu tanggap: Respons dalam 4 jam kerja.
- Sejak tanggal berita acara ini, risiko atas sistem beralih kepada PIHAK PERTAMA.

| Nama                       | Peran                    | Telepon                  | Email                            |
|:---------------------------|:-------------------------|:-------------------------|:---------------------------------|
| Rina Wijaya | Project Manager | \+62 812 0000 1111 | rina\@nusa.example |

## 4. Uji terima {#bast-acceptance}

Uji terima belum dijalankan. Daftar pemeriksaannya ada di Lampiran 1, untuk dikerjakan bersama saat sesi serah terima.
Uji pemulihan (restore) terakhir: belum pernah dilakukan.

## 5. Catatan {#bast-notes}

- Hal terbuka: Daftar izin ssh.allow_from kosong: terbuka untuk siapa saja.
- Hal terbuka: Daftar izin admin_allow_from kosong: terbuka untuk siapa saja.
- Hal terbuka: Tidak ada yang diberi tahu bila backup berhenti bekerja.
- Hal terbuka: Pemantauan belum disiapkan: tidak ada yang menerima peringatan.
- Hal terbuka: Notifikasi Uptime Kuma harus diatur secara manual.
- Hal terbuka: Swarmpit memakai versi database lama (risiko yang sudah diketahui).
- Tidak termasuk pekerjaan: Aplikasi bisnis milik klien

```{=typst}
#block(breakable: false)[
```

## 6. Penutup {#bast-closing}

Demikian berita acara ini dibuat dengan sebenarnya dalam rangkap 2 (dua), masing-masing mempunyai kekuatan hukum yang sama.

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
| □ | <https://rabbitmq.apps.internal.example/> terbuka | Buka di browser | | | |
| □ | <https://swarmpit.apps.internal.example/> terbuka | Buka di browser | | | |
| □ | <https://traefik.apps.internal.example/dashboard/> terbuka | Buka di browser | | | |
| □ | <https://uptimekuma.apps.internal.example/> terbuka | Buka di browser | | | |
| □ | Setiap login berhasil | Login dengan setiap entri web di Lampiran 2 | | | |
| □ | File kredensial terbuka, SHA-256 cocok | Bandingkan dengan Lampiran 3, lalu buka dengan frasa sandi | | | |
| □ | Akses laptop: Budi Santoso | Halaman web, SSH dan tunnel dari Windows | | | |
| □ | Akses laptop: Siti Rahma | Halaman web dari macOS | | | |
| □ | Kunci SSH PIHAK PERTAMA terpasang di setiap server | `ssh maju-<server>` berhasil untuk setiap server | | | |
| □ | Alamat PIHAK PERTAMA diizinkan | Daftar izin kosong (terbuka untuk siapa saja): PIHAK PERTAMA menyetujui hal ini | | | |
| □ | Ada backup yang berumur kurang dari 26 jam | `sudo ansibro-backup snapshots` di salah satu server | | | |
| □ | Uji pemulihan (restore) | Belum dilakukan | | | |
| □ | Notifikasi diatur di Uptime Kuma | Pengaturan notifikasi tiap aplikasi menunjukkan sebuah saluran | | | |
| □ | Uji sistem (check.py) | `.venv/bin/python tests/check.py` |  | | |

```{=typst}
#pagebreak()
```

## Lampiran 2. Daftar akun {#bast-annex-accounts}

Nama-nama akun di file kredensial **maju-kredensial.kdbx**. Tidak ada kata sandi yang ditulis di sini. Alamatnya tercantum di setiap entri.

| Aplikasi       | Pengguna      | Entri di file kredensial                        | Kegunaan                      | Cara menggantinya                     |
|:---------------|:--------------|:------------------------------------------------|:------------------------------|:--------------------------------------|
| mariadb | root | 02 Database dan cache/MariaDB | Untuk login orang | Di aplikasi dan di file bersamaan |
| rabbitmq | admin | 01 Login web/RabbitMQ | Untuk login orang | Di aplikasi, lalu di file (belum diuji) |
| registry | ansibro | 04 Infrastruktur/Image registry | Pemulihan (simpan baik-baik) | Di aplikasi dan di file bersamaan |
| backup | — | 05 Pemulihan (darurat)/Backup (restic) | Pemulihan (simpan baik-baik) | Di aplikasi dan di file bersamaan |
| swarmpit | admin | 01 Login web/Swarmpit | Untuk login orang | Di aplikasi, lalu di file |
| traefik | admin | 01 Login web/Traefik | Untuk login orang | Ubah file, jalankan installer |
| uptimekuma | admin | 01 Login web/Uptime Kuma | Untuk login orang | Di aplikasi, lalu di file |
| valkey | — | 02 Database dan cache/Valkey | Untuk login orang | Ubah file, jalankan installer |
| config.yml | — | 05 Pemulihan (darurat)/config.yml backup.repository | Pemulihan (simpan baik-baik) | Di config.yml, jalankan installer |
| ansibro | — | 06 Internal (menjalankan ulang ansibro)/ansibro installer files | Untuk menjalankan installer lagi (lampiran) | Tidak berlaku lagi setelah kata sandi diganti |

Grup "06 Internal (menjalankan ulang ansibro)" juga berisi 1 entri internal yang tidak pernah diketik orang. Bab 6 dokumentasi teknis menjelaskan cara mengganti masing-masing.

```{=typst}
#pagebreak()
```

## Lampiran 3. Daftar file yang diserahkan {#bast-annex-files}

Setiap file beserta ukuran dan kode SHA-256-nya (sidik jari isi file: perubahan sekecil apa pun menghasilkan kode lain). Kode milik berita acara ini sendiri ada di file SHA256SUMS.

| File                                         | Ukuran (byte)  | SHA-256                                  |
|:---------------------------------------------|:---------------|:-----------------------------------------|
| `id/maju-dokumentasi-teknis.pdf` | <size> | `<sha<size>>` `<sha<size>>` |
| `id/maju-panduan-laptop-macos.pdf` | <size> | `<sha<size>>` `<sha<size>>` |
| `id/maju-panduan-laptop-windows.pdf` | <size> | `<sha<size>>` `<sha<size>>` |
| `maju-ca.crt` | 579 | `<sha256>` `<sha256>` |
| `maju-kredensial.kdbx` | <size> | `<sha<size>>` `<sha<size>>` |
| `ssh_config.txt` | 991 | `<sha256>` `<sha256>` |

Cara memeriksa sebuah file: `Get-FileHash <file> -Algorithm SHA256` (Windows), `shasum -a 256 <file>` (macOS), `sha256sum <file>` (Linux).
