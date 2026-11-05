---
title: "Panduan Akses Laptop"
subtitle: "macOS · Produksi"
short-title: "Panduan Akses Laptop (macOS)"
lang: id
region: ID
docnumber: "001/DOK/NUSA/XI/2026"
version: "1.0"
date: "4 November 2026"
classification: "TERBATAS"
numbered: true
labels: {page: "Halaman", of: "dari", toc: "Daftar Isi"}
cover:
  kicker: "PANDUAN AKSES LAPTOP"
  rows:
    - {label: "Klien", value: "PT Maju Bersama"}
    - {label: "Vendor", value: "PT Nusantara Teknologi"}
    - {label: "Sistem", value: "Produksi (apps.internal.example)"}
    - {label: "Laptop", value: "macOS"}
    - {label: "Nomor dokumen", value: "001/DOK/NUSA/XI/2026"}
    - {label: "Versi", value: "1.0"}
    - {label: "Tanggal", value: "4 November 2026"}
    - {label: "Klasifikasi", value: "TERBATAS"}
  footer: "Dibuat dengan dejavu 1.0.0 dari ansibro 1.2.0. Panduan ini tidak memuat kata sandi; semua kata sandi hanya ada di file kredensial yang terenkripsi."
---

# Akses dari laptop (macOS) {#guide}

Panduan ini menjelaskan cara menjangkau Produksi (apps.internal.example) milik PT Maju Bersama dari laptop macOS: halaman web, kata sandi, dan, bagi operator, server. Panduan ini bagian dari serah terima oleh PT Nusantara Teknologi. Rincian lengkapnya ada di dokumentasi teknis.

Panduan ini ditujukan untuk: Siti Rahma.

Anda memerlukan file-file ini dari paket serah terima: file kredensial, ssh_config.txt, maju-ca.crt, serta frasa sandi pembuka file kredensial, yang disampaikan kepada Anda secara terpisah.

## Siapa butuh apa {#access-who}

Bagian ini menjelaskan, langkah demi langkah, cara menjangkau sistem dari komputer Anda sendiri. Bagian ini ditulis untuk macOS. Di macOS, perintah diketik di aplikasi **Terminal**. Setiap langkah menjelaskan apa tujuannya, apa yang diketik, apa yang seharusnya tampil, dan apa yang dilakukan bila gagal.

Perintah yang bertanda *(belum diuji)* belum pernah dicoba di laptop sungguhan. Bila salah satunya gagal, beri tahu vendor.

Tidak semua orang membutuhkan semua bagian. Cari peran Anda di tabel ini:

|                          | Pembaca (hanya halaman web)   | Operator (juga server)          | Penerus (menjalankan installer)  |
|:-------------------------|:------------------------------|:--------------------------------|:---------------------------------|
| Alat                     | Browser, KeePassXC | Sama, ditambah program SSH; alat database bila perlu | Sama, ditambah git, Python 3.12 atau lebih baru, age; hanya macOS atau Linux |
| Halaman web              | Ya                            | Ya                              | Ya                               |
| SSH dan tunnel           | Tidak                         | Ya                              | Ya                               |
| Menjalankan installer    | Tidak                         | Tidak                           | Ya                               |

Orang yang disebut dalam serah terima ini:

| Nama                      | Peran         | Laptop       | Alamat internet                   |
|:--------------------------|:--------------|:-------------|:----------------------------------|
| Budi Santoso | Operator | Windows | 198.51.100.7 |
| Siti Rahma | Pembaca | macOS | 198.51.100.0/24 |

Sebelum kunjungan pertama Anda, vendor melakukan dua hal untuk Anda:

1. Menambahkan alamat internet Anda ke daftar izin (allow-list), bila daftar itu dipakai (lihat [Alamat internet Anda](#access-ip)).
2. Memasang kunci SSH Anda di setiap server, bila Anda operator (lihat [SSH](#access-ssh)).

## Membuka file kredensial {#access-kdbx}

Semua kata sandi ada dalam satu file terenkripsi (teracak, hanya bisa dibaca dengan kuncinya), yaitu **maju-kredensial.kdbx**. File ini dibuka dengan KeePassXC, aplikasi pengelola kata sandi yang gratis. Frasa sandi pembukanya (kata sandi berupa 7 kata) disampaikan kepada Anda secara terpisah, melalui telepon, kepada Siti Rahma. Frasa sandi itu tidak pernah dikirim dalam pesan yang sama atau di flashdisk yang sama dengan filenya.

### Memasang KeePassXC {#access-kdbx-install}

Tujuan: KeePassXC terpasang di komputer Anda.

macOS (Terminal):

```sh
brew install --cask keepassxc
```

Di macOS, Anda juga bisa mengunduh DMG dari <https://keepassxc.org/download>. Saat pertama kali dijalankan, bila macOS menolak membukanya, klik kanan aplikasinya lalu pilih "Open".

Di ponsel, KeePassDX (Android), KeePassium atau Strongbox (iPhone) dapat membuka file ini untuk melihat isinya.

**Yang seharusnya tampil:** KeePassXC ada di daftar aplikasi Anda.

**Bila gagal:** di laptop kantor, Anda mungkin tidak diizinkan memasang aplikasi. Mintalah bantuan tim TI Anda, atau minta vendor memasangnya saat sesi serah terima.

### Memeriksa file {#access-kdbx-hash}

Tujuan: memastikan file yang Anda terima persis sama dengan yang tercantum di Berita Acara Serah Terima (BAST). Buka Terminal di folder tempat file itu berada, lalu ketik:

macOS (Terminal):

```sh
shasum -a <size> maju-kredensial.kdbx
```

**Yang seharusnya tampil:** kode panjang berisi 64 huruf dan angka. Kode itu harus sama dengan SHA-<size> milik maju-kredensial.kdbx di Lampiran 3 BAST.

**Bila gagal:** bila kodenya berbeda, jangan pakai file itu. Mintalah salinan baru kepada vendor.

### Membuka file dan menyalin kata sandi {#access-kdbx-open}

Tujuan: membaca kata sandi tanpa mengetiknya dengan tangan.

1. Buka KeePassXC, pilih "Open Database", lalu pilih maju-kredensial.kdbx.
2. Ketik 7 kata frasa sandi, dengan spasi di antara kata-katanya.
3. Pilih grup di sebelah kiri (misalnya "01 Login web"), lalu klik salah satu entri.
4. Salin kata sandinya dengan Ctrl+C (Cmd+C di Mac), lalu tempel di halaman login. KeePassXC menghapus isi clipboard (tempat salinan sementara) setelah beberapa detik.
5. File di dalam entri (lampiran) ada di bagian "Attachments" entri tersebut: klik kanan untuk menyimpannya.

Simpan cadangan file ini di flashdisk di tempat yang aman. Setelah serah terima, ganti frasa sandinya (menu "Database", lalu "Database Security") dan ganti kata sandi-kata sandinya dalam 7 hari, seperti dijelaskan dalam dokumentasi teknis.

**Yang seharusnya tampil:** grup dan entri di dalam file.

**Bila gagal:** "Invalid credentials" berarti ada kata yang salah. Periksa ejaan dan spasinya, lalu coba lagi.

## Alamat internet Anda {#access-ip}

Tujuan: mengetahui alamat internet (alamat IP) koneksi Anda, karena sebagian halaman dan server hanya menerima alamat yang dikenal.

macOS (Terminal):

```sh
curl -4 https://ifconfig.me
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

Tujuan: memastikan komputer Anda menemukan halaman web sistem di bawah apps.internal.example.

macOS (Terminal):

```sh
ping -c 1 rabbitmq.apps.internal.example
```

**Yang seharusnya tampil:** alamat 192.168.50.11. Itulah server yang melayani halaman web. Balasan ping tidak wajib: sebagian jaringan memblokir ping, tetapi alamatnya harus benar.

Nama-nama ini berasal dari DNS milik perusahaan Anda sendiri (semacam buku telepon internet), dengan satu catatan untuk setiap nama di bawah apps.internal.example.

**Bila gagal:** "could not find host" berarti nama itu tidak dikenal. Minta vendor memeriksa catatan DNS-nya.

### Sertifikat {#access-web-tls}

Tujuan: membuat komputer Anda memercayai sertifikat sistem (bukti bahwa sebuah halaman benar-benar milik sistem ini). Sertifikat ini berasal dari otoritas sertifikat (CA) privat, jadi komputer Anda harus memercayai file **maju-ca.crt** dari paket serah terima. Semua perintah di sini *(belum diuji)*.

macOS (Terminal):

```sh
security add-trusted-cert -r trustRoot \
  -k ~/Library/Keychains/login.keychain-db maju-ca.crt
```

**Yang seharusnya tampil:** setelah browser dibuka ulang, halaman terbuka tanpa peringatan.

**Bila gagal:** tutup semua jendela browser, lalu buka lagi. Bila peringatan masih muncul, tanyakan kepada vendor.

### Daftar halaman {#access-web-pages}

Tujuan: mengetahui halaman apa saja yang ada, siapa yang bisa membukanya, dan entri mana di file kredensial yang berisi loginnya.

| Alamat                                   | Aplikasi         | Siapa yang bisa membuka   | Login                       | Entri di file kredensial             |
|:-----------------------------------------|:-----------------|:--------------------------|:----------------------------|:-------------------------------------|
| <https://rabbitmq.apps.internal.example/> | rabbitmq | Siapa saja (daftar izin kosong) | Login milik aplikasi | 01 Login web/RabbitMQ |
| <https://swarmpit.apps.internal.example/> | swarmpit | Siapa saja (daftar izin kosong) | Login milik aplikasi | 01 Login web/Swarmpit |
| <https://traefik.apps.internal.example/dashboard/> | traefik | Siapa saja (daftar izin kosong) | Login admin (Traefik) | 01 Login web/Traefik |
| <https://uptimekuma.apps.internal.example/> | uptimekuma | Siapa saja (daftar izin kosong) | Login milik aplikasi | 01 Login web/Uptime Kuma |

**Yang seharusnya tampil:** halaman login aplikasi, atau lebih dulu login admin (Traefik).

**Bila gagal:** "403 Forbidden" berarti alamat internet Anda tidak ada di daftar izin admin (lihat [Alamat internet Anda](#access-ip)). Halaman yang tidak pernah termuat biasanya berarti ada masalah nama (lihat [Memeriksa nama](#access-web-dns)).

## SSH: login ke server {#access-ssh}

Bagian ini untuk operator. SSH (Secure Shell) adalah cara aman untuk mengetik perintah di server. Anda login dengan kunci: sepasang file, satu privat (tetap di laptop Anda) dan satu publik (dipasang di server). Kunci milik vendor sendiri tidak pernah diserahkan.

### Memeriksa program SSH {#access-ssh-client}

Tujuan: memastikan komputer Anda punya program OpenSSH.

macOS (Terminal):

```sh
ssh -V
```

**Yang seharusnya tampil:** sebuah versi, misalnya "OpenSSH_9.6".

**Bila gagal:** macOS selalu sudah memilikinya. Gunakan OpenSSH, bukan PuTTY: PuTTY membutuhkan format kunci tersendiri.

### Membuat kunci sendiri {#access-ssh-key}

Tujuan: membuat pasangan kunci Anda, lalu mengirim hanya bagian publiknya (file berakhiran .pub) kepada vendor.

macOS (Terminal):

```sh
mkdir -p ~/.ssh
ssh-keygen -t ed25519 -f ~/.ssh/maju_ed25519 -C "your name"
```

Saat diminta, pilih frasa sandi untuk kunci itu; frasa sandi melindungi kunci bila laptop Anda hilang. Ganti "your name" dengan nama Anda.

**Yang seharusnya tampil:** dua file baru: maju_ed25519 (privat: jangan pernah dikirim) dan maju_ed25519.pub (publik: kirim file ini kepada vendor).

**Bila gagal:** "No such file or directory" berarti folder .ssh belum ada: jalankan lagi baris pertama.

### Vendor memasang kunci Anda {#access-ssh-add}

Tujuan: vendor memasang kunci publik Anda di setiap server. ansibro tidak melakukan ini, jadi operator melakukannya dengan tangan, sekali per server, dengan aksesnya sendiri:

```sh
cat maju_ed25519.pub | ssh -p 22 ubuntu@<server> \
  "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys \
  && chmod 600 ~/.ssh/authorized_keys"
```

`<server>` adalah setiap alamat di tabel berikutnya. Langkah ini adalah salah satu baris daftar uji terima (Lampiran 1 BAST).

### Menambahkan pengaturan SSH {#access-ssh-config}

Tujuan: memberi setiap server nama pendek, sehingga Anda cukup mengetik `ssh maju-app1`. File **ssh_config.txt** dari paket serah terima berisi pengaturannya; tambahkan ke akhir file pengaturan SSH Anda:

macOS (Terminal):

```sh
cat ssh_config.txt >> ~/.ssh/config
```

Hasilnya adalah nama-nama berikut:

| Nama                        | Server          | Alamat            | Melalui                       |
|:----------------------------|:----------------|:------------------|:------------------------------|
| `maju-app1` | app1 | 192.168.50.11 | Langsung |
| `maju-data1` | data1 | 192.168.50.21 | `maju-app1` |

Setiap nama login sebagai ubuntu di port 22, dengan kunci ~/.ssh/maju_ed25519.
Server tanpa alamat publik dijangkau melalui server lain (kolom "Melalui").
Di macOS, Anda bisa menambahkan dua baris di bawah setiap baris `Host` agar frasa sandi kunci disimpan di Keychain: `UseKeychain yes` dan `AddKeysToAgent yes`.

**Yang seharusnya tampil:** baris-baris `Host` di akhir file.

**Bila gagal:** bila sebelumnya sudah ada `Host` dengan nama yang sama, hapus yang lama.

### Koneksi pertama {#access-ssh-first}

Tujuan: login sekali ke server pertama dan memastikan bahwa server itu asli.

macOS (Terminal):

```sh
ssh maju-app1
```

Pada koneksi pertama, SSH menampilkan sidik jari (fingerprint) server, yaitu kode yang diawali SHA256:, lalu bertanya apakah akan dilanjutkan. Bandingkan dengan tabel ini, lalu ketik `yes`. Bila berbeda, ketik `no` dan hubungi vendor.

| Server          | Sidik jari kunci host                                                         |
|:----------------|:------------------------------------------------------------------------------|
| app1 | Belum diperiksa |
| data1 | Belum diperiksa |

Sidik jari ini belum diperiksa oleh uji terima. Minta vendor membacakannya dari setiap server dengan `ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub`.

**Yang seharusnya tampil:** prompt seperti `ubuntu@app1:~$`. Ketik `exit` untuk keluar. Perintah untuk sistem perlu diawali `sudo`, karena file-filenya di /opt/ansibro milik administrator (root).

**Bila gagal:**

- "Permission denied (publickey)": kunci Anda belum terpasang di server itu, atau nama file kuncinya salah.
- "Connection timed out": alamat Anda tidak ada di ssh.allow_from, atau firewall penyedia server memblokir port 22.
- "UNPROTECTED PRIVATE KEY FILE": file kunci bisa dibaca orang lain. Perbaiki dengan:

macOS (Terminal):

```sh
chmod 600 ~/.ssh/maju_ed25519
```

### Mengingat frasa sandi kunci {#access-ssh-agent}

Tujuan: mengetik frasa sandi kunci sekali per sesi, tidak di setiap login.

macOS (Terminal):

```sh
ssh-add --apple-use-keychain ~/.ssh/maju_ed25519
```

**Yang seharusnya tampil:** "Identity added".

**Bila gagal:** "Could not open a connection to your authentication agent" berarti agent (program penyimpan kunci) tidak berjalan.

## Database dan layanan lain: tunnel SSH {#access-tunnel}

Database dan layanan sejenis hanya mendengarkan di dalam cluster (kumpulan server), dan lalu lintas datanya tidak terenkripsi. Untuk menjangkaunya, Anda membuka tunnel SSH: pipa pribadi melalui SSH dari laptop Anda ke server. Tunnel ini sekaligus mengenkripsi lalu lintasnya.

### Menjalankan tunnel {#access-tunnel-start}

Tujuan: membuka semua pipa sekaligus dengan nama `maju-tunnel` dari ssh_config.txt.

macOS (Terminal):

```sh
ssh -N maju-tunnel
```

Biarkan jendela ini terbuka selama Anda bekerja; tutup (Ctrl+C) bila sudah selesai. Lalu hubungkan alat Anda ke 127.0.0.1 (laptop Anda sendiri) dan port di tabel ini:

| Layanan              | Server        | Di server                | Di laptop Anda          |
|:---------------------|:--------------|:-------------------------|:------------------------|
| MariaDB | data1 | 192.168.50.21:3306 | 127.0.0.1:13306 |
| AMQP | data1 | 192.168.50.21:5672 | 127.0.0.1:15672 |
| Valkey | data1 | 192.168.50.21:6379 | 127.0.0.1:16379 |

**Yang seharusnya tampil:** tidak ada apa-apa: tidak ada prompt, dan jendelanya tetap terbuka. Itu berarti tunnel bekerja.

**Bila gagal:** "Address already in use" atau "port forwarding failed" berarti ada program lain di laptop Anda yang memakai port itu. Tutup program tersebut, atau ubah angka pertama pada baris `LocalForward` yang bersangkutan di pengaturan SSH Anda.

### Menghubungkan alat Anda {#access-tunnel-tools}

Tujuan: memakai database atau layanan melalui tunnel. Kata sandinya ada di grup "02 Database dan cache" di file kredensial.

MariaDB:

macOS (Terminal):

```sh
mariadb -h 127.0.0.1 -P 13306 -u root -p
```

Valkey *(belum diuji)*:

macOS (Terminal):

```sh
redis-cli -h 127.0.0.1 -p 16379 --askpass
```

RabbitMQ: program Anda terhubung dengan AMQP ke 127.0.0.1:15672, user admin. Halaman webnya <https://rabbitmq.apps.internal.example/>.

Program berjendela (DBeaver, TablePlus, RedisInsight, WinSCP, Cyberduck) bekerja dengan cara yang sama: jalankan tunnel, lalu hubungkan ke host 127.0.0.1 dan port laptop. Program-program itu juga bisa membuat tunnel sendiri: di pengaturan SSH-nya, pakai host 192.168.50.11, port 22, user ubuntu dan file kunci Anda; lalu hubungkan ke alamat "Di server" dari tabel.

**Yang seharusnya tampil:** alat terhubung dan meminta kata sandi, atau langsung menampilkan data.

**Bila gagal:** "connection refused" berarti tunnel tidak berjalan. Jalankan lagi di jendelanya sendiri.

## Mengelola cluster {#access-cluster}

### Docker Swarm {#access-cluster-swarm}

Tujuan: melihat dan mengelola aplikasi yang berjalan (service).

Cara termudah adalah lewat browser: Swarmpit di <https://swarmpit.apps.internal.example/>.

Dari baris perintah, di server pertama:

macOS (Terminal):

```sh
ssh -t maju-app1 sudo docker service ls
```

**Yang seharusnya tampil:** daftar service, masing-masing dengan "REPLICAS" seperti 1/1.

**Bila gagal:** lihat [SSH](#access-ssh). Koneksi Docker jarak jauh (`docker context create maju --docker host=ssh://maju-app1`) hanya bekerja bila user SSH boleh memakai Docker tanpa sudo. ansibro tidak mengatur hal ini, dan akses itu memberi kendali penuh atas server, jadi vendor yang memutuskan.

### Image milik Anda sendiri {#access-cluster-images}

Tujuan: menjalankan image (paket aplikasi siap jalan) milik Anda sendiri. Registry image (registry.ansibro:5000) hanya bisa dijangkau dari server, jadi Anda mengirim image lewat SSH lalu mendorongnya (push) di server pertama:

macOS (Terminal):

```sh
docker save app:1 | ssh maju-app1 "sudo docker load"
ssh maju-app1 "sudo docker tag app:1 registry.ansibro:5000/app:1 && \
  sudo docker push registry.ansibro:5000/app:1"
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

Bila Anda buntu, hubungi vendor (Senin-Jumat 09.00-17.00 WIB). Jangan pernah mengirim kata sandi lewat email atau chat.

| Nama                     | Peran                 | Telepon                | Email                          |
|:-------------------------|:----------------------|:-----------------------|:-------------------------------|
| Rina Wijaya | Project Manager | \+62 812 0000 1111 | rina\@nusa.example |
