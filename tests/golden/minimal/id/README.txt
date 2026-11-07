PAKET SERAH TERIMA: demo.example.net (demo.example.net)
=======================================================

Klien:   CV Demo
Vendor:  Belum diisi
Tanggal: Belum diisi
Dibuat dengan dejavu 1.1.0 dari ansibro 1.2.0.

INI MASIH DRAF. Jangan ditandatangani atau diserahkan: masih ada jawaban
yang belum diisi.

Tidak ada file di paket ini yang memuat kata sandi, kecuali file kredensial,
yang terenkripsi. Frasa sandi pembukanya tidak pernah ada di paket ini.

ISI SETIAP FILE
---------------

id/cv-demo-BAST.pdf
    Berita Acara Serah Terima (BAST), dengan Lampiran 1 (daftar periksa uji
    terima), Lampiran 2 (daftar akun, hanya nama) dan Lampiran 3 (daftar
    file beserta kode SHA-256-nya). Cetak dan tanda tangani.
id/cv-demo-dokumentasi-teknis.pdf
    Dokumentasi teknis lengkap sistem ini.
id/cv-demo-panduan-laptop-windows.pdf
    Cara menjangkau sistem dari laptop Windows. Untuk staf klien.
id/cv-demo-panduan-laptop-macos.pdf
    Cara menjangkau sistem dari laptop macOS. Untuk staf klien.
id/cv-demo-panduan-laptop-linux.pdf
    Cara menjangkau sistem dari laptop Linux. Untuk staf klien.
id/*.md
    Dokumen yang sama dalam bentuk teks (Markdown), sebagai arsip yang bisa
    dibuka dengan editor apa pun.
cv-demo-kredensial.kdbx
    File kredensial: semua kata sandi, terenkripsi. Buka dengan KeePassXC.
ssh_config.txt
    Pengaturan SSH siap pakai untuk operator di pihak klien.
SHA256SUMS
    Kode SHA-256 setiap file, untuk memastikan tidak ada yang berubah.
README.txt
    File ini.

YANG DICETAK DAN DITANDATANGANI
-------------------------------

Cetak BAST sebanyak 2 (dua) rangkap. Saat sesi serah terima,
periksa Lampiran 1 bersama-sama dan bubuhkan paraf di setiap baris. Lalu
kedua pihak menandatangani setiap rangkap. Setiap pihak menyimpan satu rangkap yang sudah ditandatangani.
Untuk tanda tangan elektronik atau e-meterai, unggah file PDF-nya langsung.

URUTAN PENYERAHAN
-----------------

1. Sebelum sesi: kirim panduan laptop dan ssh_config.txt kepada
   staf klien. File-file itu tidak memuat kata sandi.
2. Serahkan file kredensial (cv-demo-kredensial.kdbx)
   melalui: Belum diisi.
3. Sampaikan frasa sandinya melalui saluran yang BERBEDA
   melalui: Belum diisi
   kepada:  Belum diisi.
   Jangan pernah dalam email, chat atau flashdisk yang sama dengan file
   kredensial. Vendor membacanya di terminalnya sendiri dengan perintah:
   handover.py passphrase
4. Klien memeriksa SHA-256 file kredensial terhadap Lampiran 3,
   membukanya, lalu menguji akses (Lampiran 1).
5. Kedua pihak menandatangani BAST.
6. Setelah itu klien mengganti semua kata sandi dalam 7 hari,
   serta frasa sandi file kredensial.

MEMERIKSA FILE
--------------

Linux:    sha256sum -c SHA256SUMS
macOS:    shasum -a 256 -c SHA256SUMS
Windows:  Get-FileHash <file> -Algorithm SHA256, lalu bandingkan dengan SHA256SUMS
