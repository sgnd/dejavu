---
title: "Panduan Akses Laptop"
subtitle: "Linux · Produksi"
short-title: "Panduan Akses Laptop (Linux)"
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
    - {label: "Sistem", value: "Produksi (nusa.example.co.id)"}
    - {label: "Laptop", value: "Linux"}
    - {label: "Nomor dokumen", value: "001/DOK/NUSA/XI/2026"}
    - {label: "Versi", value: "1.0"}
    - {label: "Tanggal", value: "4 November 2026"}
    - {label: "Klasifikasi", value: "TERBATAS"}
  footer: "Dibuat dengan dejavu 1.1.0 dari ansibro 1.2.0. Panduan ini tidak memuat kata sandi; semua kata sandi hanya ada di file kredensial yang terenkripsi."
---

# Akses dari laptop (Linux) {#guide}

Panduan ini menjelaskan cara menjangkau Produksi (nusa.example.co.id) milik PT Maju Bersama dari laptop Linux: halaman web, kata sandi, dan, bagi operator, server. Panduan ini bagian dari serah terima oleh PT Nusantara Teknologi. Rincian lengkapnya ada di dokumentasi teknis.

Panduan ini ditujukan untuk: Joko Prasetyo.

Anda memerlukan file-file ini dari paket serah terima: file kredensial, ssh_config.txt, serta frasa sandi pembuka file kredensial, yang disampaikan kepada Anda secara terpisah.

## Siapa butuh apa {#access-who}

Bagian ini menjelaskan, langkah demi langkah, cara menjangkau sistem dari komputer Anda sendiri. Bagian ini ditulis untuk Linux. Di Linux, perintah diketik di aplikasi **Terminal**. Setiap langkah menjelaskan apa tujuannya, apa yang diketik, apa yang seharusnya tampil, dan apa yang dilakukan bila gagal.

Perintah yang bertanda *(belum diuji)* belum pernah dicoba di laptop sungguhan. Bila salah satunya gagal, beri tahu vendor.

Tidak semua orang membutuhkan semua bagian. Cari peran Anda di tabel ini:

|                          | Pembaca (hanya halaman web)   | Operator (juga server)          | Penerus (menjalankan installer)  |
|:-------------------------|:------------------------------|:--------------------------------|:---------------------------------|
| Alat                     | Browser, KeePassXC, aplikasi autentikator | Sama, ditambah program SSH; alat database bila perlu | Sama, ditambah git, Python 3.12 atau lebih baru, age; hanya macOS atau Linux |
| Halaman web              | Ya                            | Ya                              | Ya                               |
| SSH dan tunnel           | Tidak                         | Ya                              | Ya                               |
| Menjalankan installer    | Tidak                         | Tidak                           | Ya                               |

Orang yang disebut dalam serah terima ini:

| Nama                      | Peran         | Laptop       | Alamat internet                   |
|:--------------------------|:--------------|:-------------|:----------------------------------|
| Budi Santoso | Operator | Windows | 198.51.100.7 |
| Siti Rahma | Pembaca | macOS | 198.51.100.0/24 |
| Joko Prasetyo | Penerus | Linux | 203.0.113.200 |

Sebelum kunjungan pertama Anda, vendor melakukan dua hal untuk Anda:

1. Menambahkan alamat internet Anda ke daftar izin (allow-list), bila daftar itu dipakai (lihat [Alamat internet Anda](#access-ip)).
2. Memasang kunci SSH Anda di setiap server, bila Anda operator (lihat [SSH](#access-ssh)).

> **Penting:** alamat-alamat ini berada di luar daftar izin, sehingga orang-orang ini terblokir sampai vendor menambahkan alamatnya dan menjalankan installer lagi: Joko Prasetyo (203.0.113.200).

## Membuka file kredensial {#access-kdbx}

Semua kata sandi ada dalam satu file terenkripsi (teracak, hanya bisa dibaca dengan kuncinya), yaitu **maju-kredensial.kdbx**. File ini dibuka dengan KeePassXC, aplikasi pengelola kata sandi yang gratis. Frasa sandi pembukanya (kata sandi berupa 7 kata) disampaikan kepada Anda secara terpisah, melalui telepon, kepada Siti Rahma. Frasa sandi itu tidak pernah dikirim dalam pesan yang sama atau di flashdisk yang sama dengan filenya.

### Memasang KeePassXC {#access-kdbx-install}

Tujuan: KeePassXC terpasang di komputer Anda.

Linux (Terminal):

```sh
sudo apt install keepassxc
```

Di Linux, pilihan lainnya adalah `sudo dnf install keepassxc` (Fedora) atau `flatpak install flathub org.keepassxc.KeePassXC`. Di Debian 13 dan Ubuntu 26.04, nama paketnya mungkin `keepassxc-full`.

Di ponsel, KeePassDX (Android), KeePassium atau Strongbox (iPhone) dapat membuka file ini untuk melihat isinya.

**Yang seharusnya tampil:** KeePassXC ada di daftar aplikasi Anda.

**Bila gagal:** di laptop kantor, Anda mungkin tidak diizinkan memasang aplikasi. Mintalah bantuan tim TI Anda, atau minta vendor memasangnya saat sesi serah terima.

### Memeriksa file {#access-kdbx-hash}

Tujuan: memastikan file yang Anda terima persis sama dengan yang tercantum di Berita Acara Serah Terima (BAST). Buka Terminal di folder tempat file itu berada, lalu ketik:

Linux (Terminal):

```sh
sha<size>sum maju-kredensial.kdbx
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

Linux (Terminal):

```sh
curl -4 https://ifconfig.me
```

Anda juga bisa membuka <https://ifconfig.me> di browser. Layanan itu dijalankan oleh pihak ketiga.

**Yang seharusnya tampil:** empat angka yang dipisah titik, misalnya 198.51.100.7.

Sistem ini punya dua daftar alamat yang diizinkan (daftar izin atau allow-list):

| Daftar               | Yang dilindungi                        | Alamat yang diizinkan saat ini                |
|:---------------------|:---------------------------------------|:----------------------------------------------|
| `ssh.allow_from`     | SSH, login ke server (port 22) | Kosong: terbuka untuk siapa saja |
| `admin_allow_from`   | Halaman web admin                      | 198.51.100.0/24, 192.0.2.10 |

Daftar yang kosong berarti sistem **terbuka untuk siapa saja** di internet untuk daftar itu: satu-satunya pelindung adalah kata sandi.
Bila daftar diisi, alamat yang tidak tercantum akan mendapat "403 Forbidden" di halaman admin, atau tidak mendapat jawaban (timeout) di SSH. Hal ini juga terjadi bila alamat internet rumah Anda berubah, bila Anda berada di balik proxy kantor, atau bila koneksi Anda hanya punya alamat IPv6.

**Bila gagal:** hanya operator yang bisa menambahkan alamat: ia menambahkannya ke daftar di pengaturan installer (config.yml), lalu menjalankan installer lagi. Kirimkan alamat Anda kepada vendor atau operator Anda.

## Halaman web {#access-web}

### Memeriksa nama {#access-web-dns}

Tujuan: memastikan komputer Anda menemukan halaman web sistem di bawah nusa.example.co.id.

Linux (Terminal):

```sh
ping -c 1 authelia.nusa.example.co.id
```

**Yang seharusnya tampil:** alamat 203.0.113.11 atau 203.0.113.12 atau 203.0.113.13. Itulah server yang melayani halaman web. Balasan ping tidak wajib: sebagian jaringan memblokir ping, tetapi alamatnya harus benar.

Nama-nama ini berasal dari DNS publik (semacam buku telepon internet), dengan satu catatan untuk setiap nama di bawah nusa.example.co.id.

**Bila gagal:** "could not find host" berarti nama itu tidak dikenal. Minta vendor memeriksa catatan DNS-nya.

### Sertifikat {#access-web-tls}

Sistem ini tidak punya sertifikat yang dapat dipercaya komputer Anda (pengaturan "selfsigned"). Browser akan memberi peringatan di setiap halaman, dan muncul lagi setiap kali gateway (pintu masuk halaman web) dijalankan ulang. Hal ini memang sudah diperkirakan. Untuk tetap melanjutkan:

- Chrome dan Edge: klik "Advanced", lalu "Proceed".
- Firefox: klik "Advanced", lalu "Accept the Risk and Continue".
- Safari: klik "Show Details", lalu "visit this website".

Peringatan ini aman dilewati hanya untuk alamat yang ada di tabel di bawah. Saran: gunakan sertifikat sungguhan (pengaturan "custom", atau server ACME privat); lihat masalah yang diketahui dalam dokumentasi teknis.

### Daftar halaman {#access-web-pages}

Tujuan: mengetahui halaman apa saja yang ada, siapa yang bisa membukanya, dan entri mana di file kredensial yang berisi loginnya.

| Alamat                                   | Aplikasi         | Siapa yang bisa membuka   | Login                       | Entri di file kredensial             |
|:-----------------------------------------|:-----------------|:--------------------------|:----------------------------|:-------------------------------------|
| <https://authelia.nusa.example.co.id/> | authelia | Siapa saja | Login milik aplikasi | 01 Login web/Authelia |
| <https://portainer.nusa.example.co.id/> | portainer | Hanya alamat yang diizinkan | Login milik aplikasi | 01 Login web/Portainer |
| <https://traefik.nusa.example.co.id/dashboard/> | traefik | Hanya alamat yang diizinkan | Login admin (Authelia) | 01 Login web/Authelia |
| <https://uptimekuma.nusa.example.co.id/> | uptimekuma | Hanya alamat yang diizinkan | Login milik aplikasi | 01 Login web/Uptime Kuma |
| <https://grafana.nusa.example.co.id/> | victoria | Hanya alamat yang diizinkan | Login milik aplikasi | 01 Login web/Grafana |
| <https://alertmanager.nusa.example.co.id/> | victoria | Hanya alamat yang diizinkan | Login admin (Authelia) | 01 Login web/Authelia |
| <https://metrics.nusa.example.co.id/vmui> | victoria | Hanya alamat yang diizinkan | Login admin (Authelia) | 01 Login web/Authelia |
| <https://logs.nusa.example.co.id/select/vmui> | victoria | Hanya alamat yang diizinkan | Login admin (Authelia) | 01 Login web/Authelia |

**Yang seharusnya tampil:** halaman login aplikasi, atau lebih dulu login admin (Authelia).

**Bila gagal:** "403 Forbidden" berarti alamat internet Anda tidak ada di daftar izin admin (lihat [Alamat internet Anda](#access-ip)). Halaman yang tidak pernah termuat biasanya berarti ada masalah nama (lihat [Memeriksa nama](#access-web-dns)).

### Login pertama dan 2FA {#access-web-2fa}

Tujuan: menyiapkan faktor kedua (2FA): kode 6 angka dari aplikasi di ponsel Anda, yang diminta setelah kata sandi. Lakukan ini saat sesi serah terima, bersama vendor.

1. Pasang aplikasi autentikator di ponsel Anda: Aegis, Google Authenticator atau Microsoft Authenticator.
2. Login di <https://authelia.nusa.example.co.id/> dengan user dan kata sandi dari "01 Login web/Authelia".
3. Pilih untuk mendaftarkan perangkat. Authelia tidak punya server email: operator membaca kode pendaftarannya di server pertama:

```sh
ssh -t maju-manager1 sudo cat /opt/ansibro/authelia/config/notification.txt
```

4. Pindai kode QR dengan aplikasi autentikator, lalu ketik kode 6 angkanya.

**Yang seharusnya tampil:** halaman admin terbuka setelah kode dimasukkan.

**Bila gagal:** pastikan jam di ponsel Anda tepat; kode-kode ini bergantung pada waktu.

## SSH: login ke server {#access-ssh}

Bagian ini untuk operator. SSH (Secure Shell) adalah cara aman untuk mengetik perintah di server. Anda login dengan kunci: sepasang file, satu privat (tetap di laptop Anda) dan satu publik (dipasang di server). Kunci milik vendor sendiri tidak pernah diserahkan.

### Memeriksa program SSH {#access-ssh-client}

Tujuan: memastikan komputer Anda punya program OpenSSH.

Linux (Terminal):

```sh
ssh -V
```

**Yang seharusnya tampil:** sebuah versi, misalnya "OpenSSH_9.6".

**Bila gagal:** Di Linux, pasang dengan `sudo apt install openssh-client`. Gunakan OpenSSH, bukan PuTTY: PuTTY membutuhkan format kunci tersendiri.

### Menyimpan kunci Anda {#access-ssh-key}

Tujuan: menaruh kunci yang dibuatkan vendor untuk Anda di tempat yang benar. Kunci itu adalah lampiran maju_ed25519 pada entri "04 Infrastruktur/SSH key (client)" di file kredensial. Simpan dengan nama ini:

Linux (Terminal):

```sh
mkdir -p ~/.ssh
# save the attachment as ~/.ssh/maju_ed25519, then:
chmod 600 ~/.ssh/maju_ed25519
```

**Yang seharusnya tampil:** file maju_ed25519 ada di folder .ssh Anda.

**Bila gagal:** bila lampirannya tidak ada, tanyakan kepada vendor.

### Menambahkan pengaturan SSH {#access-ssh-config}

Tujuan: memberi setiap server nama pendek, sehingga Anda cukup mengetik `ssh maju-manager1`. File **ssh_config.txt** dari paket serah terima berisi pengaturannya; tambahkan ke akhir file pengaturan SSH Anda:

Linux (Terminal):

```sh
cat ssh_config.txt >> ~/.ssh/config
```

Hasilnya adalah nama-nama berikut:

| Nama                        | Server          | Alamat            | Melalui                       |
|:----------------------------|:----------------|:------------------|:------------------------------|
| `maju-data1` | data1 | 203.0.113.21 | Langsung |
| `maju-data2` | data2 | 203.0.113.22 | Langsung |
| `maju-data3` | data3 | 203.0.113.23 | Langsung |
| `maju-manager1` | manager1 | 203.0.113.11 | Langsung |
| `maju-manager2` | manager2 | 203.0.113.12 | Langsung |
| `maju-manager3` | manager3 | 203.0.113.13 | Langsung |
| `maju-worker1` | worker1 | 203.0.113.31 | Langsung |
| `maju-worker2` | worker2 | 203.0.113.32 | Langsung |
| `maju-worker3` | worker3 | 203.0.113.33 | Langsung |

Setiap nama login sebagai ubuntu di port 22, dengan kunci ~/.ssh/maju_ed25519.

**Yang seharusnya tampil:** baris-baris `Host` di akhir file.

**Bila gagal:** bila sebelumnya sudah ada `Host` dengan nama yang sama, hapus yang lama.

### Koneksi pertama {#access-ssh-first}

Tujuan: login sekali ke server pertama dan memastikan bahwa server itu asli.

Linux (Terminal):

```sh
ssh maju-manager1
```

Pada koneksi pertama, SSH menampilkan sidik jari (fingerprint) server, yaitu kode yang diawali SHA256:, lalu bertanya apakah akan dilanjutkan. Bandingkan dengan tabel ini, lalu ketik `yes`. Bila berbeda, ketik `no` dan hubungi vendor.

| Server          | Sidik jari kunci host                                                         |
|:----------------|:------------------------------------------------------------------------------|
| data1 | `SHA256:data1TestFingerprintDoNotTrust0000000000000` |
| data2 | `SHA256:data2TestFingerprintDoNotTrust0000000000000` |
| data3 | `SHA256:data3TestFingerprintDoNotTrust0000000000000` |
| manager1 | `SHA256:manager1TestFingerprintDoNotTrust0000000000` |
| manager2 | `SHA256:manager2TestFingerprintDoNotTrust0000000000` |
| manager3 | `SHA256:manager3TestFingerprintDoNotTrust0000000000` |
| worker1 | `SHA256:worker1TestFingerprintDoNotTrust00000000000` |
| worker2 | `SHA256:worker2TestFingerprintDoNotTrust00000000000` |
| worker3 | `SHA256:worker3TestFingerprintDoNotTrust00000000000` |

**Yang seharusnya tampil:** prompt seperti `ubuntu@manager1:~$`. Ketik `exit` untuk keluar. Perintah untuk sistem perlu diawali `sudo`, karena file-filenya di /opt/ansibro milik administrator (root).

**Bila gagal:**

- "Permission denied (publickey)": kunci Anda belum terpasang di server itu, atau nama file kuncinya salah.
- "Connection timed out": alamat Anda tidak ada di ssh.allow_from, atau firewall penyedia server memblokir port 22.
- "UNPROTECTED PRIVATE KEY FILE": file kunci bisa dibaca orang lain. Perbaiki dengan:

Linux (Terminal):

```sh
chmod 600 ~/.ssh/maju_ed25519
```

### Mengingat frasa sandi kunci {#access-ssh-agent}

Tujuan: mengetik frasa sandi kunci sekali per sesi, tidak di setiap login.

Linux (Terminal):

```sh
ssh-add ~/.ssh/maju_ed25519
```

**Yang seharusnya tampil:** "Identity added".

**Bila gagal:** "Could not open a connection to your authentication agent" berarti agent (program penyimpan kunci) tidak berjalan.

## Database dan layanan lain: tunnel SSH {#access-tunnel}

Database dan layanan sejenis hanya mendengarkan di dalam cluster (kumpulan server), dan lalu lintas datanya tidak terenkripsi. Untuk menjangkaunya, Anda membuka tunnel SSH: pipa pribadi melalui SSH dari laptop Anda ke server. Tunnel ini sekaligus mengenkripsi lalu lintasnya.

### Menjalankan tunnel {#access-tunnel-start}

Tujuan: membuka semua pipa sekaligus dengan nama `maju-tunnel` dari ssh_config.txt.

Linux (Terminal):

```sh
ssh -N maju-tunnel
```

Biarkan jendela ini terbuka selama Anda bekerja; tutup (Ctrl+C) bila sudah selesai. Lalu hubungkan alat Anda ke 127.0.0.1 (laptop Anda sendiri) dan port di tabel ini:

| Layanan              | Server        | Di server                | Di laptop Anda          |
|:---------------------|:--------------|:-------------------------|:------------------------|
| S3 | data1 | 10.0.0.21:3900 | 127.0.0.1:13900 |
| S3 | data2 | 10.0.0.22:3900 | 127.0.0.1:13901 |
| S3 | data3 | 10.0.0.23:3900 | 127.0.0.1:13902 |
| PostgreSQL | data1 | 10.0.0.21:5432 | 127.0.0.1:15432 |
| PostgreSQL | data2 | 10.0.0.22:5432 | 127.0.0.1:15433 |
| PostgreSQL | data3 | 10.0.0.23:5432 | 127.0.0.1:15434 |
| Redis | data1 | 10.0.0.21:6379 | 127.0.0.1:16379 |
| Redis | data2 | 10.0.0.22:6379 | 127.0.0.1:16380 |
| Redis | data3 | 10.0.0.23:6379 | 127.0.0.1:16381 |

**Yang seharusnya tampil:** tidak ada apa-apa: tidak ada prompt, dan jendelanya tetap terbuka. Itu berarti tunnel bekerja.

**Bila gagal:** "Address already in use" atau "port forwarding failed" berarti ada program lain di laptop Anda yang memakai port itu. Tutup program tersebut, atau ubah angka pertama pada baris `LocalForward` yang bersangkutan di pengaturan SSH Anda.
Server-server saling terhubung melalui WireGuard (jaringan terenkripsi khusus antarserver; laptop Anda tidak bisa ikut bergabung). SSH menuju alamat publik, dan tunnel menjangkau alamat WireGuard; pengaturannya sudah mengatur hal ini.

### Menghubungkan alat Anda {#access-tunnel-tools}

Tujuan: memakai database atau layanan melalui tunnel. Kata sandinya ada di grup "02 Database dan cache" dan "03 Penyimpanan S3" di file kredensial.

PostgreSQL *(belum diuji)*:

Linux (Terminal):

```sh
psql "host=127.0.0.1,127.0.0.1,127.0.0.1
      port=15432,15433,15434 user=postgres
      target_session_attrs=read-write"
```

Server utama (primary) bisa berpindah di antara data1, data2, data3; baris ini mencoba setiap port dan memakai port yang menerima perubahan data.

Redis *(belum diuji)*:

Linux (Terminal):

```sh
redis-cli -h 127.0.0.1 -p 16379 --askpass
```

Dengan 3 server, hanya server utama (primary) yang menerima perubahan, dan server utama itu bisa berpindah. Cari dulu yang mana; jawabannya berupa alamat server dari tabel di atas, jadi pakai port laptop pada baris tersebut:

Linux (Terminal):

```sh
ssh maju-data1 "sudo docker exec redis-sentinel redis-cli -p 26379 \
  sentinel get-master-addr-by-name ansibro"
```

Garage (penyimpanan file S3). Access key-nya diawali GK; region-nya garage. Masukkan dulu kunci dari "03 Penyimpanan S3/Garage S3" ke `aws configure`:

Linux (Terminal):

```sh
aws --endpoint-url http://127.0.0.1:13900 --region garage s3 ls
```

Program berjendela (DBeaver, TablePlus, RedisInsight, WinSCP, Cyberduck) bekerja dengan cara yang sama: jalankan tunnel, lalu hubungkan ke host 127.0.0.1 dan port laptop. Program-program itu juga bisa membuat tunnel sendiri: di pengaturan SSH-nya, pakai host 203.0.113.21, port 22, user ubuntu dan file kunci Anda; lalu hubungkan ke alamat "Di server" dari tabel.

**Yang seharusnya tampil:** alat terhubung dan meminta kata sandi, atau langsung menampilkan data.

**Bila gagal:** "connection refused" berarti tunnel tidak berjalan. Jalankan lagi di jendelanya sendiri.

## Mengelola cluster {#access-cluster}

### Docker Swarm {#access-cluster-swarm}

Tujuan: melihat dan mengelola aplikasi yang berjalan (service).

Cara termudah adalah lewat browser: Portainer di <https://portainer.nusa.example.co.id/>.

Dari baris perintah, di server pertama:

Linux (Terminal):

```sh
ssh -t maju-manager1 sudo docker service ls
```

**Yang seharusnya tampil:** daftar service, masing-masing dengan "REPLICAS" seperti 1/1.

**Bila gagal:** lihat [SSH](#access-ssh). Koneksi Docker jarak jauh (`docker context create maju --docker host=ssh://maju-manager1`) hanya bekerja bila user SSH boleh memakai Docker tanpa sudo. ansibro tidak mengatur hal ini, dan akses itu memberi kendali penuh atas server, jadi vendor yang memutuskan.

### Image milik Anda sendiri {#access-cluster-images}

Tujuan: menjalankan image (paket aplikasi siap jalan) milik Anda sendiri. Registry image (registry.ansibro:5000) hanya bisa dijangkau dari server, jadi Anda mengirim image lewat SSH lalu mendorongnya (push) di server pertama:

Linux (Terminal):

```sh
docker save app:1 | ssh maju-manager1 "sudo docker load"
ssh maju-manager1 "sudo docker tag app:1 registry.ansibro:5000/app:1 && \
  sudo docker push registry.ansibro:5000/app:1"
```

`app:1` adalah nama dan versi image Anda. Registry tidak termasuk dalam backup: setelah pemulihan (restore), push lagi image Anda.

## Penerus: menjalankan installer {#access-successor}

Bagian ini untuk orang yang akan mengubah sistem dengan ansibro (installer) setelah serah terima. Dibutuhkan macOS atau Linux; Windows tidak didukung (WSL2 *belum diuji*). Selalu jalankan installer dari satu komputer yang sama ini.

1. Pasang git, Python 3.12 atau lebih baru, dan age (`brew install age` di macOS, `sudo apt install age` di Ubuntu).
2. Ambil ansibro dan pindah ke versi yang dipakai untuk membangun sistem ini (1.2.0):

```sh
git clone https://github.com/sgnd/ansibro.git
cd ansibro
git tag --list
```

   Lalu jalankan `git checkout` ke tag versi 1.2.0.

3. Simpan lampiran ansibro-installer.tar.gz dari entri "06 Internal (menjalankan ulang ansibro)/ansibro installer files" ke folder itu, lalu buka arsipnya:

```sh
tar -xzf ansibro-installer.tar.gz
chmod 700 state
```

4. Opsional: buat kunci agar catatan installer tetap terenkripsi (state.age):

```sh
mkdir -p ~/.config/ansibro && age-keygen -o ~/.config/ansibro/age.key
```

5. Jalankan installer, lalu uji sistem:

```sh
./install.sh config.yml
.venv/bin/python tests/check.py
```

**Yang seharusnya tampil:** installer selesai tanpa "failed", dan uji sistem menampilkan baris-baris PASS.

**Bila gagal:** kata sandi di lampiran itu adalah kata sandi pada hari serah terima. Setelah kata sandi diganti, masukkan dulu nilai barunya ke file yang sesuai di state/secrets/, seperti dijelaskan dalam dokumentasi teknis.

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
