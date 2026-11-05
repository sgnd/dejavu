---
title: "BERITA ACARA SERAH TERIMA PEKERJAAN"
short-title: "Berita Acara Serah Terima"
lang: id
region: ID
docnumber: "Belum diisi"
version: "1.0"
date: "Belum diisi"
classification: "TERBATAS"
draft: true
labels: {page: "Halaman", of: "dari", toc: "Daftar Isi"}
kop:
  name: "Belum diisi"
  address: "Belum diisi"
signatories:
  - {role: "PIHAK PERTAMA", company: "Belum diisi", name: "Belum diisi", title: "Belum diisi", meterai: false}

  - {role: "PIHAK KEDUA", company: "CV Demo", name: "Belum diisi", title: "Belum diisi", meterai: false}

meterai-label: "Meterai Rp10.000"
---

```{=typst}
#align(center)[
```

**BERITA ACARA SERAH TERIMA PEKERJAAN**\
Nomor: Belum diisi

```{=typst}
]
```

Dasar: Belum diisi, nomor Belum diisi, tanggal Belum diisi.

Pada hari ini, Belum diisi, bertempat di Belum diisi, kami yang bertanda tangan di bawah ini:

1. **Belum diisi**, jabatan Belum diisi, dalam hal ini bertindak untuk dan atas nama **Belum diisi**, beralamat di Belum diisi, selanjutnya disebut **PIHAK PERTAMA**.
2. **Belum diisi**, jabatan Belum diisi, dalam hal ini bertindak untuk dan atas nama **CV Demo**, beralamat di Belum diisi, selanjutnya disebut **PIHAK KEDUA**.

## 1. Yang diserahterimakan {#bast-items}

PIHAK PERTAMA menyerahkan kepada PIHAK KEDUA, dan PIHAK KEDUA menerima dari PIHAK PERTAMA, pekerjaan dan barang-barang dalam tabel di bawah, dalam kondisi sebagaimana tercantum di dalamnya.
Sistem belum diuji: uji terima belum dijalankan. Daftar pemeriksaannya ada di Lampiran 1.

| No    | Uraian                     | Jumlah dan spesifikasi                                       | Kondisi         | Keterangan                                    |
|:------|:---------------------------|:-------------------------------------------------------------|:----------------|:----------------------------------------------|
| 1 | Sistem (demo.example.net) | Cluster Docker Swarm berisi 1 server (srv), domain demo.example.net, dipasang dengan ansibro 1.2.0 | Belum diuji | Instalasi terakhir 2026-11-03 |
| 2 | Aplikasi | postgres 18.6, traefik v3.7.17 | Belum diuji | Rincian di bab 4 dokumentasi teknis |
| 3 | Dokumentasi teknis | `id/cv-demo-dokumentasi-teknis.pdf`, versi 1.0 | Lengkap | SHA-<size> `<sha<size>>` (Lampiran 3) |
| 4 | Panduan akses laptop (Linux) | `id/cv-demo-panduan-laptop-linux.pdf`, versi 1.0 | Lengkap | SHA-<size> `<sha<size>>` (Lampiran 3) |
| 5 | Panduan akses laptop (macOS) | `id/cv-demo-panduan-laptop-macos.pdf`, versi 1.0 | Lengkap | SHA-<size> `<sha<size>>` (Lampiran 3) |
| 6 | Panduan akses laptop (Windows) | `id/cv-demo-panduan-laptop-windows.pdf`, versi 1.0 | Lengkap | SHA-<size> `<sha<size>>` (Lampiran 3) |
| 7 | Pengaturan SSH untuk laptop | `ssh_config.txt` | Lengkap | SHA-256 `<sha256>` (Lampiran 3) |
| 8 | File kredensial (terenkripsi) | `cv-demo-kredensial.kdbx`, <size> byte; diserahkan melalui Belum diisi pada Belum diisi | Lengkap, terenkripsi | SHA-<size> `<sha<size>>` (Lampiran 3). Kata sandi pembuka disampaikan terpisah melalui Belum diisi kepada Belum diisi. Dokumen ini dan dokumen teknis tidak memuat kata sandi. |
| 9 | Domain dan DNS | demo.example.net; DNS: DNS publik | Digunakan | Pemilik domain: Belum diisi |
| 10 | Repositori backup | Tidak ada | Tidak ada | Backup belum disiapkan (lihat butir 5) |
| 11 | Akun | Hanya nama, tanpa nilai: lihat Lampiran 2 | Diserahkan | Nilainya hanya ada di file kredensial |

## 2. Kewajiban setelah serah terima {#bast-duties}

1. PIHAK KEDUA mengganti semua kata sandi yang dipakai orang (Lampiran 2) dalam waktu 7 (tujuh) hari sejak tanggal berita acara ini, sebagaimana dijelaskan dalam bab 6 dan Lampiran E dokumentasi teknis, serta mengganti frasa sandi pembuka file kredensial. PIHAK KEDUA menyimpan file kredensial sebagai catatan akun.
2. Pada Belum diisi, kunci SSH dan alamat internet milik PIHAK PERTAMA dihapus dari server dan dari daftar izin (allow-list).
3. PIHAK PERTAMA menyimpan catatan installer (folder state/ milik ansibro), yang diperlukan untuk mengubah sistem di kemudian hari. Bila PIHAK KEDUA mengganti kata sandi yang juga dipakai oleh installer, PIHAK KEDUA mengirimkan nilai barunya kepada PIHAK PERTAMA dalam file kredensial yang dienkripsi ulang; bila tidak, instalasi berikutnya akan membatalkan perubahan itu atau gagal. PIHAK KEDUA juga memegang salinan catatan ini di file kredensial, sehingga dapat berganti penyedia kapan saja.

