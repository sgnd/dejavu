---
title: "Dokumentasi Teknis Serah Terima"
subtitle: "demo.example.net"
short-title: "Dokumentasi Teknis · CV Demo"
lang: id
region: ID
docnumber: ""
version: "1.0"
date: "4 November 2026"
classification: "TERBATAS"
numbered: true
draft: true
labels: {page: "Halaman", of: "dari", toc: "Daftar Isi"}
cover:
  kicker: "DOKUMENTASI SERAH TERIMA"
  rows:
    - {label: "Untuk", value: "CV Demo"}
    - {label: "Oleh", value: "Belum diisi"}
    - {label: "Sistem", value: "demo.example.net"}
    - {label: "Nomor dokumen", value: "Belum diisi"}
    - {label: "Versi", value: "1.0"}
    - {label: "Tanggal", value: "4 November 2026"}
    - {label: "Klasifikasi", value: "TERBATAS"}
    - {label: "Distribusi", value: "Hanya untuk CV Demo dan Vendor"}
  footer: "Dibuat dengan dejavu 1.1.0 dari ansibro 1.2.0. Dokumen ini tidak memuat kata sandi apa pun. Dokumen ini menjelaskan cara masuk ke sistem, jadi jaga kerahasiaannya."
---

# Pengendalian dokumen {#control .unnumbered}

| Peran | Nama |
|:---------------|:--------------------------------------------------------|
| Disusun oleh | *Belum diisi* |
| Diperiksa oleh | *Belum diisi* |
| Disetujui oleh | *Belum diisi* |

Riwayat revisi: *belum ada catatan*.

Dokumen ini dibuat dengan dejavu 1.1.0 dari ansibro 1.2.0, konfigurasi `config`, instalasi terakhir 3 November 2026.
Dokumen ini tidak memuat kata sandi. Semua kata sandi ada di file kredensial `cv-demo-kredensial.kdbx`.
Jika suatu jawaban belum diberikan, teks menulis *Belum diisi*.

## Cara membaca dokumen ini {#how-to-read .unnumbered}