## 3. Garansi dan pemeliharaan {#bast-warranty}

- Masa garansi: Belum diisi, sampai Belum diisi.
- Lingkup: Belum diisi.
- Jam layanan: Belum diisi. Waktu tanggap: Belum diisi.
- Sejak tanggal berita acara ini, risiko atas sistem beralih kepada PIHAK KEDUA.

Kontak dukungan: Belum diisi.

## 4. Uji terima {#bast-acceptance}

Uji terima belum dijalankan. Daftar pemeriksaannya ada di Lampiran 1, untuk dikerjakan bersama saat sesi serah terima.
Uji pemulihan (restore) terakhir: belum pernah dilakukan.

## 5. Catatan {#bast-notes}

- Hal terbuka: Daftar izin ssh.allow_from kosong: terbuka untuk siapa saja.
- Hal terbuka: Daftar izin admin_allow_from kosong: terbuka untuk siapa saja.
- Hal terbuka: Backup belum disiapkan.
- Hal terbuka: Pemantauan belum disiapkan: tidak ada yang menerima peringatan.
- Hal terbuka: Masih ada file kata sandi dari aplikasi yang sudah dihapus (nats); file itu disimpan di file kredensial, grup "07 Lama (aplikasi yang sudah dihapus)".

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
| □ | <https://traefik.demo.example.net/dashboard/> terbuka | Buka di browser | | | |
| □ | Setiap login berhasil | Login dengan setiap entri web di Lampiran 2 | | | |
| □ | File kredensial terbuka, SHA-256 cocok | Bandingkan dengan Lampiran 3, lalu buka dengan frasa sandi | | | |
| □ | Akses laptop | Halaman web, SSH dan tunnel dari laptop PIHAK KEDUA | | | |
| □ | Kunci SSH PIHAK KEDUA terpasang di setiap server | `ssh cv-demo-<server>` berhasil untuk setiap server | | | |
| □ | Alamat PIHAK KEDUA diizinkan | Daftar izin kosong (terbuka untuk siapa saja): PIHAK KEDUA menyetujui hal ini | | | |
| □ | Uji pemulihan (restore) | Belum dilakukan | | | |
| □ | Uji sistem (check.py) | `.venv/bin/python tests/check.py` |  | | |

```{=typst}
#pagebreak()
```

## Lampiran 2. Daftar akun {#bast-annex-accounts}

Nama-nama akun di file kredensial **cv-demo-kredensial.kdbx**. Tidak ada kata sandi yang ditulis di sini. Alamatnya tercantum di setiap entri.

| Aplikasi       | Pengguna      | Entri di file kredensial                        | Kegunaan                      | Cara menggantinya                     |
|:---------------|:--------------|:------------------------------------------------|:------------------------------|:--------------------------------------|
| postgres | postgres | 02 Database dan cache/PostgreSQL | Untuk login orang | Di aplikasi dan di file bersamaan (belum diuji) |
| registry | ansibro | 04 Infrastruktur/Image registry | Pemulihan (simpan baik-baik) | Di aplikasi dan di file bersamaan |
| traefik | admin | 01 Login web/Traefik | Untuk login orang | Ubah file, jalankan installer |
| ansibro | — | 06 Internal (menjalankan ulang ansibro)/ansibro installer files | Untuk menjalankan installer lagi (lampiran) | Tidak berlaku lagi setelah kata sandi diganti |

Grup "06 Internal (menjalankan ulang ansibro)" juga berisi 2 entri internal yang tidak pernah diketik orang, dan grup "07 Lama (aplikasi yang sudah dihapus)" berisi 1 entri dari aplikasi yang sudah dihapus. Bab 6 dokumentasi teknis menjelaskan cara mengganti masing-masing.

```{=typst}
#pagebreak()
```

## Lampiran 3. Daftar file yang diserahkan {#bast-annex-files}

Setiap file beserta ukuran dan kode SHA-256-nya (sidik jari isi file: perubahan sekecil apa pun menghasilkan kode lain). Kode milik berita acara ini sendiri ada di file SHA256SUMS.

| File                                         | Ukuran (byte)  | SHA-256                                  |
|:---------------------------------------------|:---------------|:-----------------------------------------|
| `cv-demo-kredensial.kdbx` | <size> | `<sha<size>>` `<sha<size>>` |
| `id/cv-demo-dokumentasi-teknis.pdf` | <size> | `<sha<size>>` `<sha<size>>` |
| `id/cv-demo-panduan-laptop-linux.pdf` | <size> | `<sha<size>>` `<sha<size>>` |
| `id/cv-demo-panduan-laptop-macos.pdf` | <size> | `<sha<size>>` `<sha<size>>` |
| `id/cv-demo-panduan-laptop-windows.pdf` | <size> | `<sha<size>>` `<sha<size>>` |
| `ssh_config.txt` | 726 | `<sha256>` `<sha256>` |

Cara memeriksa sebuah file: `Get-FileHash <file> -Algorithm SHA256` (Windows), `shasum -a 256 <file>` (macOS), `sha256sum <file>` (Linux).