- **Semua pembaca** (yang hanya memakai halaman web): baca [bab 1](#summary), [bab 5](#access), [bab 6](#credentials), dan [bab 11](#support).
- **Operator** (yang merawat server): baca seluruh dokumen.
- Istilah teknis dijelaskan saat pertama kali muncul, dan sekali lagi di [glosarium](#appendix-glossary) (Lampiran H).
- Kotak merah menandai hal yang harus Anda tindak lanjuti.

# Ringkasan {#summary}

## Apa yang dibangun {#summary-built}

Vendor membangun sistem dengan 1 server untuk CV Demo.
Sistem ini dapat diakses di alamat web `demo.example.net` dan halaman-halaman di bawahnya, misalnya `traefik.demo.example.net`.
Sistem dipasang dengan ansibro, yaitu program instalasi yang memasang program yang sama di setiap server dengan cara yang sama.
Program yang berjalan:

- **PostgreSQL**: Database SQL untuk aplikasi Anda (dan untuk Kong, Keycloak, Authelia).
- **Traefik**: Pintu masuk semua halaman web. Menerima HTTPS untuk domain dan meneruskan tiap subdomain ke aplikasinya, lengkap dengan sertifikat.

## Enam hal yang perlu Anda ketahui lebih dulu {#summary-six}

1. **Tempat semua kata sandi.** Semua kata sandi ada di satu file terkunci, `cv-demo-kredensial.kdbx`. Buka file ini dengan KeePassXC (lihat [bab 5](#access)). Kata sandi pembukanya diberikan terpisah.
2. **Ganti kata sandi dalam 7 hari.** Saat ini vendor masih mengetahuinya. [Bab 6](#credentials) menjelaskan caranya, dan [Lampiran E](#appendix-passwords) berisi daftar periksanya.
3. **Cara membuka halaman admin.** Gunakan browser web dan buka alamat di [bab 4](#apps), misalnya <https://traefik.demo.example.net/dashboard/>.
4. **Tidak ada backup.** Jika sebuah server hilang, datanya ikut hilang. Lihat [bab 7](#backup).
5. **Anda tidak menerima peringatan.** Tidak ada yang memantau sistem dan memberi tahu Anda saat terjadi kerusakan. Lihat [bab 8](#monitoring).
6. **Siapa yang dihubungi.** *Belum diisi*. Lihat [bab 11](#support).

## Lingkup pekerjaan {#summary-scope}

**Termasuk dalam pekerjaan ini:**

- 1 server yang dipasang dengan ansibro, beserta 2 program yang tercantum di atas.
- Dokumen ini, panduan laptop, berita acara serah terima (BAST), dan file kredensial.

**Tidak termasuk dalam pekerjaan ini:**

- *Belum diisi*

# Arsitektur {#architecture}

![Server dan aplikasi yang berjalan di atasnya](architecture.svg)

## Cluster dan ketersediaan tinggi {#architecture-ha}

Server ini berjalan sebagai *cluster* dengan satu anggota. Cluster adalah sekelompok server yang bekerja sebagai satu kesatuan; server lain dapat ditambahkan nanti.
Cluster dijalankan oleh *Docker Swarm*. Docker Swarm menjalankan setiap aplikasi di dalam *container* (aplikasi yang dikemas bersama semua kebutuhannya) dan menyalakannya kembali jika berhenti.
*Manager* adalah server yang mengendalikan cluster. Cluster tetap bekerja selama lebih dari separuh manager-nya menyala.

*Ketersediaan tinggi* (*high availability*, HA) berarti suatu bagian tetap bekerja walaupun satu server berhenti. Berikut tingkat HA setiap bagian:

| Bagian | Cara pemasangan | Jika satu server berhenti |
|:----------------|:--------------------------------------|:--------------------------------------|
| Manager cluster | 1 manager: srv | Cluster tidak dapat dikendalikan sampai manager menyala kembali |
| Pintu masuk web (Traefik) | Di srv | Tidak ada halaman web yang terbuka sampai server itu menyala kembali |
| Database (PostgreSQL) | Satu server: srv | Database berhenti sampai server menyala kembali |

## Bagaimana pengunjung sampai ke aplikasi {#architecture-traffic}

1. *DNS* (buku alamat internet) mengubah `nama-apa-saja.demo.example.net` menjadi alamat publik srv.
2. Browser terhubung ke *Traefik*, pintu masuk sistem, di port 443 (HTTPS). Port 80 hanya mengalihkan ke port 443.
3. Traefik memeriksa siapa yang boleh masuk. Setiap halaman punya satu *penjaga*:
   - **admin**: alamat pengunjung harus ada di daftar izin admin, lalu login admin meminta kata sandi;
   - **admin-ip**: alamat harus ada di daftar izin admin; setelah itu aplikasi menampilkan login-nya sendiri;
   - **public**: siapa saja boleh membukanya; aplikasi punya login sendiri, atau tanpa login.
4. Traefik meneruskan pengunjung ke aplikasi, di server mana pun aplikasi itu berjalan dalam cluster.

Daftar izin admin (`admin_allow_from`): siapa saja (daftarnya kosong).

## Manager pertama {#architecture-first}

`srv` adalah *manager pertama*. Server ini punya tugas yang tidak dimiliki server lain:

- ansibro dan uji penerimaannya menjalankan pemeriksaan dari server ini.
- Server ini menyimpan otoritas sertifikat (CA) untuk registry image privat.
- **Server ini tidak boleh dikeluarkan dari cluster.**

## Komponen {#architecture-components}

ansibro juga memasang bagian-bagian berikut. Bagian ini bukan aplikasi pilihan Anda, tetapi termasuk dalam sistem.

| Komponen | Lokasi | Port | Versi | Lisensi | Fungsi |
|:-----------|:------------|:-----|:-------------|:----------|:------------------------------------|
| registry | manager | 5000 | 3.1.2 | Apache-2.0 | Registry image pribadi di setiap manager. Semua server menarik image dari sini. |

# Server dan jaringan {#servers}

## Daftar server {#servers-list}

*IP cluster* adalah alamat yang dipakai antarserver. *Alamat SSH* adalah alamat tempat orang dan program instalasi login.

| Server | Peran | Tier | IP cluster | Alamat SSH | IP publik |
|:-----------|:-----------|:---------|:-------------|:--------------|:--------------|
| srv (manager pertama) | manager | data | 10.1.0.5 | 198.51.100.50 | sama dengan alamat SSH |

| Server | Penyedia | Region | Ukuran | Sistem operasi |
|:-----------|:---------------|:-------------|:---------------------------|:------------------|
| srv | *Belum diisi* | *Belum diisi* | *Belum diperiksa* | *Belum diperiksa* |

| Server | Sidik jari host key (ED25519) |
|:-----------|:--------------------------------------------------------------|
| srv | *Belum diperiksa* |

*Sidik jari host key* (*fingerprint*) memungkinkan Anda memastikan, saat login SSH pertama kali, bahwa Anda benar-benar terhubung ke server yang asli. [Bab 5](#access) menunjukkan cara membacanya.

Aplikasi yang berjalan di server tertentu (semua aplikasi lainnya berjalan di cluster):

| Server | Aplikasi |
|:-------------|:----------------------------------------------------------|
| srv | PostgreSQL |

## DNS {#servers-dns}

| Pengaturan | Nilai |
|:--------------------|:---------------------------------------------------|
| Mode | DNS publik |
| Record | `*.demo.example.net` (tipe A) |
| Mengarah ke | 198.51.100.50 (srv) |
| Penyedia DNS | *Belum diisi* |
| Pemilik domain | *Belum diisi* |
| CDN di depan server | tidak |

Dengan Let's Encrypt, Traefik hanya berjalan di srv, karena Let's Encrypt harus dapat menghubungi server yang meminta sertifikat.

## Sertifikat (TLS) {#servers-tls}

*Sertifikat* membuktikan kepada browser bahwa halaman itu benar-benar `demo.example.net`, sekaligus mengenkripsi koneksinya (*TLS*, huruf "s" pada https).

| Pengaturan | Nilai |
|:--------------------|:---------------------------------------------------|
| Mode | Let's Encrypt (sertifikat publik gratis, dibuat otomatis) |
| Penerbit | Let's Encrypt |
| Email kontak | admin@demo.example.net |
| Masa berlaku | Setiap sertifikat berlaku beberapa bulan; Traefik memperbaruinya sebelum habis |
| Pembaruan | Otomatis. DNS harus mengarah ke srv dan port 80 harus tetap terbuka |

## Firewall {#servers-firewall}

*Firewall* menentukan koneksi mana yang boleh masuk ke sebuah server. Setiap server menjalankan firewall *ufw*.

- ansibro yang mengelola firewall. ansibro menulis ulang aturannya setiap kali ada perubahan, dan **aturan yang ditambahkan manual akan terhapus**. Ubah daftar di bawah ini di `config.yml`, lalu jalankan `./install.sh`.
- Port yang dibuka oleh container Docker tidak melewati ufw.
- *Daftar izin* (*allow-list*) adalah daftar alamat internet yang boleh terhubung. Daftar kosong berarti siapa saja boleh terhubung.

| Daftar | Yang dijaga | Alamat | Milik |
|:----------------|:-------------------|:----------------------|:----------------------|
| `ssh.allow_from` | SSH ke semua server | **terbuka untuk siapa saja** | |
| `admin_allow_from` | halaman web admin | **terbuka untuk siapa saja** | |

> **Penting:** SSH terbuka untuk siapa saja di internet, dan halaman admin terbuka untuk siapa saja di internet (tetap meminta login). Rekomendasi: cantumkan alamat kantor dan staf Anda di `config.yml`, lalu jalankan `./install.sh`.

## Port {#servers-ports}

*Port* adalah pintu bernomor di sebuah server untuk satu jenis koneksi.

| Port | Fungsi | Di server | Terbuka untuk |
|:---------|:-------------------|:-------------------------|:-------------------------|
| 22/tcp | SSH | semua | siapa saja (daftarnya kosong) |
| 80, 443/tcp | Halaman web (Traefik) | srv | siapa saja; halaman admin juga memeriksa `admin_allow_from` |
| 5432/tcp | PostgreSQL | srv | hanya server lain dalam cluster |
| 5000/tcp | registry | srv | hanya server lain dalam cluster |

Database, cache, penyimpanan, dan antrean pesan diakses dari laptop melalui tunnel SSH (lihat [bab 5](#access)).

## Jaringan antarserver {#servers-wireguard}

WireGuard tidak aktif. Server-server berkomunikasi melalui IP cluster, dan ansibro tidak mengenkripsi lalu lintas tersebut. Hal ini aman di jaringan privat milik penyedia server.

## Waktu dan internet {#servers-time}

- Zona waktu: **UTC**. Jadwal backup dan log memakai zona waktu ini.
- Server memakai internet untuk mengunduh program dan menyamakan jam.

# Aplikasi {#apps}

## Gambaran umum {#apps-overview}

| Aplikasi | Fungsi | Berjalan di | Versi | Lisensi |
|:-----------|:-------------------------------|:-------------------|:-----------|:-----------|
| PostgreSQL | database | srv | 18.6 | PostgreSQL |
| Traefik | pintu masuk web | srv | v3.7.17 | MIT |

## Halaman web {#apps-web}

| Alamat | Aplikasi | Siapa yang dapat membuka | Login |
|:------------------------------------|:-----------|:--------------------|:--------------------|
| <https://traefik.demo.example.net/dashboard/> | Traefik | siapa saja | login Traefik (pengguna admin) |

## PostgreSQL {#app-postgres}

Database SQL untuk aplikasi Anda (dan untuk Kong, Keycloak, Authelia).

| Hal | Keterangan |
|:----------------|:-------------------------------------------------------|
| Berjalan di | srv |
| PostgreSQL | `10.1.0.5:5432` |
| Dari laptop | tunnel SSH ([bab 5](#access)) |
| Kredensial | `02 Database dan cache/PostgreSQL` |
| Data | `/opt/ansibro/postgres` di srv |
| Backup | Tidak disimpan |
| Pemeriksaan kesehatan | `pg_isready` |

- Dengan 2 server atau lebih, PostgreSQL berjalan dengan Patroni. Server utama (primary) bisa berpindah; aplikasi di cluster memakai database-proxy.
- Naik versi mayor (misalnya 18 ke 19) butuh dump dan restore manual.

## Traefik {#app-traefik}

Pintu masuk semua halaman web. Menerima HTTPS untuk domain dan meneruskan tiap subdomain ke aplikasinya, lengkap dengan sertifikat.

| Hal | Keterangan |
|:----------------|:-------------------------------------------------------|
| Berjalan di | srv |
| Halaman web | <https://traefik.demo.example.net/dashboard/> (login Traefik (pengguna admin)) |
| Dari laptop | browser web |
| Kredensial | `01 Login web/Traefik` |
| Data | `/opt/ansibro/traefik` |
| Backup | Tidak disimpan |
| Pemeriksaan kesehatan | `traefik healthcheck --ping` |

# Akses dari laptop Anda {#access}

Bab ini menunjukkan langkah demi langkah cara menjangkau sistem dari laptop Windows, macOS, atau Linux.

## Siapa butuh apa {#access-who}

Bagian ini menjelaskan, langkah demi langkah, cara menjangkau sistem dari komputer Anda sendiri. Bagian ini ditulis untuk Windows, macOS, Linux. Di Windows, perintah diketik di **PowerShell** (buka menu Start, ketik "PowerShell"). Di macOS dan Linux, perintah diketik di aplikasi **Terminal**. Setiap langkah menjelaskan apa tujuannya, apa yang diketik, apa yang seharusnya tampil, dan apa yang dilakukan bila gagal.

Perintah yang bertanda *(belum diuji)* belum pernah dicoba di laptop sungguhan. Bila salah satunya gagal, beri tahu vendor.

Tidak semua orang membutuhkan semua bagian. Cari peran Anda di tabel ini:

|                          | Pembaca (hanya halaman web)   | Operator (juga server)          | Penerus (menjalankan installer)  |
|:-------------------------|:------------------------------|:--------------------------------|:---------------------------------|
| Alat                     | Browser, KeePassXC | Sama, ditambah program SSH; alat database bila perlu | Sama, ditambah git, Python 3.12 atau lebih baru, age; hanya macOS atau Linux |
| Halaman web              | Ya                            | Ya                              | Ya                               |
| SSH dan tunnel           | Tidak                         | Ya                              | Ya                               |
| Menjalankan installer    | Tidak                         | Tidak                           | Ya                               |

Sebelum kunjungan pertama Anda, vendor melakukan dua hal untuk Anda:

1. Menambahkan alamat internet Anda ke daftar izin (allow-list), bila daftar itu dipakai (lihat [Alamat internet Anda](#access-ip)).
2. Memasang kunci SSH Anda di setiap server, bila Anda operator (lihat [SSH](#access-ssh)).

## Membuka file kredensial {#access-kdbx}

Semua kata sandi ada dalam satu file terenkripsi (teracak, hanya bisa dibaca dengan kuncinya), yaitu **cv-demo-kredensial.kdbx**. File ini dibuka dengan KeePassXC, aplikasi pengelola kata sandi yang gratis. Frasa sandi pembukanya (kata sandi berupa 7 kata) disampaikan kepada Anda secara terpisah. Frasa sandi itu tidak pernah dikirim dalam pesan yang sama atau di flashdisk yang sama dengan filenya.

### Memasang KeePassXC {#access-kdbx-install}

Tujuan: KeePassXC terpasang di komputer Anda.

Windows (PowerShell):

```powershell
winget install KeePassXCTeam.KeePassXC
```

macOS (Terminal):

```sh
brew install --cask keepassxc
```

Linux (Terminal):

```sh
sudo apt install keepassxc
```

Di Windows, Anda juga bisa mengunduh installer (MSI) dari <https://keepassxc.org/download>. Nama paket winget di atas *(belum diuji)*.
Di macOS, Anda juga bisa mengunduh DMG dari <https://keepassxc.org/download>. Saat pertama kali dijalankan, bila macOS menolak membukanya, klik kanan aplikasinya lalu pilih "Open".
Di Linux, pilihan lainnya adalah `sudo dnf install keepassxc` (Fedora) atau `flatpak install flathub org.keepassxc.KeePassXC`. Di Debian 13 dan Ubuntu 26.04, nama paketnya mungkin `keepassxc-full`.

Di ponsel, KeePassDX (Android), KeePassium atau Strongbox (iPhone) dapat membuka file ini untuk melihat isinya.

**Yang seharusnya tampil:** KeePassXC ada di daftar aplikasi Anda.

**Bila gagal:** di laptop kantor, Anda mungkin tidak diizinkan memasang aplikasi. Mintalah bantuan tim TI Anda, atau minta vendor memasangnya saat sesi serah terima.

### Memeriksa file {#access-kdbx-hash}

Tujuan: memastikan file yang Anda terima persis sama dengan yang tercantum di Berita Acara Serah Terima (BAST). Buka PowerShell atau Terminal di folder tempat file itu berada, lalu ketik:

Windows (PowerShell):

```powershell
Get-FileHash .\cv-demo-kredensial.kdbx -Algorithm SHA<size>
```

macOS (Terminal):

```sh
shasum -a <size> cv-demo-kredensial.kdbx
```

Linux (Terminal):

```sh
sha<size>sum cv-demo-kredensial.kdbx
```

**Yang seharusnya tampil:** kode panjang berisi 64 huruf dan angka. Kode itu harus sama dengan SHA-<size> milik cv-demo-kredensial.kdbx di Lampiran 3 BAST.

**Bila gagal:** bila kodenya berbeda, jangan pakai file itu. Mintalah salinan baru kepada vendor.

### Membuka file dan menyalin kata sandi {#access-kdbx-open}

Tujuan: membaca kata sandi tanpa mengetiknya dengan tangan.

1. Buka KeePassXC, pilih "Open Database", lalu pilih cv-demo-kredensial.kdbx.
2. Ketik 7 kata frasa sandi, dengan spasi di antara kata-katanya.
3. Pilih grup di sebelah kiri (misalnya "01 Login web"), lalu klik salah satu entri.
4. Salin kata sandinya dengan Ctrl+C (Cmd+C di Mac), lalu tempel di halaman login. KeePassXC menghapus isi clipboard (tempat salinan sementara) setelah beberapa detik.
5. File di dalam entri (lampiran) ada di bagian "Attachments" entri tersebut: klik kanan untuk menyimpannya.

Simpan cadangan file ini di flashdisk di tempat yang aman. Setelah serah terima, ganti frasa sandinya (menu "Database", lalu "Database Security") dan ganti kata sandi-kata sandinya dalam 7 hari, seperti dijelaskan dalam dokumen ini.

**Yang seharusnya tampil:** grup dan entri di dalam file.

**Bila gagal:** "Invalid credentials" berarti ada kata yang salah. Periksa ejaan dan spasinya, lalu coba lagi.

## Alamat internet Anda {#access-ip}

Tujuan: mengetahui alamat internet (alamat IP) koneksi Anda, karena sebagian halaman dan server hanya menerima alamat yang dikenal.

macOS dan Linux (Terminal):

```sh
curl -4 https://ifconfig.me
```

Windows (PowerShell):

```powershell
curl.exe -4 https://ifconfig.me
```

Anda juga bisa membuka <https://ifconfig.me> di browser. Layanan itu dijalankan oleh pihak ketiga.

**Yang seharusnya tampil:** empat angka yang dipisah titik, misalnya 198.51.100.7.

Sistem ini punya dua daftar alamat yang diizinkan (daftar izin atau allow-list):

| Daftar               | Yang dilindungi                        | Alamat yang diizinkan saat ini                |
|:---------------------|:---------------------------------------|:----------------------------------------------|
| `ssh.allow_from`     | SSH, login ke server (port 22) | Kosong: terbuka untuk siapa saja |
| `admin_allow_from`   | Halaman web admin                      | Kosong: terbuka untuk siapa saja |

Daftar yang kosong berarti sistem **terbuka untuk siapa saja** di internet: satu-satunya pelindung adalah kata sandi.

**Bila gagal:** hanya operator yang bisa menambahkan alamat: ia menambahkannya ke daftar di pengaturan installer (config.yml), lalu menjalankan installer lagi. Kirimkan alamat Anda kepada vendor atau operator Anda.

## Halaman web {#access-web}

### Memeriksa nama {#access-web-dns}

Tujuan: memastikan komputer Anda menemukan halaman web sistem di bawah demo.example.net.

macOS dan Linux (Terminal):

```sh
ping -c 1 traefik.demo.example.net
```

Windows (PowerShell):

```powershell
ping -n 1 traefik.demo.example.net
```

**Yang seharusnya tampil:** alamat 198.51.100.50. Itulah server yang melayani halaman web. Balasan ping tidak wajib: sebagian jaringan memblokir ping, tetapi alamatnya harus benar.

Nama-nama ini berasal dari DNS publik (semacam buku telepon internet), dengan satu catatan untuk setiap nama di bawah demo.example.net.

**Bila gagal:** "could not find host" berarti nama itu tidak dikenal. Minta vendor memeriksa catatan DNS-nya.

### Sertifikat {#access-web-tls}

Sertifikatnya berasal dari Let's Encrypt, sebuah otoritas publik. Browser Anda sudah memercayainya: tidak ada yang perlu dilakukan.

### Daftar halaman {#access-web-pages}

Tujuan: mengetahui halaman apa saja yang ada, siapa yang bisa membukanya, dan entri mana di file kredensial yang berisi loginnya.

| Alamat                                   | Aplikasi         | Siapa yang bisa membuka   | Login                       | Entri di file kredensial             |
|:-----------------------------------------|:-----------------|:--------------------------|:----------------------------|:-------------------------------------|
| <https://traefik.demo.example.net/dashboard/> | traefik | Siapa saja (daftar izin kosong) | Login admin (Traefik) | 01 Login web/Traefik |

**Yang seharusnya tampil:** halaman login aplikasi, atau lebih dulu login admin (Traefik).

**Bila gagal:** "403 Forbidden" berarti alamat internet Anda tidak ada di daftar izin admin (lihat [Alamat internet Anda](#access-ip)). Halaman yang tidak pernah termuat biasanya berarti ada masalah nama (lihat [Memeriksa nama](#access-web-dns)).

## SSH: login ke server {#access-ssh}

Bagian ini untuk operator. SSH (Secure Shell) adalah cara aman untuk mengetik perintah di server. Anda login dengan kunci: sepasang file, satu privat (tetap di laptop Anda) dan satu publik (dipasang di server). Kunci milik vendor sendiri tidak pernah diserahkan.

### Memeriksa program SSH {#access-ssh-client}

Tujuan: memastikan komputer Anda punya program OpenSSH.

Windows (PowerShell):

```powershell
ssh -V
```

macOS (Terminal):

```sh
ssh -V
```

Linux (Terminal):

```sh
ssh -V
```

**Yang seharusnya tampil:** sebuah versi, misalnya "OpenSSH_9.6".

**Bila gagal:** di Windows, pasang dari PowerShell yang dibuka sebagai administrator: `Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0`. Di Linux, pasang dengan `sudo apt install openssh-client`. macOS selalu sudah memilikinya. Gunakan OpenSSH, bukan PuTTY: PuTTY membutuhkan format kunci tersendiri.

### Membuat kunci sendiri {#access-ssh-key}

Tujuan: membuat pasangan kunci Anda, lalu mengirim hanya bagian publiknya (file berakhiran .pub) kepada vendor.

macOS dan Linux (Terminal):

```sh
mkdir -p ~/.ssh
ssh-keygen -t ed25519 -f ~/.ssh/cv-demo_ed25519 -C "your name"
```

Windows (PowerShell):

```powershell
New-Item -ItemType Directory -Force "$env:USERPROFILE\.ssh"
ssh-keygen -t ed25519 -f $env:USERPROFILE\.ssh\cv-demo_ed25519 -C "your name"
```

Saat diminta, pilih frasa sandi untuk kunci itu; frasa sandi melindungi kunci bila laptop Anda hilang. Ganti "your name" dengan nama Anda.

**Yang seharusnya tampil:** dua file baru: cv-demo_ed25519 (privat: jangan pernah dikirim) dan cv-demo_ed25519.pub (publik: kirim file ini kepada vendor).

**Bila gagal:** "No such file or directory" berarti folder .ssh belum ada: jalankan lagi baris pertama.

### Vendor memasang kunci Anda {#access-ssh-add}

Tujuan: vendor memasang kunci publik Anda di setiap server. ansibro tidak melakukan ini, jadi operator melakukannya dengan tangan, sekali per server, dengan aksesnya sendiri:

```sh
cat cv-demo_ed25519.pub | ssh -p 22 ubuntu@<server> \
  "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys \
  && chmod 600 ~/.ssh/authorized_keys"
```

`<server>` adalah setiap alamat di tabel berikutnya. Langkah ini adalah salah satu baris daftar uji terima (Lampiran 1 BAST).

### Menambahkan pengaturan SSH {#access-ssh-config}

Tujuan: memberi setiap server nama pendek, sehingga Anda cukup mengetik `ssh cv-demo-srv`. File **ssh_config.txt** dari paket serah terima berisi pengaturannya; tambahkan ke akhir file pengaturan SSH Anda:

macOS dan Linux (Terminal):

```sh
cat ssh_config.txt >> ~/.ssh/config
```

Windows (PowerShell):

```powershell
Get-Content .\ssh_config.txt |
  Add-Content -Encoding ascii "$env:USERPROFILE\.ssh\config"
```

Hasilnya adalah nama-nama berikut:

| Nama                        | Server          | Alamat            | Melalui                       |
|:----------------------------|:----------------|:------------------|:------------------------------|
| `cv-demo-srv` | srv | 198.51.100.50 | Langsung |

Setiap nama login sebagai ubuntu di port 22, dengan kunci ~/.ssh/cv-demo_ed25519.
Di macOS, Anda bisa menambahkan dua baris di bawah setiap baris `Host` agar frasa sandi kunci disimpan di Keychain: `UseKeychain yes` dan `AddKeysToAgent yes`.

**Yang seharusnya tampil:** baris-baris `Host` di akhir file.

**Bila gagal:** bila sebelumnya sudah ada `Host` dengan nama yang sama, hapus yang lama.

### Koneksi pertama {#access-ssh-first}

Tujuan: login sekali ke server pertama dan memastikan bahwa server itu asli.

macOS dan Linux (Terminal):

```sh
ssh cv-demo-srv
```

Windows (PowerShell):

```powershell
ssh cv-demo-srv
```

Pada koneksi pertama, SSH menampilkan sidik jari (fingerprint) server, yaitu kode yang diawali SHA256:, lalu bertanya apakah akan dilanjutkan. Bandingkan dengan tabel ini, lalu ketik `yes`. Bila berbeda, ketik `no` dan hubungi vendor.

| Server          | Sidik jari kunci host                                                         |
|:----------------|:------------------------------------------------------------------------------|
| srv | Belum diperiksa |

Sidik jari ini belum diperiksa oleh uji terima. Minta vendor membacakannya dari setiap server dengan `ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub`.

**Yang seharusnya tampil:** prompt seperti `ubuntu@srv:~$`. Ketik `exit` untuk keluar. Perintah untuk sistem perlu diawali `sudo`, karena file-filenya di /opt/ansibro milik administrator (root).

**Bila gagal:**

- "Permission denied (publickey)": kunci Anda belum terpasang di server itu, atau nama file kuncinya salah.
- "Connection timed out": alamat Anda tidak ada di ssh.allow_from, atau firewall penyedia server memblokir port 22.
- "UNPROTECTED PRIVATE KEY FILE": file kunci bisa dibaca orang lain. Perbaiki dengan:

macOS dan Linux (Terminal):

```sh
chmod 600 ~/.ssh/cv-demo_ed25519
```

Windows (PowerShell):

```powershell
icacls $env:USERPROFILE\.ssh\cv-demo_ed25519 /inheritance:r `
  /grant:r "$($env:USERNAME):(R)"
```

### Mengingat frasa sandi kunci {#access-ssh-agent}

Tujuan: mengetik frasa sandi kunci sekali per sesi, tidak di setiap login.

Windows (PowerShell):

```powershell
Get-Service ssh-agent | Set-Service -StartupType Automatic
Start-Service ssh-agent
ssh-add $env:USERPROFILE\.ssh\cv-demo_ed25519
```

macOS (Terminal):

```sh
ssh-add --apple-use-keychain ~/.ssh/cv-demo_ed25519
```

Linux (Terminal):

```sh
ssh-add ~/.ssh/cv-demo_ed25519
```

Di Windows, dua baris pertama perlu PowerShell yang dibuka sebagai administrator.

**Yang seharusnya tampil:** "Identity added".

**Bila gagal:** "Could not open a connection to your authentication agent" berarti agent (program penyimpan kunci) tidak berjalan: jalankan baris-baris Windows di atas sebagai administrator.

## Database dan layanan lain: tunnel SSH {#access-tunnel}

Database dan layanan sejenis hanya mendengarkan di dalam cluster (kumpulan server), dan lalu lintas datanya tidak terenkripsi. Untuk menjangkaunya, Anda membuka tunnel SSH: pipa pribadi melalui SSH dari laptop Anda ke server. Tunnel ini sekaligus mengenkripsi lalu lintasnya.

### Menjalankan tunnel {#access-tunnel-start}

Tujuan: membuka semua pipa sekaligus dengan nama `cv-demo-tunnel` dari ssh_config.txt.

macOS dan Linux (Terminal):

```sh
ssh -N cv-demo-tunnel
```

Windows (PowerShell):

```powershell
ssh -N cv-demo-tunnel
```

Biarkan jendela ini terbuka selama Anda bekerja; tutup (Ctrl+C) bila sudah selesai. Lalu hubungkan alat Anda ke 127.0.0.1 (laptop Anda sendiri) dan port di tabel ini:

| Layanan              | Server        | Di server                | Di laptop Anda          |
|:---------------------|:--------------|:-------------------------|:------------------------|
| PostgreSQL | srv | 10.1.0.5:5432 | 127.0.0.1:15432 |

**Yang seharusnya tampil:** tidak ada apa-apa: tidak ada prompt, dan jendelanya tetap terbuka. Itu berarti tunnel bekerja.

**Bila gagal:** "Address already in use" atau "port forwarding failed" berarti ada program lain di laptop Anda yang memakai port itu. Tutup program tersebut, atau ubah angka pertama pada baris `LocalForward` yang bersangkutan di pengaturan SSH Anda.

### Menghubungkan alat Anda {#access-tunnel-tools}

Tujuan: memakai database atau layanan melalui tunnel. Kata sandinya ada di grup "02 Database dan cache" di file kredensial.

PostgreSQL:

macOS dan Linux (Terminal):

```sh
psql "host=127.0.0.1 port=15432 user=postgres"
```

Windows (PowerShell):

```powershell
psql "host=127.0.0.1 port=15432 user=postgres"
```

Program berjendela (DBeaver, TablePlus, RedisInsight, WinSCP, Cyberduck) bekerja dengan cara yang sama: jalankan tunnel, lalu hubungkan ke host 127.0.0.1 dan port laptop. Program-program itu juga bisa membuat tunnel sendiri: di pengaturan SSH-nya, pakai host 198.51.100.50, port 22, user ubuntu dan file kunci Anda; lalu hubungkan ke alamat "Di server" dari tabel.

**Yang seharusnya tampil:** alat terhubung dan meminta kata sandi, atau langsung menampilkan data.

**Bila gagal:** "connection refused" berarti tunnel tidak berjalan. Jalankan lagi di jendelanya sendiri.

## Mengelola cluster {#access-cluster}

### Docker Swarm {#access-cluster-swarm}

Tujuan: melihat dan mengelola aplikasi yang berjalan (service).

Dari baris perintah, di server pertama:

macOS dan Linux (Terminal):

```sh
ssh -t cv-demo-srv sudo docker service ls
```

Windows (PowerShell):

```powershell
ssh -t cv-demo-srv sudo docker service ls
```

**Yang seharusnya tampil:** daftar service, masing-masing dengan "REPLICAS" seperti 1/1.

**Bila gagal:** lihat [SSH](#access-ssh). Koneksi Docker jarak jauh (`docker context create cv-demo --docker host=ssh://cv-demo-srv`) hanya bekerja bila user SSH boleh memakai Docker tanpa sudo. ansibro tidak mengatur hal ini, dan akses itu memberi kendali penuh atas server, jadi vendor yang memutuskan.

### Image milik Anda sendiri {#access-cluster-images}

Tujuan: menjalankan image (paket aplikasi siap jalan) milik Anda sendiri. Registry image (registry.ansibro:5000) hanya bisa dijangkau dari server, jadi Anda mengirim image lewat SSH lalu mendorongnya (push) di server pertama:

macOS dan Linux (Terminal):

```sh
docker save app:1 | ssh cv-demo-srv "sudo docker load"
ssh cv-demo-srv "sudo docker tag app:1 registry.ansibro:5000/app:1 && \
  sudo docker push registry.ansibro:5000/app:1"
```

Windows (PowerShell):

```powershell
docker save app:1 | ssh cv-demo-srv "sudo docker load"
ssh cv-demo-srv ("sudo docker tag app:1 registry.ansibro:5000/app:1 && " +
  "sudo docker push registry.ansibro:5000/app:1")
```

`app:1` adalah nama dan versi image Anda. Di Mac dengan Apple Silicon, buat image dengan `--platform linux/amd64`: server memakai prosesor Intel atau AMD. Registry tidak termasuk dalam backup: setelah pemulihan (restore), push lagi image Anda.

## Mengatasi masalah {#access-trouble}

| Masalah                                 | Yang perlu dilakukan                                                  |
|:----------------------------------------|:----------------------------------------------------------------------|
| "403 Forbidden" di halaman web          | Alamat Anda tidak ada di daftar izin admin. Lihat [Alamat internet Anda](#access-ip). |
| Peringatan sertifikat                   | Lihat [Sertifikat](#access-web-tls). |
| SSH: "Connection timed out"             | Alamat Anda tidak ada di ssh.allow_from, atau firewall penyedia server memblokir port-nya. |
| SSH: "Permission denied (publickey)"    | Kunci Anda belum terpasang di server itu, atau nama file kunci di pengaturan salah. |
| Tunnel: "Address already in use"        | Ada program lain yang memakai port laptop itu. Tutup program itu, atau ganti port-nya. |
| Tidak ada lagi yang bisa login ke server | Operator membuka konsol web penyedia server, menjalankan `sudo ufw disable`, memperbaiki daftar, lalu menjalankan installer lagi. |

Bila Anda buntu, hubungi vendor. Jangan pernah mengirim kata sandi lewat email atau chat.

Kontak dukungan: Belum diisi.

# Kredensial dan penggantian kata sandi {#credentials}

## File kredensial {#credentials-file}

Semua kata sandi ada di satu file terkunci, `cv-demo-kredensial.kdbx`. File ini berformat KeePass. Buka file ini dengan KeePassXC ([bab 5](#access)).
Kata sandi pembuka file ini (*frasa sandi* atau *passphrase*) dikirim terpisah. Dokumen ini maupun berita acara serah terima tidak memuat kata sandi apa pun.

File ini berisi kelompok berikut:

| Kelompok | Isinya | Siapa yang memerlukan |
|:-------------------------------|:------------------------------------------|:-------------------|
| 01 Login web | Traefik | semua yang mengelola halaman web |
| 02 Database dan cache | PostgreSQL | operator |
| 04 Infrastruktur | Image registry | operator |
| 06 Internal (menjalankan ulang ansibro) | 2 kata sandi teknis, ditambah file "ansibro installer files" (untuk menjalankan ulang ansibro) | hanya untuk menjalankan ulang ansibro |
| 07 Lama (aplikasi yang sudah dihapus) | NATS | tidak ada (sisa aplikasi yang sudah dihapus) |

## Akun {#credentials-accounts}

Berikut akun yang dipakai orang. Kolom kelas menunjukkan cara mengganti kata sandinya (lihat bagian berikutnya).

| Akun | Untuk | Entri di file kredensial | Cara mengganti | Batas waktu |
|:----------------|:-----------|:------------------------------|:----------------|:-----------|
| PostgreSQL | pemakaian harian | `02 Database dan cache/PostgreSQL` | Aplikasi dan file bersamaan (belum diuji) | dalam 7 hari |
| Image registry | pemulihan | `04 Infrastruktur/Image registry` | Aplikasi dan file bersamaan | saat akses vendor berakhir |
| Traefik | pemakaian harian | `01 Login web/Traefik` | File dulu | dalam 7 hari |
| Frasa sandi file kredensial | semua | (file itu sendiri) | KeePassXC | dalam 7 hari |

## Cara mengganti kata sandi {#credentials-change}

ansibro menyimpan salinan semua kata sandi di folder `state/` pada komputer yang menjalankan program instalasi. Salinan ini dipakai setiap kali ansibro dijalankan. Karena itu, kata sandi harus diganti di tempat yang benar. Jika tidak, instalasi berikutnya akan membatalkan perubahan Anda atau gagal.

### File dulu {#credentials-file-first}

Berlaku untuk: Traefik.
ansibro menulis kata sandi ini ke aplikasi setiap kali dijalankan. Perubahan yang hanya dilakukan di aplikasi akan dibatalkan pada instalasi berikutnya.

1. Di komputer instalasi, tulis kata sandi baru di file `state/secrets/<name>`.
2. Jalankan `./install.sh`.
3. Perbarui file kredensial, juga setiap aplikasi milik Anda yang memakai kata sandi ini.

### Aplikasi dan file bersamaan {#credentials-both}

Berlaku untuk: PostgreSQL, Image registry.
ansibro login dengan kata sandi ini, atau kata sandi ini diperlukan untuk pemulihan. Jika hanya satu tempat yang diubah, instalasi berikutnya gagal.

1. Ganti kata sandi di aplikasi.
2. Pada saat yang sama, tulis kata sandi yang sama di `state/secrets/<name>` pada komputer instalasi.
3. Jalankan `./install.sh`, lalu uji penerimaan (`tests/check.py`).
4. Perbarui file kredensial.

- PostgreSQL: cara aplikasi menerima kata sandi baru belum diuji, jadi perlakukan sebagai "aplikasi dan file bersamaan".

### Jangan diubah {#credentials-internal}

Kata sandi di kelompok "06 Internal (menjalankan ulang ansibro)" hanya dipakai antarprogram. Tidak ada orang yang mengetiknya. Ganti hanya jika bocor, dan serahkan kepada operator ansibro.

> **Penting:** file ringkasan milik ansibro menyebut "ganti di aplikasi, lalu perbarui juga filenya". Petunjuk itu salah untuk kelas "file dulu" dan "aplikasi dan file bersamaan". Ikuti bab ini.

## Siapa yang memegang state/ {#credentials-state}

**Vendor memegang `state/`** (salinan kata sandi milik program instalasi).
Setelah Anda mengganti kata sandi kelas "file dulu" atau "aplikasi dan file bersamaan", kirim nilai barunya kepada vendor **di dalam file kredensial dengan frasa sandi tersendiri**, jangan lewat email atau chat. Jika tidak, instalasi berikutnya oleh vendor akan membatalkan perubahan Anda ("file dulu") atau gagal ("aplikasi dan file bersamaan").

## Mengakhiri akses vendor {#credentials-revoke}

Tanggal yang direncanakan: *Belum diisi*. Pada tanggal itu:

1. Hapus kunci SSH vendor dari `~/.ssh/authorized_keys` milik pengguna `ubuntu` di setiap server. ansibro tidak mengelola kunci SSH.
2. Hapus alamat vendor dari `ssh.allow_from` dan `admin_allow_from` di `config.yml`, lalu jalankan `./install.sh`.
3. Ganti kata sandi seperti dijelaskan di atas.
5. Vendor menghapus salinan `state/` miliknya setelah Anda setujui.

## Mengganti frasa sandi file kredensial {#credentials-passphrase}

Di KeePassXC: menu **"Database → Database Security"**, lalu atur kata sandi baru. (Di KeePass 2: **"File → Change Master Key"**.) Simpan salinan cadangan file ini di tempat yang aman.

## Menambah staf {#credentials-staff}

- Tambahkan alamat internetnya ke `admin_allow_from` (halaman web) dan `ssh.allow_from` (SSH, khusus operator) di `config.yml`, lalu jalankan `./install.sh`.
- Untuk operator: tambahkan kunci publik SSH-nya ke `~/.ssh/authorized_keys` milik `ubuntu` di setiap server.

# Backup dan pemulihan {#backup}

*Backup* adalah salinan data yang disimpan di tempat lain, agar data dapat dikembalikan (*dipulihkan*, *restore*) setelah hilang.

> **Penting:** **tidak ada backup.** Jika sebuah server rusak, datanya hilang untuk selamanya. Rekomendasi: tambahkan bagian `backup:` di `config.yml` dengan tempat penyimpanan di luar server-server ini, lalu jalankan `./install.sh`.

# Pemantauan dan peringatan {#monitoring}

*Pemantauan* (*monitoring*) mengawasi server dan aplikasi. *Peringatan* (*alert*) adalah pesan yang dikirim saat ada masalah.

> **Penting:** **Anda tidak menerima peringatan.** Tidak ada aplikasi pemantauan yang dipasang, sehingga tidak ada yang diberi tahu saat server atau aplikasi rusak.

# Panduan operasional {#runbook}

## Aturan utama {#runbook-rules}

1. **Setiap perubahan dilakukan melalui `config.yml`,** lalu jalankan `./install.sh`. Perintah ini hanya mengubah yang berbeda, dan aman dijalankan ulang setelah gagal.
2. **Selalu jalankan dari komputer yang menyimpan `state/`.** Di komputer lain, ansibro membuat kata sandi baru yang tidak cocok dengan sistem yang berjalan.
3. `--check` (uji coba tanpa perubahan) tidak didukung.

**Siapa yang dapat menjalankan program instalasi:** komputer macOS atau Linux dengan Python 3.12 atau lebih baru, ansibro 1.2.0, `config.yml`, dan `state/`. Saat ini: Vendor.

## Prosedur {#runbook-procedures}

Semua perintah di server dijalankan setelah login SSH (lihat [bab 5](#access)). `/opt/ansibro` milik root, jadi perintahnya memakai `sudo`.

### Menambah atau menghapus aplikasi {#runbook-app}

- **Menambah:** tambahkan aplikasi di bagian `apps:` pada `config.yml`, lalu jalankan `./install.sh`.
- **Menghapus:** hapus aplikasi dari `config.yml`, lalu jalankan `./install.sh`. Aplikasi berhenti; datanya tetap di `/opt/ansibro/<app>` sampai Anda menghapusnya dengan `sudo rm -rf`.
- **Memeriksa:** `tests/check.py`.

### Menambah atau menghapus server {#runbook-server}

- **Menambah:** tambahkan server di `nodes:` **setelah** srv, lalu jalankan `./install.sh`.
- **Menghapus:** pindahkan dulu aplikasinya, hapus server dari `config.yml`, lalu jalankan:

  ```sh
  ./install.sh -e remove_nodes=true
  ```

- **Jangan pernah menghapus srv.**

### Menaikkan atau menurunkan peran server {#runbook-promote}

Di srv: `sudo docker node promote <name>` (worker menjadi manager) atau `sudo docker node demote <name>`.

### Memperbarui aplikasi atau Docker {#runbook-upgrade}

1. Di `versions.yml`, ubah tag **dan** digest aplikasi. Baca digest-nya dengan `docker buildx imagetools inspect <image>:<tag>`.
2. Jalankan `./install.sh`. Docker diperbarui satu server demi satu server.
3. Pembaruan versi besar PostgreSQL (misalnya 18 ke 19) memerlukan dump dan restore manual.

### Mengambil ulang sertifikat Let's Encrypt {#runbook-certs}

DNS harus benar dan port 80 terbuka. Di srv:

```sh
sudo docker service update --force traefik_traefik
```

### Menyalakan ulang aplikasi {#runbook-restart}

- Aplikasi cluster: `sudo docker service update --force <stack>_<service>` di srv. Lihat daftar layanannya dengan `sudo docker service ls`.
- Aplikasi di server tertentu: `cd /opt/ansibro/<app> && sudo docker compose restart` di server itu.

### Setelah server dinyalakan ulang {#runbook-reboot}

- Aplikasi menyala dengan sendirinya. Backup yang terlewat dijalankan saat server menyala.

### Terkunci dari SSH {#runbook-locked}

Buka konsol server di halaman web penyedia server, login, lalu jalankan `sudo ufw disable`. Setelah itu perbaiki `ssh.allow_from` dan jalankan `./install.sh` (firewall akan aktif kembali).

### Batas Docker Hub (toomanyrequests) {#runbook-dockerhub}

Tunggu beberapa saat, atau login ke Docker Hub dengan `sudo docker login` di srv.

### Label server {#runbook-labels}

ansibro hanya menambah label. Hapus label dengan `sudo docker node update --label-rm <label> <name>`.

## Yang tidak dikerjakan ansibro {#runbook-not}

| Pekerjaan | Penanggung jawab yang disarankan |
|:------------------------------------|:------------------------------------------|
| Pembaruan keamanan sistem operasi | Operator CV Demo, atau tim dukungan |
| Memperbarui ansibro itu sendiri | pemegang `state/` (Vendor) |
| Memperbarui sertifikat registry (berlaku 10 tahun sejak instalasi pertama) | pemegang `state/` |
| Menambah dan menghapus kunci SSH | Operator CV Demo |

# Keamanan {#security}

## Apa yang terbuka ke internet {#security-exposure}

Tidak ada halaman web yang terbuka untuk siapa saja tanpa login.

Siapa yang dapat menjangkau sisanya:

- SSH: siapa saja (daftarnya kosong).
- Halaman admin: siapa saja (daftarnya kosong).

## Lalu lintas di dalam cluster {#security-plaintext}

Layanan berikut berkomunikasi tanpa enkripsi, sehingga hanya terbuka untuk server dalam cluster: PostgreSQL.

## Salinan kata sandi di server {#security-copies}

Server menyimpan salinan kata sandi yang hanya dapat dibaca oleh root:

- File `.env` di `/opt/ansibro/<app>/` untuk aplikasi yang memakainya.
- `/root/.docker/config.json` (login registry).

Jadi siapa pun yang punya akses root di srv, memiliki semua kata sandi.
Di komputer instalasi, `state/` **tidak terenkripsi**. Rekomendasi: aktifkan enkripsi ansibro (age).

## Kunci SSH {#security-ssh}

*Kunci SSH* adalah sepasang file yang memungkinkan seseorang login tanpa kata sandi. ansibro tidak menambah atau menghapus kunci SSH. Siapa yang boleh login ditentukan oleh daftar di `~/.ssh/authorized_keys` milik `ubuntu` di setiap server; jaga daftar itu tetap pendek dan hapus kunci orang yang sudah tidak bertugas.

## Masa berlaku sertifikat {#security-certs}

| Sertifikat | Berakhir |
|:------------------------------|:------------------------------------------|
| Halaman web (Let's Encrypt) | diperbarui otomatis |
| Registry image (internal) | 10 tahun setelah instalasi pertama |

# Dukungan {#support}

Kontak: *Belum diisi*.

| Hal | Keterangan |
|:--------------------|:---------------------------------------------------|
| Perusahaan | *Belum diisi* |
| Telepon | *Belum diisi* |
| Email | *Belum diisi* |
| Situs web | *Belum diisi* |
| Jam layanan | *Belum diisi* |
| Waktu respons | *Belum diisi* |
| Garansi | *Belum diisi* |
| Cakupan garansi | *Belum diisi* |
| Akses vendor berakhir | *Belum diisi* |

**Cara melaporkan masalah.** Sebutkan apa yang Anda lihat, kapan mulai terjadi, halaman atau server mana, dan apa yang sudah Anda coba. Tangkapan layar sangat membantu.

> **Penting:** jangan pernah mengirim kata sandi di laporan, email, atau chat. Tim dukungan tidak pernah memintanya.

# Uji penerimaan {#acceptance}

ansibro punya *uji penerimaan* sendiri (`tests/check.py`). Uji ini login ke setiap aplikasi dan memeriksa cluster, backup, serta pemantauan.

Uji penerimaan **tidak dijalankan** untuk dokumen ini, sehingga belum ada hasil yang tercatat. Jalankan uji ini sebelum menandatangani berita acara serah terima.

Berita acara serah terima memuat daftar periksa untuk sesi serah terima (lampiran pertamanya): setiap halaman web terbuka, setiap login berfungsi, 2FA sudah didaftarkan, file kredensial dapat dibuka, akses dari laptop berfungsi, ada backup terbaru, dan peringatan uji coba diterima.

# Lampiran A. Versi perangkat lunak {#appendix-versions .unnumbered}

| Aplikasi | Image | Tag | Digest |
|:-----------|:--------------------------------------|:-----------------|:-------------|
| PostgreSQL | `docker.io/library/postgres` | 18.6 | `979bccfde354` |
| Traefik | `docker.io/library/traefik` | v3.7.17 | `30ff62491aac` |

| Komponen | Versi |
|:--------------------|:---------------------------------------------------|
| registry | 3.1.2 |
| docker-ce | 29.9.2-1 |
| docker-ce-cli | 29.9.2-1 |
| containerd.io | 2.4.2-3 |
| docker-buildx-plugin | 0.38.1-1 |
| docker-compose-plugin | 5.6.1-1 |
| ansibro | 1.2.0 |
| dejavu | 1.1.0 |

Digest adalah 12 karakter pertama sidik jari image (sha256). Digest memastikan image yang dipakai persis sama.

# Lampiran B. Lisensi {#appendix-licenses .unnumbered}

Semua bagian sistem ini adalah perangkat lunak sumber terbuka (open source).

| Bagian | Lisensi |
|:-----------------|:------------------------------------------------------|
| PostgreSQL | PostgreSQL |
| Traefik | MIT |
| registry | Apache-2.0 |

# Lampiran C. Konfigurasi {#appendix-config .unnumbered}

Berikut `config.yml` sebagaimana dibaca oleh ansibro, disusun ulang oleh dejavu. Komentar di file aslinya hilang, sebagian nilai adalah nilai bawaan, dan setiap rahasia diganti dengan lokasinya di file kredensial. Komentar di dalam blok di bawah ini sengaja dibiarkan dalam bahasa Inggris, seperti di file aslinya.

```yaml
domain: demo.example.net
orchestrator: swarm
tls: letsencrypt
acme_email: admin@demo.example.net
timezone: UTC
ssh:
  user: ubuntu
  port: 22
  key: <your SSH private key>
nodes:
  - {name: srv, ip: 10.1.0.5, host: 198.51.100.50, role: manager}
apps:
  postgres: srv
  traefik: swarm
```

# Lampiran D. Pengaturan SSH {#appendix-ssh .unnumbered}

Baris-baris berikut dimasukkan ke file pengaturan SSH di laptop (`~/.ssh/config`; di Windows `%USERPROFILE%\.ssh\config`). Baris yang sama ada di file `ssh_config.txt`.

```text
# SSH settings for CV Demo (demo.example.net), made by dejavu 1.1.0.
# Add these lines to ~/.ssh/config (Windows: %USERPROFILE%\.ssh\config).
# The key file is your own key (or the one from the credentials file), never the vendor's.

Host cv-demo-srv
  HostName 198.51.100.50
  User ubuntu
  Port 22
  IdentityFile ~/.ssh/cv-demo_ed25519
  IdentitiesOnly yes

# A private pipe to the databases and other services: run "ssh -N cv-demo-tunnel" and keep it open.
# Then connect to 127.0.0.1 and the local port below.
Host cv-demo-tunnel
  HostName 198.51.100.50
  User ubuntu
  Port 22
  IdentityFile ~/.ssh/cv-demo_ed25519
  IdentitiesOnly yes
  ExitOnForwardFailure yes
  # PostgreSQL on srv
  LocalForward 15432 10.1.0.5:5432
```

# Lampiran E. Daftar periksa penggantian kata sandi {#appendix-passwords .unnumbered}

Centang setiap kata sandi yang sudah diganti, paling lambat 7 hari setelah serah terima. [Bab 6](#credentials) menjelaskan caranya.

| Cek | Akun | Entri di file kredensial | Diganti pada | Oleh |
|:----|:-------------------|:------------------------------|:-------------|:-------------|
| `☐` | PostgreSQL | `02 Database dan cache/PostgreSQL` | | |
| `☐` | Image registry | `04 Infrastruktur/Image registry` | | |
| `☐` | Traefik | `01 Login web/Traefik` | | |
| `☐` | Frasa sandi file kredensial | | | |

# Lampiran F. Masalah yang diketahui dan rekomendasi {#appendix-issues .unnumbered}

- **Kata sandi dari aplikasi yang sudah dihapus (`nats`).** Kata sandi ini disimpan di kelompok "07 Lama (aplikasi yang sudah dihapus)" pada file kredensial, jadi tidak ada yang hilang. Kata sandi ini boleh dihapus jika Anda setuju.
- **Daftar izin `ssh.allow_from` kosong.** SSH dapat dijangkau dari alamat internet mana pun. Rekomendasi: cantumkan alamat kantor dan staf Anda.
- **Daftar izin `admin_allow_from` kosong.** Halaman admin dapat dijangkau dari alamat internet mana pun. Rekomendasi: cantumkan alamat kantor dan staf Anda.
- **Tidak ada backup.** Server yang hilang berarti data yang hilang. Rekomendasi: tambahkan backup ke tempat penyimpanan di luar server-server ini.
- **Tidak ada pemantauan.** Anda tidak menerima peringatan. Rekomendasi: pasang Beszel atau Victoria monitoring.

# Lampiran G. Sumber data {#appendix-sources .unnumbered}

Setiap fakta dalam dokumen ini berasal dari salah satu sumber berikut. dejavu tidak pernah membuka file kata sandi. Nama sumber ditulis dalam bahasa Inggris, seperti yang dicatat oleh dejavu.

| Fakta | Sumber |
|:------------------------------------------|:------------------------------------------|
| nodes, apps, domain, tls, ssh, allow-lists, backup, monitoring, versions | inventory.py --list |
| traefik_nodes, admin_sso, database, cache, monitoring app | group_vars/all.yml (ansible debug) |
| alerts | roles/observability/files/alerts.yml |
| pages, ports, data, backup kind, change of passwords | dejavu assets/apps.yml |
| secret names | state/secrets (names only) |
| last install | the date of state/summary.md (never opened) |
| ansibro version | git describe / CHANGELOG.md |
| nama, tanggal, kontak, lingkup, catatan | jawaban vendor (`handover.yml`) |

# Lampiran H. Glosarium {#appendix-glossary .unnumbered}

| Istilah | Arti |
|:-----------------|:----------------------------------------------------------------|
| 2FA | Login dua faktor: kata sandi ditambah kode dari aplikasi di ponsel Anda. |
| ansibro | Program instalasi yang memasang sistem ini. |
| Aplikasi autentikator | Aplikasi di ponsel yang menampilkan kode 6 angka baru setiap 30 detik. |
| Backup | Salinan data yang disimpan di tempat lain. |
| Cluster | Sekelompok server yang bekerja sebagai satu kesatuan. |
| Container | Aplikasi yang dikemas bersama semua kebutuhannya, sehingga berjalan sama di mana pun. |
| Daftar izin (allow-list) | Daftar alamat internet yang boleh terhubung. Jika kosong, siapa saja boleh. |
| DNS | Buku alamat internet: mengubah nama menjadi alamat server. |
| Docker Swarm | Program yang menjalankan container di seluruh cluster. |
| File kredensial | File KeePass (`.kdbx`) terkunci yang menyimpan semua kata sandi. |
| Firewall | Penyaring yang menentukan koneksi mana yang boleh masuk ke server. |
| Frasa sandi (passphrase) | Kata sandi untuk membuka file kredensial. |
| Image | Bentuk kemasan sebuah aplikasi, tempat container dijalankan. |
| KeePassXC | Program gratis untuk membuka file kredensial. |
| Ketersediaan tinggi (HA) | Suatu bagian tetap bekerja walaupun satu server berhenti. |
| Kunci SSH | Sepasang file yang memungkinkan seseorang login tanpa kata sandi. |
| Manager | Server yang mengendalikan cluster. |
| Pemulihan (restore) | Mengembalikan data dari backup. |
| Peringatan (alert) | Pesan yang dikirim saat ada masalah. |
| Port | Pintu bernomor di server untuk satu jenis koneksi. |
| restic | Program backup. |
| Sertifikat | File yang membuktikan sebuah halaman web asli dan mengenkripsi koneksinya. |
| Snapshot | Satu backup lengkap pada satu waktu tertentu. |
| SSH | Cara aman untuk login ke server dan mengetik perintah di sana. |
| state/ | Folder milik program instalasi yang berisi salinan semua kata sandi. |
| TLS | Enkripsi halaman web (huruf "s" pada https). |
| Traefik | Pintu masuk semua halaman web. |
| Tunnel | Jalur privat melalui SSH dari laptop ke sebuah layanan di server. |
| ufw | Program firewall di setiap server. |
