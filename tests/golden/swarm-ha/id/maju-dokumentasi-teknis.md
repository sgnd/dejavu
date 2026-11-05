---
title: "Dokumentasi Teknis Serah Terima"
subtitle: "Produksi · nusa.example.co.id"
short-title: "Dokumentasi Teknis · Maju"
lang: id
region: ID
docnumber: "001/DOK/NUSA/XI/2026"
version: "1.0"
date: "4 November 2026"
classification: "TERBATAS"
numbered: true
labels: {page: "Halaman", of: "dari", toc: "Daftar Isi"}
cover:
  kicker: "DOKUMENTASI SERAH TERIMA"
  rows:
    - {label: "Untuk", value: "PT Maju Bersama"}
    - {label: "Oleh", value: "PT Nusantara Teknologi"}
    - {label: "Sistem", value: "Produksi, nusa.example.co.id"}
    - {label: "Nomor dokumen", value: "001/DOK/NUSA/XI/2026"}
    - {label: "Versi", value: "1.0"}
    - {label: "Tanggal", value: "4 November 2026"}
    - {label: "Klasifikasi", value: "TERBATAS"}
    - {label: "Distribusi", value: "Hanya untuk PT Maju Bersama dan PT Nusantara Teknologi"}
  footer: "Dibuat dengan dejavu 1.0.0 dari ansibro 1.2.0. Dokumen ini tidak memuat kata sandi apa pun. Dokumen ini menjelaskan cara masuk ke sistem, jadi jaga kerahasiaannya."
---

# Pengendalian dokumen {#control .unnumbered}

| Peran | Nama |
|:---------------|:--------------------------------------------------------|
| Disusun oleh | Rina Wijaya |
| Diperiksa oleh | Andi Saputra |
| Disetujui oleh | Dewi Lestari |

| Versi | Tanggal | Oleh | Perubahan |
|:--------|:-----------|:----------------|:-----------------------------------------|
| 1.0 | 2026-11-04 | Rina Wijaya | Terbitan pertama |

Dokumen ini dibuat dengan dejavu 1.0.0 dari ansibro 1.2.0, konfigurasi `config`, instalasi terakhir 3 November 2026.
Dokumen ini tidak memuat kata sandi. Semua kata sandi ada di file kredensial `maju-kredensial.kdbx`.
Jika suatu jawaban belum diberikan, teks menulis *Belum diisi*.

## Cara membaca dokumen ini {#how-to-read .unnumbered}

- **Semua pembaca** (yang hanya memakai halaman web): baca [bab 1](#summary), [bab 5](#access), [bab 6](#credentials), dan [bab 11](#support).
- **Operator** (yang merawat server): baca seluruh dokumen.
- Istilah teknis dijelaskan saat pertama kali muncul, dan sekali lagi di [glosarium](#appendix-glossary) (Lampiran H).
- Kotak merah menandai hal yang harus Anda tindak lanjuti.

# Ringkasan {#summary}

## Apa yang dibangun {#summary-built}

PT Nusantara Teknologi membangun sistem dengan 9 server untuk PT Maju Bersama.
Sistem ini dapat diakses di alamat web `nusa.example.co.id` dan halaman-halaman di bawahnya, misalnya `traefik.nusa.example.co.id`.
Sistem dipasang dengan ansibro, yaitu program instalasi yang memasang program yang sama di setiap server dengan cara yang sama.
Program yang berjalan:

- **Authelia**: Halaman login dengan faktor kedua (2FA) di depan halaman admin.
- **Garage**: Penyimpanan file kompatibel S3. Pada 3 server, setiap file disimpan 3 salinan.
- **Portainer**: Halaman web untuk melihat dan mengelola container dan stack di cluster.
- **PostgreSQL**: Database SQL untuk aplikasi Anda (dan untuk Kong, Keycloak, Authelia).
- **Redis**: Penyimpanan key-value di memori, untuk cache dan sesi login.
- **Traefik**: Pintu masuk semua halaman web. Menerima HTTPS untuk domain dan meneruskan tiap subdomain ke aplikasinya, lengkap dengan sertifikat.
- **Uptime Kuma**: Memeriksa setiap menit bahwa halaman web Anda menjawab, dan memberi tahu bila ada yang mati.
- **Victoria monitoring**: Pemantauan lengkap. Metrik, log, aturan peringatan, Grafana, dan peringatan ke Telegram, email, atau webhook.

## Enam hal yang perlu Anda ketahui lebih dulu {#summary-six}

1. **Tempat semua kata sandi.** Semua kata sandi ada di satu file terkunci, `maju-kredensial.kdbx`. Buka file ini dengan KeePassXC (lihat [bab 5](#access)). Kata sandi pembukanya diberikan terpisah melalui telepon kepada Siti Rahma.
2. **Ganti kata sandi dalam 7 hari.** Saat ini vendor masih mengetahuinya. [Bab 6](#credentials) menjelaskan caranya, dan [Lampiran E](#appendix-passwords) berisi daftar periksanya.
3. **Cara membuka halaman admin.** Gunakan browser web dan buka alamat di [bab 4](#apps), misalnya <https://authelia.nusa.example.co.id/>. Halaman ini hanya terbuka dari alamat internet yang ada di daftar izin. Anda login dengan kata sandi dan kode dari aplikasi di ponsel Anda.
4. **Backup aktif.** Setiap malam pukul 02:00 (UTC) setiap server menyalin datanya ke `s3.example.com`.
5. **Peringatan aktif.** Masalah dilaporkan ke slack. Lihat [bab 8](#monitoring).
6. **Siapa yang dihubungi.** Rina Wijaya (Project Manager), \+62 812 0000 1111, rina\@nusa.example, Senin-Jumat 09.00-17.00 WIB. Lihat [bab 11](#support).

## Lingkup pekerjaan {#summary-scope}

**Termasuk dalam pekerjaan ini:**

- 9 server yang dipasang dengan ansibro, beserta 8 program yang tercantum di atas.
- Dokumen ini, panduan laptop, berita acara serah terima (BAST), dan file kredensial.

**Tidak termasuk dalam pekerjaan ini:**

- Aplikasi bisnis milik klien

# Arsitektur {#architecture}

![Server dan aplikasi yang berjalan di atasnya](architecture.svg)

## Cluster dan ketersediaan tinggi {#architecture-ha}

Server-server ini membentuk sebuah *cluster*, yaitu sekelompok server yang bekerja sebagai satu kesatuan.
Cluster dijalankan oleh *Docker Swarm*. Docker Swarm menjalankan setiap aplikasi di dalam *container* (aplikasi yang dikemas bersama semua kebutuhannya) dan menyalakannya kembali jika berhenti.
*Manager* adalah server yang mengendalikan cluster. Cluster tetap bekerja selama lebih dari separuh manager-nya menyala.

*Ketersediaan tinggi* (*high availability*, HA) berarti suatu bagian tetap bekerja walaupun satu server berhenti. Berikut tingkat HA setiap bagian:

| Bagian | Cara pemasangan | Jika satu server berhenti |
|:----------------|:--------------------------------------|:--------------------------------------|
| Manager cluster | 3 manager: manager1, manager2, manager3 | Cluster tetap bekerja (1 boleh berhenti) |
| Pintu masuk web (Traefik) | Di manager1, manager2, manager3 | DNS masih mengarah ke server yang berhenti; browser mungkin mencobanya lebih dulu |
| Database (PostgreSQL) | Patroni di data1, data2, data3, dengan etcd dan database-proxy | Server lain otomatis menjadi primary |
| Cache (Redis) | Satu primary dan dua salinan dengan Sentinel di data1, data2, data3 | Sentinel menjadikan salah satu salinan sebagai primary baru |
| Penyimpanan (Garage) | 3 server, 3 salinan untuk setiap file | File tetap tersedia dari salinan lainnya |

## Bagaimana pengunjung sampai ke aplikasi {#architecture-traffic}

1. *DNS* (buku alamat internet) mengubah `nama-apa-saja.nusa.example.co.id` menjadi alamat publik manager1, manager2, manager3.
2. Browser terhubung ke *Traefik*, pintu masuk sistem, di port 443 (HTTPS). Port 80 hanya mengalihkan ke port 443.
3. Traefik memeriksa siapa yang boleh masuk. Setiap halaman punya satu *penjaga*:
   - **admin**: alamat pengunjung harus ada di daftar izin admin, lalu login admin meminta kata sandi dan kode (2FA);
   - **admin-ip**: alamat harus ada di daftar izin admin; setelah itu aplikasi menampilkan login-nya sendiri;
   - **public**: siapa saja boleh membukanya; aplikasi punya login sendiri, atau tanpa login.
4. Traefik meneruskan pengunjung ke aplikasi, di server mana pun aplikasi itu berjalan dalam cluster.

Daftar izin admin (`admin_allow_from`): 198.51.100.0/24, 192.0.2.10.

## Manager pertama {#architecture-first}

`manager1` adalah *manager pertama*. Server ini punya tugas yang tidak dimiliki server lain:

- ansibro dan uji penerimaannya menjalankan pemeriksaan dari server ini.
- Portainer dan Authelia menyimpan datanya di server ini.
- Authelia menulis kode 2FA pertama dan tautan reset kata sandi ke sebuah file di server ini.
- Backup malamnya juga berisi state Swarm, salinan `config.yml`, dan salinan semua file kata sandi.
- Server ini menyimpan otoritas sertifikat (CA) untuk registry image privat.
- **Server ini tidak boleh dikeluarkan dari cluster.**

## Komponen {#architecture-components}

ansibro juga memasang bagian-bagian berikut. Bagian ini bukan aplikasi pilihan Anda, tetapi termasuk dalam sistem.

| Komponen | Lokasi | Port | Versi | Lisensi | Fungsi |
|:-----------|:------------|:-----|:-------------|:----------|:------------------------------------|
| registry | manager | 5000 | 3.1.2 | Apache-2.0 | Registry image pribadi di setiap manager. Semua server menarik image dari sini. |
| database-proxy | cluster | 5432 | 3.2.26 | GPL-2.0 | HAProxy di depan database ber-HA, selalu menuju server utama (primary). |
| etcd | manager | 12379 | v3.6.16 | Apache-2.0 | Penyimpanan kunci-nilai yang dipakai Patroni untuk memilih server utama PostgreSQL. |
| sentinel | server cache | 26379 |  |  | Mengawasi Redis atau Valkey dan memindahkan primary bila server utama mati. |
| monitoring-agents | semua server | 9100 | v1.12.1 | Apache-2.0 | node-exporter, cAdvisor, Vector, dan exporter database di setiap server, plus timer ansibro-metrics. |
| backup | semua server |  |  | BSD-2-Clause | Timer ansibro-backup dengan restic setiap malam di setiap server. |
| wireguard | semua server | 51820 |  | GPL-2.0 | Jaringan terenkripsi antar-server saja (bukan VPN untuk laptop). |

# Server dan jaringan {#servers}

## Daftar server {#servers-list}

*IP cluster* adalah alamat yang dipakai antarserver. *Alamat SSH* adalah alamat tempat orang dan program instalasi login.

| Server | Peran | Tier | IP cluster | Alamat SSH | IP publik |
|:-----------|:-----------|:---------|:-------------|:--------------|:--------------|
| data1 | standalone |  | 10.0.0.21 | 203.0.113.21 | sama dengan alamat SSH |
| data2 | standalone |  | 10.0.0.22 | 203.0.113.22 | sama dengan alamat SSH |
| data3 | standalone |  | 10.0.0.23 | 203.0.113.23 | sama dengan alamat SSH |
| manager1 (manager pertama) | manager | gateway | 10.0.0.11 | 203.0.113.11 | sama dengan alamat SSH |
| manager2 | manager | gateway | 10.0.0.12 | 203.0.113.12 | sama dengan alamat SSH |
| manager3 | manager | gateway | 10.0.0.13 | 203.0.113.13 | sama dengan alamat SSH |
| worker1 | worker | app | 10.0.0.31 | 203.0.113.31 | sama dengan alamat SSH |
| worker2 | worker | app | 10.0.0.32 | 203.0.113.32 | sama dengan alamat SSH |
| worker3 | worker | app | 10.0.0.33 | 203.0.113.33 | sama dengan alamat SSH |

| Server | Penyedia | Region | Ukuran | Sistem operasi |
|:-----------|:---------------|:-------------|:---------------------------|:------------------|
| data1 | DigitalOcean | *Belum diisi* | 4 vCPU, memori 8.0 GB, disk 160 GB | Ubuntu 24.04 (kernel 6.8.0-88-generic) |
| data2 | DigitalOcean | *Belum diisi* | 4 vCPU, memori 8.0 GB, disk 160 GB | Ubuntu 24.04 (kernel 6.8.0-88-generic) |
| data3 | DigitalOcean | *Belum diisi* | 4 vCPU, memori 8.0 GB, disk 160 GB | Ubuntu 24.04 (kernel 6.8.0-88-generic) |
| manager1 | DigitalOcean | SGP1 | 2 vCPU, memori 4.0 GB, disk 80 GB | Ubuntu 24.04 (kernel 6.8.0-88-generic) |
| manager2 | DigitalOcean | *Belum diisi* | 2 vCPU, memori 4.0 GB, disk 80 GB | Ubuntu 24.04 (kernel 6.8.0-88-generic) |
| manager3 | DigitalOcean | *Belum diisi* | 2 vCPU, memori 4.0 GB, disk 80 GB | Ubuntu 24.04 (kernel 6.8.0-88-generic) |
| worker1 | DigitalOcean | *Belum diisi* | 4 vCPU, memori 4.0 GB, disk 80 GB | Ubuntu 24.04 (kernel 6.8.0-88-generic) |
| worker2 | DigitalOcean | *Belum diisi* | 4 vCPU, memori 4.0 GB, disk 80 GB | Ubuntu 24.04 (kernel 6.8.0-88-generic) |
| worker3 | DigitalOcean | *Belum diisi* | 4 vCPU, memori 4.0 GB, disk 80 GB | Ubuntu 24.04 (kernel 6.8.0-88-generic) |

| Server | Sidik jari host key (ED25519) |
|:-----------|:--------------------------------------------------------------|
| data1 | `SHA256:data1TestFingerprintDoNotTrust0000000000000` |
| data2 | `SHA256:data2TestFingerprintDoNotTrust0000000000000` |
| data3 | `SHA256:data3TestFingerprintDoNotTrust0000000000000` |
| manager1 | `SHA256:manager1TestFingerprintDoNotTrust0000000000` |
| manager2 | `SHA256:manager2TestFingerprintDoNotTrust0000000000` |
| manager3 | `SHA256:manager3TestFingerprintDoNotTrust0000000000` |
| worker1 | `SHA256:worker1TestFingerprintDoNotTrust00000000000` |
| worker2 | `SHA256:worker2TestFingerprintDoNotTrust00000000000` |
| worker3 | `SHA256:worker3TestFingerprintDoNotTrust00000000000` |

*Sidik jari host key* (*fingerprint*) memungkinkan Anda memastikan, saat login SSH pertama kali, bahwa Anda benar-benar terhubung ke server yang asli. [Bab 5](#access) menunjukkan cara membacanya.

Aplikasi yang berjalan di server tertentu (semua aplikasi lainnya berjalan di cluster):

| Server | Aplikasi |
|:-------------|:----------------------------------------------------------|
| data1 | PostgreSQL, Redis, Garage, Victoria monitoring |
| data2 | PostgreSQL, Redis, Garage, Uptime Kuma |
| data3 | PostgreSQL, Redis, Garage |

## DNS {#servers-dns}

| Pengaturan | Nilai |
|:--------------------|:---------------------------------------------------|
| Mode | DNS publik |
| Record | `*.nusa.example.co.id` (tipe A) |
| Mengarah ke | 203.0.113.11 (manager1), 203.0.113.12 (manager2), 203.0.113.13 (manager3) |
| Penyedia DNS | Cloudflare |
| Pemilik domain | PT Maju Bersama |
| CDN di depan server | tidak |

## Sertifikat (TLS) {#servers-tls}

*Sertifikat* membuktikan kepada browser bahwa halaman itu benar-benar `nusa.example.co.id`, sekaligus mengenkripsi koneksinya (*TLS*, huruf "s" pada https).

| Pengaturan | Nilai |
|:--------------------|:---------------------------------------------------|
| Mode | Self-signed (ditandatangani sendiri) |
| Penerbit | Sertifikat bawaan Traefik sendiri |
| Masa berlaku | Dibuat ulang setiap kali Traefik menyala |
| Pembaruan | Tidak ada |

> **Penting:** dengan sertifikat self-signed, setiap browser menampilkan peringatan di setiap halaman, dan tidak ada sertifikat yang dapat dipasang untuk menghilangkannya. Rekomendasi: beralih ke `tls: custom` dengan sertifikat dari otoritas sertifikat (CA) perusahaan Anda.

Pada 2026-11-04, sertifikat yang dipakai diterbitkan oleh CN=Test Self-Signed dan berakhir pada 2027-11-04.

## Firewall {#servers-firewall}

*Firewall* menentukan koneksi mana yang boleh masuk ke sebuah server. Setiap server menjalankan firewall *ufw*.

- ansibro yang mengelola firewall. ansibro menulis ulang aturannya setiap kali ada perubahan, dan **aturan yang ditambahkan manual akan terhapus**. Ubah daftar di bawah ini di `config.yml`, lalu jalankan `./install.sh`.
- Port yang dibuka oleh container Docker tidak melewati ufw.
- *Daftar izin* (*allow-list*) adalah daftar alamat internet yang boleh terhubung. Daftar kosong berarti siapa saja boleh terhubung.

| Daftar | Yang dijaga | Alamat | Milik |
|:----------------|:-------------------|:----------------------|:----------------------|
| `ssh.allow_from` | SSH ke semua server | **terbuka untuk siapa saja** | |
| `admin_allow_from` | halaman web admin | 198.51.100.0/24 | Siti Rahma |
|  |  | 192.0.2.10 | *Belum diisi* |

> **Penting:** SSH terbuka untuk siapa saja di internet. Rekomendasi: cantumkan alamat kantor dan staf Anda di `config.yml`, lalu jalankan `./install.sh`.

> **Penting:** alamat orang-orang berikut belum ada di daftar izin, sehingga mereka belum dapat terhubung: Joko Prasetyo (203.0.113.200).

## Port {#servers-ports}

*Port* adalah pintu bernomor di sebuah server untuk satu jenis koneksi.

| Port | Fungsi | Di server | Terbuka untuk |
|:---------|:-------------------|:-------------------------|:-------------------------|
| 22/tcp | SSH | semua | siapa saja (daftarnya kosong) |
| 80, 443/tcp | Halaman web (Traefik) | manager1, manager2, manager3 | siapa saja; halaman admin juga memeriksa `admin_allow_from` |
| 3900/tcp | Garage S3 | data1, data2, data3 | hanya server lain dalam cluster |
| 5432/tcp | PostgreSQL | data1, data2, data3 | hanya server lain dalam cluster |
| 6379/tcp | Redis | data1, data2, data3 | hanya server lain dalam cluster |
| 5000/tcp | registry | manager1, manager2, manager3 | hanya server lain dalam cluster |
| 12379/tcp | etcd | manager1, manager2, manager3 | hanya server lain dalam cluster |
| 26379/tcp | sentinel | data1, data2, data3 | hanya server lain dalam cluster |
| 9100/tcp | monitoring-agents | semua | hanya server lain dalam cluster |
| 51820/udp | wireguard | semua | hanya server lain dalam cluster |

Database, cache, penyimpanan, dan antrean pesan diakses dari laptop melalui tunnel SSH (lihat [bab 5](#access)).

## Jaringan antarserver {#servers-wireguard}

Server-server berkomunikasi satu sama lain melalui *WireGuard*, sebuah jaringan terenkripsi (port UDP 51820). IP cluster di atas adalah alamat WireGuard; SSH memakai alamat SSH.
WireGuard hanya menghubungkan antarserver. WireGuard **bukan** VPN untuk laptop.

## Waktu dan internet {#servers-time}

- Zona waktu: **UTC**. Jadwal backup dan log memakai zona waktu ini.
- Server memakai internet untuk mengunduh program dan menyamakan jam.

# Aplikasi {#apps}

## Gambaran umum {#apps-overview}

| Aplikasi | Fungsi | Berjalan di | Versi | Lisensi |
|:-----------|:-------------------------------|:-------------------|:-----------|:-----------|
| Authelia | login | manager1 | 4.39.28 | Apache-2.0 |
| Garage | penyimpanan file (S3) | data1, data2, data3 | v2.5.0 | AGPL-3.0 |
| Portainer | halaman pengelolaan cluster | manager1 | 2.45.3 | zlib |
| PostgreSQL | database | data1 (utama saat instalasi), data2, data3 | spilo-18 4.1-p2 | PostgreSQL |
| Redis | cache | data1 (utama saat instalasi), data2, data3 | 8.10.3 | AGPL-3.0 |
| Traefik | pintu masuk web | manager1, manager2, manager3 | v3.7.17 | MIT |
| Uptime Kuma | pemeriksaan uptime | data2 | 2.5.8 | MIT |
| Victoria monitoring | pemantauan | data1 | victoria-metrics v1.155.0 | Apache-2.0 |

## Halaman web {#apps-web}

| Alamat | Aplikasi | Siapa yang dapat membuka | Login |
|:------------------------------------|:-----------|:--------------------|:--------------------|
| <https://authelia.nusa.example.co.id/> | Authelia | siapa saja | login aplikasi itu sendiri |
| <https://portainer.nusa.example.co.id/> | Portainer | daftar izin admin | login aplikasi itu sendiri |
| <https://traefik.nusa.example.co.id/dashboard/> | Traefik | daftar izin admin | login Authelia dengan kode dari ponsel Anda (2FA) |
| <https://uptimekuma.nusa.example.co.id/> | Uptime Kuma | daftar izin admin | login aplikasi itu sendiri |
| <https://grafana.nusa.example.co.id/> | Victoria monitoring | daftar izin admin | login aplikasi itu sendiri |
| <https://alertmanager.nusa.example.co.id/> | Victoria monitoring | daftar izin admin | login Authelia dengan kode dari ponsel Anda (2FA) |
| <https://metrics.nusa.example.co.id/vmui> | Victoria monitoring | daftar izin admin | login Authelia dengan kode dari ponsel Anda (2FA) |
| <https://logs.nusa.example.co.id/select/vmui> | Victoria monitoring | daftar izin admin | login Authelia dengan kode dari ponsel Anda (2FA) |

## Authelia {#app-authelia}

Halaman login dengan faktor kedua (2FA) di depan halaman admin.

| Hal | Keterangan |
|:----------------|:-------------------------------------------------------|
| Berjalan di | manager1 |
| Halaman web | <https://authelia.nusa.example.co.id/> (login sendiri) |
| Dari laptop | browser web |
| Kredensial | `01 Login web/Authelia` |
| Data | `/opt/ansibro/authelia` |
| Backup | Disalin saat dijeda |
| Pemeriksaan kesehatan | `POST /api/firstfactor` |

- Setelah instalasi, file users.yml di server pertama adalah sumber kebenaran untuk akun Authelia.
- Tidak ada server email. Kode 2FA pertama dan tautan reset ditulis ke /opt/ansibro/authelia/config/notification.txt di server pertama.

## Garage {#app-garage}

Penyimpanan file kompatibel S3. Pada 3 server, setiap file disimpan 3 salinan.

| Hal | Keterangan |
|:----------------|:-------------------------------------------------------|
| Berjalan di | data1, data2, data3 |
| S3 | `10.0.0.21:3900`, `10.0.0.22:3900`, `10.0.0.23:3900` |
| Dari laptop | tunnel SSH ([bab 5](#access)) |
| Kredensial | `03 Penyimpanan S3/Garage S3` |
| Data | `/opt/ansibro/garage` di data1, data2, data3 |
| Backup | Sebagian disimpan |
| Pemeriksaan kesehatan | `TCP 3900` |

- Access key adalah "GK" diikuti isi file garage\_access\_key; region "garage". Jumlah salinan tidak bisa diubah setelah instalasi pertama.
- Mengubah file kunci menambah kunci kedua; kunci lama tetap berlaku sampai dihapus dengan perintah garage.

## Portainer {#app-portainer}

Halaman web untuk melihat dan mengelola container dan stack di cluster.

| Hal | Keterangan |
|:----------------|:-------------------------------------------------------|
| Berjalan di | manager1 |
| Halaman web | <https://portainer.nusa.example.co.id/> (login sendiri) |
| Dari laptop | browser web |
| Kredensial | `01 Login web/Portainer` |
| Data | `/opt/ansibro/portainer` |
| Backup | Disalin saat dijeda |
| Pemeriksaan kesehatan | `POST /api/auth` |

- File kata sandi hanya dibaca saat Portainer pertama kali jalan. Setelah itu kata sandi diganti di halaman Portainer.

## PostgreSQL {#app-postgres}

Database SQL untuk aplikasi Anda (dan untuk Kong, Keycloak, Authelia).

| Hal | Keterangan |
|:----------------|:-------------------------------------------------------|
| Berjalan di | data1 (utama saat instalasi), data2, data3 |
| PostgreSQL | `10.0.0.21:5432`, `10.0.0.22:5432`, `10.0.0.23:5432`; aplikasi di cluster memakai `database-proxy_haproxy:5432` |
| Dari laptop | tunnel SSH ([bab 5](#access)) |
| Kredensial | `02 Database dan cache/PostgreSQL` |
| Data | `/opt/ansibro/postgres` di data1, data2, data3 |
| Backup | Dump database |
| Pemeriksaan kesehatan | `pg_isready` |

- Dengan 2 server atau lebih, PostgreSQL berjalan dengan Patroni. Server utama (primary) bisa berpindah; aplikasi di cluster memakai database-proxy.
- Naik versi mayor (misalnya 18 ke 19) butuh dump dan restore manual.

## Redis {#app-redis}

Penyimpanan key-value di memori, untuk cache dan sesi login.

| Hal | Keterangan |
|:----------------|:-------------------------------------------------------|
| Berjalan di | data1 (utama saat instalasi), data2, data3 |
| Redis | `10.0.0.21:6379`, `10.0.0.22:6379`, `10.0.0.23:6379` |
| Dari laptop | tunnel SSH ([bab 5](#access)) |
| Kredensial | `02 Database dan cache/Redis` |
| Data | `/opt/ansibro/redis` di data1, data2, data3 |
| Backup | Disalin saat dijeda |
| Pemeriksaan kesehatan | `redis-cli ping` |

- Dengan 3 server ada satu primary dan dua salinan, dipantau Sentinel (port 26379, nama master "ansibro").

## Traefik {#app-traefik}

Pintu masuk semua halaman web. Menerima HTTPS untuk domain dan meneruskan tiap subdomain ke aplikasinya, lengkap dengan sertifikat.

| Hal | Keterangan |
|:----------------|:-------------------------------------------------------|
| Berjalan di | manager1, manager2, manager3 |
| Halaman web | <https://traefik.nusa.example.co.id/dashboard/> (login Authelia dengan kode dari ponsel Anda (2FA)) |
| Dari laptop | browser web |
| Kredensial | `01 Login web/Traefik` |
| Data | `/opt/ansibro/traefik` |
| Backup | Disalin saat dijeda |
| Pemeriksaan kesehatan | `traefik healthcheck --ping` |

- Kata sandi Traefik tidak diperlukan untuk halaman admin, karena halaman admin memakai login Authelia dengan kode dari ponsel Anda (2FA).

## Uptime Kuma {#app-uptimekuma}

Memeriksa setiap menit bahwa halaman web Anda menjawab, dan memberi tahu bila ada yang mati.

| Hal | Keterangan |
|:----------------|:-------------------------------------------------------|
| Berjalan di | data2 |
| Halaman web | <https://uptimekuma.nusa.example.co.id/> (login sendiri) |
| Dari laptop | browser web |
| Kredensial | `01 Login web/Uptime Kuma` |
| Data | `/opt/ansibro/uptimekuma` di data2 |
| Backup | Disalin saat dijeda |
| Pemeriksaan kesehatan | `TCP 3001` |

- Monitor dibuat sekali saat instalasi pertama. Notifikasi (email, Telegram, dan lainnya) harus diatur sendiri di Uptime Kuma.

## Victoria monitoring {#app-victoria}

Pemantauan lengkap. Metrik, log, aturan peringatan, Grafana, dan peringatan ke Telegram, email, atau webhook.

| Hal | Keterangan |
|:----------------|:-------------------------------------------------------|
| Berjalan di | data1 |
| Halaman web | <https://grafana.nusa.example.co.id/> (login sendiri) |
|  | <https://alertmanager.nusa.example.co.id/> (login Authelia dengan kode dari ponsel Anda (2FA)) |
|  | <https://metrics.nusa.example.co.id/vmui> (login Authelia dengan kode dari ponsel Anda (2FA)) |
|  | <https://logs.nusa.example.co.id/select/vmui> (login Authelia dengan kode dari ponsel Anda (2FA)) |
| Dari laptop | browser web |
| Kredensial | `01 Login web/Grafana` |
| Data | `/opt/ansibro/victoria`, `/opt/ansibro/monitoring-agent` di data1 |
| Backup | Sebagian disimpan |
| Pemeriksaan kesehatan | `Watchdog alert` |

- Riwayat metrik dan log tidak ikut di-backup; yang di-backup adalah pengaturan, Grafana, dan Alertmanager.

# Akses dari laptop Anda {#access}

Bab ini menunjukkan langkah demi langkah cara menjangkau sistem dari laptop Windows, macOS, atau Linux.

## Siapa butuh apa {#access-who}

Bagian ini menjelaskan, langkah demi langkah, cara menjangkau sistem dari komputer Anda sendiri. Bagian ini ditulis untuk Windows, macOS, Linux. Di Windows, perintah diketik di **PowerShell** (buka menu Start, ketik "PowerShell"). Di macOS dan Linux, perintah diketik di aplikasi **Terminal**. Setiap langkah menjelaskan apa tujuannya, apa yang diketik, apa yang seharusnya tampil, dan apa yang dilakukan bila gagal.

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
Get-FileHash .\maju-kredensial.kdbx -Algorithm SHA<size>
```

macOS (Terminal):

```sh
shasum -a <size> maju-kredensial.kdbx
```

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
| `admin_allow_from`   | Halaman web admin                      | 198.51.100.0/24, 192.0.2.10 |

Daftar yang kosong berarti sistem **terbuka untuk siapa saja** di internet untuk daftar itu: satu-satunya pelindung adalah kata sandi.
Bila daftar diisi, alamat yang tidak tercantum akan mendapat "403 Forbidden" di halaman admin, atau tidak mendapat jawaban (timeout) di SSH. Hal ini juga terjadi bila alamat internet rumah Anda berubah, bila Anda berada di balik proxy kantor, atau bila koneksi Anda hanya punya alamat IPv6.

**Bila gagal:** hanya operator yang bisa menambahkan alamat: ia menambahkannya ke daftar di pengaturan installer (config.yml), lalu menjalankan installer lagi. Kirimkan alamat Anda kepada vendor atau operator Anda.

## Halaman web {#access-web}

### Memeriksa nama {#access-web-dns}

Tujuan: memastikan komputer Anda menemukan halaman web sistem di bawah nusa.example.co.id.

macOS dan Linux (Terminal):

```sh
ping -c 1 authelia.nusa.example.co.id
```

Windows (PowerShell):

```powershell
ping -n 1 authelia.nusa.example.co.id
```

**Yang seharusnya tampil:** alamat 203.0.113.11 atau 203.0.113.12 atau 203.0.113.13. Itulah server yang melayani halaman web. Balasan ping tidak wajib: sebagian jaringan memblokir ping, tetapi alamatnya harus benar.

Nama-nama ini berasal dari DNS publik (semacam buku telepon internet), dengan satu catatan untuk setiap nama di bawah nusa.example.co.id.

**Bila gagal:** "could not find host" berarti nama itu tidak dikenal. Minta vendor memeriksa catatan DNS-nya.

### Sertifikat {#access-web-tls}

Sistem ini tidak punya sertifikat yang dapat dipercaya komputer Anda (pengaturan "selfsigned"). Browser akan memberi peringatan di setiap halaman, dan muncul lagi setiap kali gateway (pintu masuk halaman web) dijalankan ulang. Hal ini memang sudah diperkirakan. Untuk tetap melanjutkan:

- Chrome dan Edge: klik "Advanced", lalu "Proceed".
- Firefox: klik "Advanced", lalu "Accept the Risk and Continue".
- Safari: klik "Show Details", lalu "visit this website".

Peringatan ini aman dilewati hanya untuk alamat yang ada di tabel di bawah. Saran: gunakan sertifikat sungguhan (pengaturan "custom", atau server ACME privat); lihat masalah yang diketahui dalam dokumen ini.

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

### Menyimpan kunci Anda {#access-ssh-key}

Tujuan: menaruh kunci yang dibuatkan vendor untuk Anda di tempat yang benar. Kunci itu adalah lampiran maju_ed25519 pada entri "04 Infrastruktur/SSH key (client)" di file kredensial. Simpan dengan nama ini:

macOS dan Linux (Terminal):

```sh
mkdir -p ~/.ssh
# save the attachment as ~/.ssh/maju_ed25519, then:
chmod 600 ~/.ssh/maju_ed25519
```

Windows (PowerShell):

```powershell
New-Item -ItemType Directory -Force "$env:USERPROFILE\.ssh"
# save the attachment as $env:USERPROFILE\.ssh\maju_ed25519
```

**Yang seharusnya tampil:** file maju_ed25519 ada di folder .ssh Anda.

**Bila gagal:** bila lampirannya tidak ada, tanyakan kepada vendor.

### Menambahkan pengaturan SSH {#access-ssh-config}

Tujuan: memberi setiap server nama pendek, sehingga Anda cukup mengetik `ssh maju-manager1`. File **ssh_config.txt** dari paket serah terima berisi pengaturannya; tambahkan ke akhir file pengaturan SSH Anda:

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
Di macOS, Anda bisa menambahkan dua baris di bawah setiap baris `Host` agar frasa sandi kunci disimpan di Keychain: `UseKeychain yes` dan `AddKeysToAgent yes`.

**Yang seharusnya tampil:** baris-baris `Host` di akhir file.

**Bila gagal:** bila sebelumnya sudah ada `Host` dengan nama yang sama, hapus yang lama.

### Koneksi pertama {#access-ssh-first}

Tujuan: login sekali ke server pertama dan memastikan bahwa server itu asli.

macOS dan Linux (Terminal):

```sh
ssh maju-manager1
```

Windows (PowerShell):

```powershell
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

macOS dan Linux (Terminal):

```sh
chmod 600 ~/.ssh/maju_ed25519
```

Windows (PowerShell):

```powershell
icacls $env:USERPROFILE\.ssh\maju_ed25519 /inheritance:r `
  /grant:r "$($env:USERNAME):(R)"
```

### Mengingat frasa sandi kunci {#access-ssh-agent}

Tujuan: mengetik frasa sandi kunci sekali per sesi, tidak di setiap login.

Windows (PowerShell):

```powershell
Get-Service ssh-agent | Set-Service -StartupType Automatic
Start-Service ssh-agent
ssh-add $env:USERPROFILE\.ssh\maju_ed25519
```

macOS (Terminal):

```sh
ssh-add --apple-use-keychain ~/.ssh/maju_ed25519
```

Linux (Terminal):

```sh
ssh-add ~/.ssh/maju_ed25519
```

Di Windows, dua baris pertama perlu PowerShell yang dibuka sebagai administrator.

**Yang seharusnya tampil:** "Identity added".

**Bila gagal:** "Could not open a connection to your authentication agent" berarti agent (program penyimpan kunci) tidak berjalan: jalankan baris-baris Windows di atas sebagai administrator.

## Database dan layanan lain: tunnel SSH {#access-tunnel}

Database dan layanan sejenis hanya mendengarkan di dalam cluster (kumpulan server), dan lalu lintas datanya tidak terenkripsi. Untuk menjangkaunya, Anda membuka tunnel SSH: pipa pribadi melalui SSH dari laptop Anda ke server. Tunnel ini sekaligus mengenkripsi lalu lintasnya.

### Menjalankan tunnel {#access-tunnel-start}

Tujuan: membuka semua pipa sekaligus dengan nama `maju-tunnel` dari ssh_config.txt.

macOS dan Linux (Terminal):

```sh
ssh -N maju-tunnel
```

Windows (PowerShell):

```powershell
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

macOS dan Linux (Terminal):

```sh
psql "host=127.0.0.1,127.0.0.1,127.0.0.1
      port=15432,15433,15434 user=postgres
      target_session_attrs=read-write"
```

Windows (PowerShell):

```powershell
psql "host=127.0.0.1,127.0.0.1,127.0.0.1
      port=15432,15433,15434 user=postgres
      target_session_attrs=read-write"
```

Server utama (primary) bisa berpindah di antara data1, data2, data3; baris ini mencoba setiap port dan memakai port yang menerima perubahan data.

Redis *(belum diuji)*:

macOS dan Linux (Terminal):

```sh
redis-cli -h 127.0.0.1 -p 16379 --askpass
```

Windows (PowerShell):

```powershell
redis-cli -h 127.0.0.1 -p 16379 --askpass
```

Dengan 3 server, hanya server utama (primary) yang menerima perubahan, dan server utama itu bisa berpindah. Cari dulu yang mana; jawabannya berupa alamat server dari tabel di atas, jadi pakai port laptop pada baris tersebut:

macOS dan Linux (Terminal):

```sh
ssh maju-data1 "sudo docker exec redis-sentinel redis-cli -p 26379 \
  sentinel get-master-addr-by-name ansibro"
```

Windows (PowerShell):

```powershell
ssh maju-data1 ("sudo docker exec redis-sentinel redis-cli -p 26379 " +
  "sentinel get-master-addr-by-name ansibro")
```

Garage (penyimpanan file S3). Access key-nya diawali GK; region-nya garage. Masukkan dulu kunci dari "03 Penyimpanan S3/Garage S3" ke `aws configure`:

macOS dan Linux (Terminal):

```sh
aws --endpoint-url http://127.0.0.1:13900 --region garage s3 ls
```

Windows (PowerShell):

```powershell
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

macOS dan Linux (Terminal):

```sh
ssh -t maju-manager1 sudo docker service ls
```

Windows (PowerShell):

```powershell
ssh -t maju-manager1 sudo docker service ls
```

**Yang seharusnya tampil:** daftar service, masing-masing dengan "REPLICAS" seperti 1/1.

**Bila gagal:** lihat [SSH](#access-ssh). Koneksi Docker jarak jauh (`docker context create maju --docker host=ssh://maju-manager1`) hanya bekerja bila user SSH boleh memakai Docker tanpa sudo. ansibro tidak mengatur hal ini, dan akses itu memberi kendali penuh atas server, jadi vendor yang memutuskan.

### Image milik Anda sendiri {#access-cluster-images}

Tujuan: menjalankan image (paket aplikasi siap jalan) milik Anda sendiri. Registry image (registry.ansibro:5000) hanya bisa dijangkau dari server, jadi Anda mengirim image lewat SSH lalu mendorongnya (push) di server pertama:

macOS dan Linux (Terminal):

```sh
docker save app:1 | ssh maju-manager1 "sudo docker load"
ssh maju-manager1 "sudo docker tag app:1 registry.ansibro:5000/app:1 && \
  sudo docker push registry.ansibro:5000/app:1"
```

Windows (PowerShell):

```powershell
docker save app:1 | ssh maju-manager1 "sudo docker load"
ssh maju-manager1 ("sudo docker tag app:1 registry.ansibro:5000/app:1 && " +
  "sudo docker push registry.ansibro:5000/app:1")
```

`app:1` adalah nama dan versi image Anda. Di Mac dengan Apple Silicon, buat image dengan `--platform linux/amd64`: server memakai prosesor Intel atau AMD. Registry tidak termasuk dalam backup: setelah pemulihan (restore), push lagi image Anda.

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

**Bila gagal:** kata sandi di lampiran itu adalah kata sandi pada hari serah terima. Setelah kata sandi diganti, masukkan dulu nilai barunya ke file yang sesuai di state/secrets/, seperti dijelaskan dalam dokumen ini.

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

# Kredensial dan penggantian kata sandi {#credentials}

## File kredensial {#credentials-file}

Semua kata sandi ada di satu file terkunci, `maju-kredensial.kdbx`. File ini berformat KeePass. Buka file ini dengan KeePassXC ([bab 5](#access)).
Kata sandi pembuka file ini (*frasa sandi* atau *passphrase*) dikirim terpisah melalui telepon kepada Siti Rahma. Dokumen ini maupun berita acara serah terima tidak memuat kata sandi apa pun.

File ini berisi kelompok berikut:

| Kelompok | Isinya | Siapa yang memerlukan |
|:-------------------------------|:------------------------------------------|:-------------------|
| 01 Login web | Authelia, Grafana, Portainer, Traefik, Uptime Kuma | semua yang mengelola halaman web |
| 02 Database dan cache | PostgreSQL, Redis | operator |
| 03 Penyimpanan S3 | Garage S3 | operator |
| 04 Infrastruktur | Image registry | operator |
| 05 Pemulihan (darurat) | Backup (restic), config.yml backup.s3_access_key, config.yml backup.s3_secret_key, config.yml monitoring.webhook | simpan baik-baik; hanya untuk pemulihan |
| 06 Internal (menjalankan ulang ansibro) | 12 kata sandi teknis, ditambah file "ansibro installer files" (untuk menjalankan ulang ansibro) | hanya untuk menjalankan ulang ansibro |
| 07 Lama (aplikasi yang sudah dihapus) | Swarmpit | tidak ada (sisa aplikasi yang sudah dihapus) |

## Akun {#credentials-accounts}

Berikut akun yang dipakai orang. Kolom kelas menunjukkan cara mengganti kata sandinya (lihat bagian berikutnya).

| Akun | Untuk | Entri di file kredensial | Cara mengganti | Batas waktu |
|:----------------|:-----------|:------------------------------|:----------------|:-----------|
| Authelia | pemakaian harian | `01 Login web/Authelia` | Aplikasi dulu | dalam 7 hari |
| Garage S3 | pemakaian harian | `03 Penyimpanan S3/Garage S3` | File dulu | dalam 7 hari |
| Grafana | pemakaian harian | `01 Login web/Grafana` | Aplikasi dan file bersamaan (belum diuji) | dalam 7 hari |
| Portainer | pemakaian harian | `01 Login web/Portainer` | Aplikasi dulu | dalam 7 hari |
| PostgreSQL | pemakaian harian | `02 Database dan cache/PostgreSQL` | Aplikasi dan file bersamaan (belum diuji) | dalam 7 hari |
| Redis | pemakaian harian | `02 Database dan cache/Redis` | File dulu | dalam 7 hari |
| Image registry | pemulihan | `04 Infrastruktur/Image registry` | Aplikasi dan file bersamaan | saat akses vendor berakhir |
| Backup (restic) | pemulihan | `05 Pemulihan (darurat)/Backup (restic)` | Aplikasi dan file bersamaan | saat akses vendor berakhir |
| Traefik | pemakaian harian | `01 Login web/Traefik` | File dulu | dalam 7 hari |
| Uptime Kuma | pemakaian harian | `01 Login web/Uptime Kuma` | Aplikasi dulu | dalam 7 hari |
| Frasa sandi file kredensial | semua | (file itu sendiri) | KeePassXC | dalam 7 hari |

## Cara mengganti kata sandi {#credentials-change}

ansibro menyimpan salinan semua kata sandi di folder `state/` pada komputer yang menjalankan program instalasi. Salinan ini dipakai setiap kali ansibro dijalankan. Karena itu, kata sandi harus diganti di tempat yang benar. Jika tidak, instalasi berikutnya akan membatalkan perubahan Anda atau gagal.

### File dulu {#credentials-file-first}

Berlaku untuk: Garage S3, Redis, Traefik.
ansibro menulis kata sandi ini ke aplikasi setiap kali dijalankan. Perubahan yang hanya dilakukan di aplikasi akan dibatalkan pada instalasi berikutnya.

1. Di komputer instalasi, tulis kata sandi baru di file `state/secrets/<name>`.
2. Jalankan `./install.sh`.
3. Perbarui file kredensial, juga setiap aplikasi milik Anda yang memakai kata sandi ini.

### Aplikasi dan file bersamaan {#credentials-both}

Berlaku untuk: PostgreSQL, Image registry, Backup (restic), Grafana.
ansibro login dengan kata sandi ini, atau kata sandi ini diperlukan untuk pemulihan. Jika hanya satu tempat yang diubah, instalasi berikutnya gagal.

1. Ganti kata sandi di aplikasi.
2. Pada saat yang sama, tulis kata sandi yang sama di `state/secrets/<name>` pada komputer instalasi.
3. Jalankan `./install.sh`, lalu uji penerimaan (`tests/check.py`).
4. Perbarui file kredensial.

- **Backup (restic):** jalankan `sudo restic -r <repository> key passwd` di satu server, tulis kata sandi baru di `state/secrets/restic`, lalu jalankan `./install.sh` (perintah ini menulis ulang `/opt/ansibro/backup/password` di setiap server). Simpan kata sandi lama sampai kata sandi baru terbukti berfungsi: tanpa kata sandi lama, backup lama tidak dapat dibaca.
- Grafana, PostgreSQL: cara aplikasi menerima kata sandi baru belum diuji, jadi perlakukan sebagai "aplikasi dan file bersamaan".

### Aplikasi dulu {#credentials-app-first}

Berlaku untuk: Authelia, Portainer, Uptime Kuma.
Aplikasi hanya membaca kata sandi ini saat pertama kali menyala. Setelah itu, kata sandi dikelola oleh aplikasi.

1. Ganti kata sandi di aplikasi.
2. Tulis kata sandi yang sama di `state/secrets/<name>`, agar catatan dan uji penerimaan tetap benar.
3. Perbarui file kredensial.

- **Authelia:** file `users.yml` di manager1 adalah daftar akun Authelia yang berlaku.

### Jangan diubah {#credentials-internal}

Kata sandi di kelompok "06 Internal (menjalankan ulang ansibro)" hanya dipakai antarprogram. Tidak ada orang yang mengetiknya. Ganti hanya jika bocor, dan serahkan kepada operator ansibro.

- **Garage:** mengubah file kunci Garage menambah kunci kedua; kunci lama tetap berlaku sampai dihapus dengan perintah garage.

> **Penting:** file ringkasan milik ansibro menyebut "ganti di aplikasi, lalu perbarui juga filenya". Petunjuk itu salah untuk kelas "file dulu" dan "aplikasi dan file bersamaan". Ikuti bab ini.

## Kode dari ponsel Anda (2FA) {#credentials-2fa}

Login admin meminta kata sandi dan kode dari *aplikasi autentikator* di ponsel (*2FA*, login dua faktor).
Vendor sudah menyiapkannya selama pekerjaan. Daftarkan ponsel Anda sendiri:

1. Login di <https://authelia.nusa.example.co.id/> dengan akun Authelia.
2. Pilih pendaftaran perangkat baru. Authelia tidak punya server email, jadi tautan konfirmasinya ditulis ke `/opt/ansibro/authelia/config/notification.txt` di manager1.
3. Operator membaca file itu melalui SSH dan memberikan tautannya kepada Anda.
4. Pindai kodenya dengan aplikasi autentikator Anda.

## Siapa yang memegang state/ {#credentials-state}

**PT Maju Bersama memegang `state/`.** File kredensial berisi lampiran "ansibro installer files" (`config.yml` dan semua file kata sandi), sehingga operator Anda sendiri dapat menjalankan ulang ansibro 1.2.0.

## Mengakhiri akses vendor {#credentials-revoke}

Tanggal yang direncanakan: 4 Desember 2026. Pada tanggal itu:

1. Hapus kunci SSH vendor dari `~/.ssh/authorized_keys` milik pengguna `ubuntu` di setiap server. ansibro tidak mengelola kunci SSH.
2. Hapus alamat vendor dari `ssh.allow_from` dan `admin_allow_from` di `config.yml`, lalu jalankan `./install.sh`.
3. Ganti kata sandi seperti dijelaskan di atas.
4. Perhatikan bahwa nilai lama masih tersimpan di `/opt/ansibro/backup/installer/state/secrets/` di manager1 dan di backup yang lebih lama.
5. Vendor menghapus salinan `state/` miliknya setelah Anda setujui.

## Mengganti frasa sandi file kredensial {#credentials-passphrase}

Di KeePassXC: menu **"Database → Database Security"**, lalu atur kata sandi baru. (Di KeePass 2: **"File → Change Master Key"**.) Simpan salinan cadangan file ini di tempat yang aman.

## Menambah staf {#credentials-staff}

- Tambahkan orang tersebut ke `users.yml` Authelia di manager1.
- Tambahkan alamat internetnya ke `admin_allow_from` (halaman web) dan `ssh.allow_from` (SSH, khusus operator) di `config.yml`, lalu jalankan `./install.sh`.
- Untuk operator: tambahkan kunci publik SSH-nya ke `~/.ssh/authorized_keys` milik `ubuntu` di setiap server.

# Backup dan pemulihan {#backup}

*Backup* adalah salinan data yang disimpan di tempat lain, agar data dapat dikembalikan (*dipulihkan*, *restore*) setelah hilang.

## Pengaturan {#backup-settings}

| Pengaturan | Nilai |
|:--------------------|:---------------------------------------------------|
| Backup | Aktif, dengan *restic* (program backup) di setiap server |
| Tujuan | s3: `https://s3.example.com/my-bucket` |
| Jadwal | Setiap malam pukul 02:00 (UTC). Jadwal yang terlewat dijalankan saat server menyala berikutnya |
| Disimpan | 7 harian, 4 mingguan, dan 6 bulanan *snapshot* per server |
| Kata sandi | `05 Pemulihan (darurat)/Backup (restic)` di file kredensial |

*Snapshot* adalah satu backup lengkap pada satu waktu tertentu.

## Apa yang disimpan {#backup-what}

| Aplikasi | Cara | Artinya |
|:-----------|:---------------------|:------------------------------------------------|
| Authelia | Disalin saat dijeda | aplikasi dijeda sebentar lalu foldernya disalin |
| Garage | Sebagian disimpan | hanya sebagian folder yang disimpan (lihat catatan aplikasi) |
| Portainer | Disalin saat dijeda | aplikasi dijeda sebentar lalu foldernya disalin |
| PostgreSQL | Dump database | ekspor lengkap database |
| Redis | Disalin saat dijeda | aplikasi dijeda sebentar lalu foldernya disalin |
| Traefik | Disalin saat dijeda | aplikasi dijeda sebentar lalu foldernya disalin |
| Uptime Kuma | Disalin saat dijeda | aplikasi dijeda sebentar lalu foldernya disalin |
| Victoria monitoring | Sebagian disimpan | hanya sebagian folder yang disimpan (lihat catatan aplikasi) |
| Registry image | Tidak disimpan | image diunduh ulang |
| etcd | Tidak disimpan | dibangun ulang |
| manager1 | Tambahan | state Swarm, `config.yml`, dan file kata sandi |

Tidak disimpan: volume Docker, dan aplikasi milik Anda sendiri kecuali file-nya berada di `/opt/ansibro/<name>/`.

## Cara memeriksa {#backup-check}

Di server mana pun, setelah login SSH:

```sh
sudo ansibro-backup snapshots
systemctl is-active ansibro-backup.timer
journalctl -u ansibro-backup
```

`sudo ansibro-backup` langsung membuat backup saat itu juga.
Peringatan **BackupTooOld** muncul jika sebuah server tidak punya backup yang berhasil selama 26 jam.

## Memulihkan seluruh sistem {#backup-restore}

ansibro memulihkan seluruh sistem sekaligus, ke server baru.

1. Siapkan server baru yang kosong (Ubuntu 24.04 atau 26.04) dengan **nama dan IP cluster yang sama**; dengan WireGuard, hanya alamat SSH yang boleh berbeda.
2. Pertahankan pengaturan `backup:` yang sama di `config.yml`, dan `state/` yang sama.
3. Jalankan:

   ```sh
   ./install.sh -e restore=true
   ```

4. Setiap server mendapatkan kembali snapshot terbarunya, lalu aplikasi menyala. Jalankan `tests/check.py` untuk memeriksa.

**Jika `state/` juga hilang,** ambil kembali dulu dari backup manager1. Anda memerlukan kata sandi restic dan kredensial penyimpanan dari file kredensial:

```sh
restic -r <repository> restore latest --host manager1 \
  --include /opt/ansibro/backup/stage/installer --target .
```

Tidak didukung: memulihkan satu aplikasi, satu database, atau titik waktu yang lebih lama, serta memulihkan ke cluster yang sedang berjalan.

Latihan pemulihan terakhir (uji coba restore): 2 November 2026.

# Pemantauan dan peringatan {#monitoring}

*Pemantauan* (*monitoring*) mengawasi server dan aplikasi. *Peringatan* (*alert*) adalah pesan yang dikirim saat ada masalah.

## Sistem pemantauan {#monitoring-tool}

Victoria monitoring berjalan di data1. Sistem ini menyimpan metrik dan log selama 30 hari.

| Halaman | Alamat |
|:----------------------|:-------------------------------------------------|
| Grafana (dasbor) | <https://grafana.nusa.example.co.id/> |
| Alertmanager (peringatan, silence) | <https://alertmanager.nusa.example.co.id/> |
| Metrik | <https://metrics.nusa.example.co.id/vmui> |
| Log | <https://logs.nusa.example.co.id/select/vmui> |

Peringatan dikirim ke:
**slack** melalui `hooks.slack.com`.
Peringatan tingkat warning dan critical dikirim ke tempat yang sama. Selama masalahnya belum selesai, peringatan diulang setiap 4 jam.

**Siapa yang mengawasi server pemantauan?**
Uptime Kuma, di server lain, memeriksa bahwa server pemantauan masih hidup.

**Membungkam peringatan:** untuk menghentikan peringatan sementara (misalnya saat pekerjaan terencana), buka Alertmanager dan buat sebuah *silence*.

## Aturan peringatan {#monitoring-rules}

Ada 35 aturan yang berlaku untuk sistem ini. *Critical* berarti segera ditangani; *warning* berarti perlu dilihat dalam waktu dekat. Isi peringatan dikirim dalam bahasa Inggris, jadi keterangan yang belum diterjemahkan di tabel ini juga tetap berbahasa Inggris.

| Peringatan aplikasi | Tingkat | Artinya |
|:-------------------------|:---------|:------------------------------------------------|
| AppDown | critical | Sebuah aplikasi tidak menjawab di port-nya. |
| ContainerDown | critical | Sebuah container (aplikasi yang sudah dikemas) berhenti. |
| ContainerRestarting | warning | Container \<container\> on \<node\> restarted … times in 15 minutes. |
| ContainerOutOfMemory | warning | Container \<container\> on \<node\> was stopped because it used too much memory. |
| SwarmServiceDown | critical | Sebuah aplikasi cluster berjalan dengan salinan lebih sedikit dari seharusnya. |
| SwarmNodeDown | critical | Cluster melaporkan salah satu servernya tidak siap. |
| WebAppDown | critical | Sebuah halaman web tidak dapat dibuka melalui pintu masuk (Traefik). |
| WebAppErrors | warning | … of the requests to \<service\> fail with a 5xx error. |
| CertificateEndsSoon | warning | The certificate for \<sans\> ends in … days. |

| Peringatan backup | Tingkat | Artinya |
|:-------------------------|:---------|:------------------------------------------------|
| BackupTooOld | critical | Backup terakhir yang berhasil dari sebuah server sudah lebih dari 26 jam. |

| Peringatan database | Tingkat | Artinya |
|:-------------------------|:---------|:------------------------------------------------|
| PostgresDown | critical | Sebuah server database PostgreSQL tidak menjawab. |
| PostgresTooManyConnections | warning | PostgreSQL on \<node\> uses … of its connections. |
| PostgresNoPrimary | critical | Tidak ada server database yang menerima penulisan, sehingga aplikasi tidak dapat menyimpan data. |
| PostgresReplicaBehind | warning | The PostgreSQL replica on \<node\> is … behind the primary. |
| CacheDown | critical | Sebuah server cache tidak menjawab. |
| CacheNoPrimary | critical | Tidak ada server cache yang menerima penulisan. |
| CacheMemoryFull | warning | \<job\> on \<node\> uses … of its memory limit. |
| CacheRejectsConnections | warning | \<job\> on \<node\> refused connections (too many clients). |

| Peringatan pemantauan | Tingkat | Artinya |
|:-------------------------|:---------|:------------------------------------------------|
| TargetDown | critical | Server pemantauan tidak dapat membaca salah satu sumbernya, sehingga sebagian sistem tidak terpantau. |
| AlertsNotSent | warning | Alertmanager could not send alerts to \<integration\>. Check monitoring: in config.yml. |
| AlertRulesFailing | warning | Some alert rules cannot be checked, so their alerts would not fire. |
| MetricsScriptNotRunning | warning | ansibro-metrics did not run on \<node\> for 5 minutes. App, backup and swarm checks there are blind. |
| LogsNotSent | warning | The log agent on \<node\> cannot send logs to the monitoring server. |

| Peringatan server | Tingkat | Artinya |
|:-------------------------|:---------|:------------------------------------------------|
| NodeDown | critical | Sebuah server mati atau tidak dapat dihubungi. |
| NodeRebooted | warning | Server \<node\> restarted. |
| DiskAlmostFull | warning | Disk \<mountpoint\> on \<node\> is … full. |
| DiskFull | critical | Sebuah disk hampir penuh. Aplikasi di disk itu bisa berhenti atau kehilangan data. |
| DiskFillsSoon | warning | At this speed, disk \<mountpoint\> on \<node\> is full within a day. |
| InodesAlmostFull | warning | Disk \<mountpoint\> on \<node\> has almost no free inodes (too many small files). |
| MemoryAlmostFull | warning | Memory on \<node\> is … used. |
| OutOfMemoryKill | warning | Linux stopped a program on \<node\> because memory was full. |
| CpuBusy | warning | CPU on \<node\> is … busy for 15 minutes. |
| ClockNotSynced | warning | The clock on \<node\> is not in sync. Certificates, logins and the swarm need the right time. |
| SystemdServiceFailed | warning | … system service(s) failed on \<node\>. Run: systemctl --failed |

| Peringatan wireguard | Tingkat | Artinya |
|:-------------------------|:---------|:------------------------------------------------|
| WireGuardPeerDown | critical | Dua server tidak dapat berkomunikasi melalui jalur terenkripsinya. |

## Uptime Kuma {#monitoring-uptimekuma}

Uptime Kuma di <https://uptimekuma.nusa.example.co.id/> memeriksa setiap menit bahwa halaman web menjawab. Pemeriksaannya dibuat pada instalasi pertama.

> **Penting:** Uptime Kuma tidak mengirim notifikasi sampai Anda menambahkannya di menu "Settings" (email, Telegram, dan sebagainya). Lakukan ini saat serah terima, lalu uji.

# Panduan operasional {#runbook}

## Aturan utama {#runbook-rules}

1. **Setiap perubahan dilakukan melalui `config.yml`,** lalu jalankan `./install.sh`. Perintah ini hanya mengubah yang berbeda, dan aman dijalankan ulang setelah gagal.
2. **Selalu jalankan dari komputer yang menyimpan `state/`.** Di komputer lain, ansibro membuat kata sandi baru yang tidak cocok dengan sistem yang berjalan.
3. `--check` (uji coba tanpa perubahan) tidak didukung.

**Siapa yang dapat menjalankan program instalasi:** komputer macOS atau Linux dengan Python 3.12 atau lebih baru, ansibro 1.2.0, `config.yml`, dan `state/`. Saat ini: PT Maju Bersama.

## Prosedur {#runbook-procedures}

Semua perintah di server dijalankan setelah login SSH (lihat [bab 5](#access)). `/opt/ansibro` milik root, jadi perintahnya memakai `sudo`.

### Menambah atau menghapus aplikasi {#runbook-app}

- **Menambah:** tambahkan aplikasi di bagian `apps:` pada `config.yml`, lalu jalankan `./install.sh`.
- **Menghapus:** hapus aplikasi dari `config.yml`, lalu jalankan `./install.sh`. Aplikasi berhenti; datanya tetap di `/opt/ansibro/<app>` sampai Anda menghapusnya dengan `sudo rm -rf`.
- **Memeriksa:** `tests/check.py`.

### Menambah atau menghapus server {#runbook-server}

- **Menambah:** tambahkan server di `nodes:` **setelah** manager1, lalu jalankan `./install.sh`.
- **Menghapus:** pindahkan dulu aplikasinya, hapus server dari `config.yml`, lalu jalankan:

  ```sh
  ./install.sh -e remove_nodes=true
  ```

- **Jangan pernah menghapus manager1.**

### Menaikkan atau menurunkan peran server {#runbook-promote}

Di manager1: `sudo docker node promote <name>` (worker menjadi manager) atau `sudo docker node demote <name>`.

### Mengubah manager saat PostgreSQL memakai Patroni {#runbook-patroni}

Di setiap manager, hentikan dan kosongkan etcd, lalu jalankan `./install.sh`. Selama sekitar 60 detik database tidak menerima penulisan.

```sh
cd /opt/ansibro/etcd && sudo docker compose down && sudo rm -rf data managers
```

### Memperbarui aplikasi atau Docker {#runbook-upgrade}

1. Di `versions.yml`, ubah tag **dan** digest aplikasi. Baca digest-nya dengan `docker buildx imagetools inspect <image>:<tag>`.
2. Jalankan `./install.sh`. Docker diperbarui satu server demi satu server.
3. Pembaruan versi besar PostgreSQL (misalnya 18 ke 19) memerlukan dump dan restore manual.

### Menyalakan ulang aplikasi {#runbook-restart}

- Aplikasi cluster: `sudo docker service update --force <stack>_<service>` di manager1. Lihat daftar layanannya dengan `sudo docker service ls`.
- Aplikasi di server tertentu: `cd /opt/ansibro/<app> && sudo docker compose restart` di server itu.

### Setelah server dinyalakan ulang {#runbook-reboot}

- Aplikasi menyala dengan sendirinya. Backup yang terlewat dijalankan saat server menyala.

### Terkunci dari SSH {#runbook-locked}

Buka konsol server di halaman web penyedia server, login, lalu jalankan `sudo ufw disable`. Setelah itu perbaiki `ssh.allow_from` dan jalankan `./install.sh` (firewall akan aktif kembali).

### Batas Docker Hub (toomanyrequests) {#runbook-dockerhub}

Tunggu beberapa saat, atau login ke Docker Hub dengan `sudo docker login` di manager1.

### Label server {#runbook-labels}

ansibro hanya menambah label. Hapus label dengan `sudo docker node update --label-rm <label> <name>`.

## Panduan menangani insiden {#runbook-incidents}

Yang perlu dilakukan saat peringatan critical masuk: periksa dulu, lalu perbaiki, lalu eskalasikan ke tim dukungan ([bab 11](#support)) jika belum selesai dalam satu jam.

### NodeDown {#incident-nodedown}

- **Artinya:** sebuah server mati atau tidak dapat dihubungi.
- **Periksa:** kondisi server di halaman web penyedia server; lalu coba SSH.
- **Perbaiki:** nyalakan server. Setelah server kembali, aplikasi menyala dengan sendirinya.
- **Eskalasi:** jika server tidak mau menyala.

### DiskFull {#incident-diskfull}

- **Artinya:** sebuah disk sudah terisi lebih dari 95%.
- **Periksa:** `df -h` di server itu.
- **Perbaiki:** hapus file lama yang tidak diperlukan, atau perbesar disk di penyedia server.
- **Eskalasi:** jika Anda tidak tahu apa yang memenuhi disk.

### AppDown dan ContainerDown {#incident-appdown}

- **Artinya:** sebuah aplikasi tidak menjawab, atau container-nya berhenti.
- **Periksa:** `sudo docker ps` dan `sudo docker logs <app>` di server itu.
- **Perbaiki:** `cd /opt/ansibro/<app> && sudo docker compose restart`.
- **Eskalasi:** jika aplikasi berhenti lagi.

### SwarmServiceDown {#incident-servicedown}

- **Artinya:** sebuah aplikasi cluster berjalan dengan salinan lebih sedikit dari seharusnya.
- **Periksa:** `sudo docker service ps <service>` dan `sudo docker service logs <stack>_<service>` di manager1.
- **Perbaiki:** `sudo docker service update --force <stack>_<service>`.
- **Eskalasi:** jika jumlah salinan tidak kembali normal.

### PostgresNoPrimary {#incident-postgres}

- **Artinya:** tidak ada server PostgreSQL yang menerima penulisan. Aplikasi tidak dapat menyimpan data.
- **Periksa:** `sudo docker exec postgres patronictl list` di salah satu server database.
- **Perbaiki:** pastikan etcd berjalan di semua manager dan server database menyala.
- **Eskalasi:** segera.

### CacheNoPrimary {#incident-cache}

- **Artinya:** tidak ada server cache yang menerima penulisan.
- **Periksa:** `sudo docker exec valkey-sentinel valkey-cli -p 26379 SENTINEL masters` (untuk Redis, namanya `redis-sentinel` dan `redis-cli`).
- **Perbaiki:** nyalakan server cache yang berhenti; Sentinel akan memilih primary baru.
- **Eskalasi:** segera.

### BackupTooOld {#incident-backup}

- **Artinya:** sebuah server tidak punya backup yang berhasil selama 26 jam.
- **Periksa:** `journalctl -u ansibro-backup` dan `systemctl is-active ansibro-backup.timer` di server itu.
- **Perbaiki:** atasi kesalahan yang tertulis di log, lalu jalankan `sudo ansibro-backup`.
- **Eskalasi:** jika tempat penyimpanan backup tidak dapat dihubungi atau penuh.

### CertificateEndsSoon {#incident-cert}

- **Artinya:** sebuah sertifikat web akan berakhir dalam 14 hari.
- **Periksa:** tanggalnya melalui ikon gembok di browser.
- **Perbaiki:** ganti file sertifikat dan file kunci, lalu jalankan `./install.sh`.
- **Eskalasi:** seminggu sebelum sertifikat berakhir.

### WireGuardPeerDown {#incident-wireguard}

- **Artinya:** dua server tidak dapat berkomunikasi melalui WireGuard.
- **Periksa:** `sudo wg show` di kedua server.
- **Perbaiki:** pastikan port UDP 51820 terbuka di antara keduanya dan kedua server menyala.
- **Eskalasi:** jika jalurnya tetap terputus.

## Yang tidak dikerjakan ansibro {#runbook-not}

| Pekerjaan | Penanggung jawab yang disarankan |
|:------------------------------------|:------------------------------------------|
| Pembaruan keamanan sistem operasi | Operator PT Maju Bersama, atau tim dukungan |
| Memperbarui ansibro itu sendiri | pemegang `state/` (PT Maju Bersama) |
| Memperbarui sertifikat registry (berlaku 10 tahun sejak instalasi pertama) | pemegang `state/` |
| Menambah dan menghapus kunci SSH | Operator PT Maju Bersama |

# Keamanan {#security}

## Apa yang terbuka ke internet {#security-exposure}

Halaman berikut terbuka untuk siapa saja. Setiap halaman punya login sendiri, atau memang ditujukan untuk publik:

- <https://authelia.nusa.example.co.id/>

Siapa yang dapat menjangkau sisanya:

- SSH: siapa saja (daftarnya kosong).
- Halaman admin: 198.51.100.0/24, 192.0.2.10.

## Lalu lintas di dalam cluster {#security-plaintext}

Layanan berikut berkomunikasi tanpa enkripsi, sehingga hanya terbuka untuk server dalam cluster: Garage, PostgreSQL, Redis.
WireGuard mengenkripsi lalu lintas ini antarserver.
Di dalam cluster, port pemantauan (8428, 9428, 8880, 9093, dan 3000) tidak memakai login.

## Salinan kata sandi di server {#security-copies}

Server menyimpan salinan kata sandi yang hanya dapat dibaca oleh root:

- `/opt/ansibro/backup/installer/state/secrets/` di manager1: **semua kata sandi**, diperbarui setiap instalasi, dan ikut tersimpan di setiap backup manager1.
- `/opt/ansibro/backup/password` di setiap server: kata sandi backup.
- File `.env` di `/opt/ansibro/<app>/` untuk aplikasi yang memakainya.
- `/opt/ansibro/portainer/admin_password`.
- `/opt/ansibro/authelia/config/` (konfigurasi, pengguna, dan notifikasi).
- `/root/.docker/config.json` (login registry).

Jadi siapa pun yang punya akses root di manager1, atau yang memegang kata sandi backup dan tempat penyimpanannya, memiliki semua kata sandi.
Di komputer instalasi, `state/` **tidak terenkripsi**. Rekomendasi: aktifkan enkripsi ansibro (age).

## Kunci SSH {#security-ssh}

*Kunci SSH* adalah sepasang file yang memungkinkan seseorang login tanpa kata sandi. ansibro tidak menambah atau menghapus kunci SSH. Siapa yang boleh login ditentukan oleh daftar di `~/.ssh/authorized_keys` milik `ubuntu` di setiap server; jaga daftar itu tetap pendek dan hapus kunci orang yang sudah tidak bertugas.

## Lisensi yang perlu diperhatikan {#security-agpl}

Garage, Redis, Victoria monitoring memakai lisensi AGPL (untuk Victoria: Grafana). Pemakaiannya gratis. Jika Anda mengubah kodenya dan menyediakannya melalui jaringan, Anda wajib memublikasikan perubahan tersebut. Lihat [Lampiran B](#appendix-licenses).

## Masa berlaku sertifikat {#security-certs}

| Sertifikat | Berakhir |
|:------------------------------|:------------------------------------------|
| Halaman web (self-signed) | dibuat ulang setiap kali menyala |
| Registry image (internal) | 10 tahun setelah instalasi pertama |

# Dukungan {#support}

Hubungi orang-orang berikut, sesuai urutan:

| Nama | Peran | Telepon | Email |
|:-------------------|:-------------------|:-------------------|:------------------------------|
| Rina Wijaya | Project Manager | \+62 812 0000 1111 | rina\@nusa.example |

| Hal | Keterangan |
|:--------------------|:---------------------------------------------------|
| Perusahaan | PT Nusantara Teknologi |
| Telepon | \+62 21 555 0101 |
| Email | support\@nusa.example |
| Situs web | https://nusa.example |
| Jam layanan | Senin-Jumat 09.00-17.00 WIB |
| Waktu respons | Respons dalam 4 jam kerja |
| Garansi | 3 bulan, sampai 4 Februari 2027 |
| Cakupan garansi | Perbaikan kesalahan konfigurasi dari pekerjaan ini |
| Akses vendor berakhir | 4 Desember 2026 |

**Cara melaporkan masalah.** Sebutkan apa yang Anda lihat, kapan mulai terjadi, halaman atau server mana, dan apa yang sudah Anda coba. Tangkapan layar sangat membantu.

> **Penting:** jangan pernah mengirim kata sandi di laporan, email, atau chat. Tim dukungan tidak pernah memintanya.

# Uji penerimaan {#acceptance}

ansibro punya *uji penerimaan* sendiri (`tests/check.py`). Uji ini login ke setiap aplikasi dan memeriksa cluster, backup, serta pemantauan.

| Hal | Keterangan |
|:--------------------------|:---------------------------------------------|
| Tanggal | 2026-11-04 |
| Lulus | 9 |
| Gagal | 0 |
| Dilewati | 1 |

| Hasil | Pemeriksaan |
|:---------|:--------------------------------------------------------------|
| PASS | traefik: HTTP redirects to HTTPS |
| PASS | traefik: the dashboard needs a login |
| PASS | portainer: admin login works |
| PASS | authelia: the right password is accepted, a wrong one refused |
| PASS | postgres: a primary and 2 replicas |
| PASS | redis: Sentinel knows the primary |
| PASS | garage: 3 copies of every file |
| PASS | victoria: every target is up |
| PASS | uptimekuma: all monitors are up |
| SKIP | backup: no snapshot yet (first night not passed) |

Setiap halaman web juga dibuka dari luar pada hari yang sama:

| Alamat | Jawaban DNS | Sertifikat berakhir | Status |
|:------------------------------------|:-------------------|:-------------|:-----------------|
| <https://traefik.nusa.example.co.id/dashboard/> | 203.0.113.11 | 2027-11-04 | 302 |
| <https://portainer.nusa.example.co.id/> | 203.0.113.11 | 2027-11-04 | 200 |
| <https://authelia.nusa.example.co.id/> | 203.0.113.11 | 2027-11-04 | 200 |
| <https://grafana.nusa.example.co.id/> | 203.0.113.11 | 2027-11-04 | 302 |
| <https://uptimekuma.nusa.example.co.id/> | 203.0.113.11 | 2027-11-04 | 302 |

Status HTTP 200 berarti halaman terbuka; 302, 401, atau 403 berarti halaman meminta login atau alamat Anda tidak ada di daftar izin. Hal ini normal untuk halaman admin.
Sertifikatnya adalah sertifikat bawaan Traefik (self-signed), seperti dijelaskan di [bab 3](#servers-tls).

Berita acara serah terima memuat daftar periksa untuk sesi serah terima (lampiran pertamanya): setiap halaman web terbuka, setiap login berfungsi, 2FA sudah didaftarkan, file kredensial dapat dibuka, akses dari laptop berfungsi, ada backup terbaru, dan peringatan uji coba diterima.

# Lampiran A. Versi perangkat lunak {#appendix-versions .unnumbered}

| Aplikasi | Image | Tag | Digest |
|:-----------|:--------------------------------------|:-----------------|:-------------|
| Authelia | `docker.io/authelia/authelia` | 4.39.28 | `bd97cff4fcbf` |
| Garage | `docker.io/dxflrs/garage` | v2.5.0 | `677e5b758e44` |
| Portainer | `docker.io/portainer/portainer-ce` | 2.45.3 | `3609c307943b` |
|  | `docker.io/portainer/agent` | 2.45.3 | `6e6d2d5d8967` |
| PostgreSQL | `ghcr.io/zalando/spilo-18` | 4.1-p2 | `258a87d34699` |
|  | `quay.io/coreos/etcd` | v3.6.16 | `a9c7cc12156f` |
|  | `docker.io/library/haproxy` | 3.2.26 | `de853dd229e0` |
| Redis | `docker.io/library/redis` | 8.10.3 | `298641b35ac5` |
| Traefik | `docker.io/library/traefik` | v3.7.17 | `30ff62491aac` |
| Uptime Kuma | `docker.io/louislam/uptime-kuma` | 2.5.8 | `20abea8c48a1` |
| Victoria monitoring | `docker.io/victoriametrics/victoria-metrics` | v1.155.0 | `f60dc268b54e` |
|  | `docker.io/victoriametrics/victoria-logs` | v1.53.0 | `251121fa882a` |
|  | `docker.io/victoriametrics/vmalert` | v1.155.0 | `3256cba5ddac` |
|  | `docker.io/prom/alertmanager` | v0.34.2 | `39d8bb3966c6` |
|  | `docker.io/grafana/grafana` | 13.2.5 | `9f7aa1e1e324` |

| Komponen | Versi |
|:--------------------|:---------------------------------------------------|
| registry | 3.1.2 |
| database-proxy | 3.2.26 |
| etcd | v3.6.16 |
| monitoring-agents | v1.12.1 |
| docker-ce | 29.9.2-1 |
| docker-ce-cli | 29.9.2-1 |
| containerd.io | 2.4.2-3 |
| docker-buildx-plugin | 0.38.1-1 |
| docker-compose-plugin | 5.6.1-1 |
| ansibro | 1.2.0 |
| dejavu | 1.0.0 |

Digest adalah 12 karakter pertama sidik jari image (sha256). Digest memastikan image yang dipakai persis sama.

# Lampiran B. Lisensi {#appendix-licenses .unnumbered}

Semua bagian sistem ini adalah perangkat lunak sumber terbuka (open source).

| Bagian | Lisensi |
|:-----------------|:------------------------------------------------------|
| Authelia | Apache-2.0 |
| Garage | AGPL-3.0 |
| Portainer | zlib |
| PostgreSQL | PostgreSQL |
| Redis | AGPL-3.0 (Redis 8 is tri-licensed, used under AGPL) |
| Traefik | MIT |
| Uptime Kuma | MIT |
| Victoria monitoring | Apache-2.0 (VictoriaMetrics, VictoriaLogs, Alertmanager), AGPL-3.0 (Grafana) |
| registry | Apache-2.0 |
| database-proxy | GPL-2.0 |
| etcd | Apache-2.0 |
| monitoring-agents | Apache-2.0 |
| backup | BSD-2-Clause |
| wireguard | GPL-2.0 |

# Lampiran C. Konfigurasi {#appendix-config .unnumbered}

Berikut `config.yml` sebagaimana dibaca oleh ansibro, disusun ulang oleh dejavu. Komentar di file aslinya hilang, sebagian nilai adalah nilai bawaan, dan setiap rahasia diganti dengan lokasinya di file kredensial. Komentar di dalam blok di bawah ini sengaja dibiarkan dalam bahasa Inggris, seperti di file aslinya.

```yaml
domain: nusa.example.co.id
orchestrator: swarm
tls: selfsigned
timezone: UTC
ssh:
  user: ubuntu
  port: 22
  key: <your SSH private key>
admin_allow_from: [198.51.100.0/24, 192.0.2.10]
wireguard: true
nodes:
  - {name: data1, ip: 10.0.0.21, host: 203.0.113.21, role: standalone}
  - {name: data2, ip: 10.0.0.22, host: 203.0.113.22, role: standalone}
  - {name: data3, ip: 10.0.0.23, host: 203.0.113.23, role: standalone}
  - {name: manager1, ip: 10.0.0.11, host: 203.0.113.11, role: manager}
  - {name: manager2, ip: 10.0.0.12, host: 203.0.113.12, role: manager}
  - {name: manager3, ip: 10.0.0.13, host: 203.0.113.13, role: manager}
  - {name: worker1, ip: 10.0.0.31, host: 203.0.113.31, role: worker}
  - {name: worker2, ip: 10.0.0.32, host: 203.0.113.32, role: worker}
  - {name: worker3, ip: 10.0.0.33, host: 203.0.113.33, role: worker}
apps:
  authelia: swarm
  garage: [data1, data2, data3]
  portainer: swarm
  postgres: [data1, data2, data3]
  redis: [data1, data2, data3]
  traefik: swarm
  uptimekuma: data2
  victoria: data1
monitoring:
  webhook: <kdbx: 05 Pemulihan (darurat)/config.yml monitoring.webhook>
  keep_days: 30
backup:
  repository: s3:https://s3.example.com/my-bucket
  s3_access_key: <kdbx: 05 Pemulihan (darurat)/config.yml backup.s3_access_key>
  s3_secret_key: <kdbx: 05 Pemulihan (darurat)/config.yml backup.s3_secret_key>
  time: "02:00"
  keep_daily: 7
  keep_weekly: 4
  keep_monthly: 6
```

# Lampiran D. Pengaturan SSH {#appendix-ssh .unnumbered}

Baris-baris berikut dimasukkan ke file pengaturan SSH di laptop (`~/.ssh/config`; di Windows `%USERPROFILE%\.ssh\config`). Baris yang sama ada di file `ssh_config.txt`.

```text
# SSH settings for PT Maju Bersama (nusa.example.co.id), made by dejavu 1.0.0.
# Add these lines to ~/.ssh/config (Windows: %USERPROFILE%\.ssh\config).
# The key file is your own key (or the one from the credentials file), never the vendor's.

Host maju-data1
  HostName 203.0.113.21
  User ubuntu
  Port 22
  IdentityFile ~/.ssh/maju_ed25519
  IdentitiesOnly yes

Host maju-data2
  HostName 203.0.113.22
  User ubuntu
  Port 22
  IdentityFile ~/.ssh/maju_ed25519
  IdentitiesOnly yes

Host maju-data3
  HostName 203.0.113.23
  User ubuntu
  Port 22
  IdentityFile ~/.ssh/maju_ed25519
  IdentitiesOnly yes

Host maju-manager1
  HostName 203.0.113.11
  User ubuntu
  Port 22
  IdentityFile ~/.ssh/maju_ed25519
  IdentitiesOnly yes

Host maju-manager2
  HostName 203.0.113.12
  User ubuntu
  Port 22
  IdentityFile ~/.ssh/maju_ed25519
  IdentitiesOnly yes

Host maju-manager3
  HostName 203.0.113.13
  User ubuntu
  Port 22
  IdentityFile ~/.ssh/maju_ed25519
  IdentitiesOnly yes

Host maju-worker1
  HostName 203.0.113.31
  User ubuntu
  Port 22
  IdentityFile ~/.ssh/maju_ed25519
  IdentitiesOnly yes

Host maju-worker2
  HostName 203.0.113.32
  User ubuntu
  Port 22
  IdentityFile ~/.ssh/maju_ed25519
  IdentitiesOnly yes

Host maju-worker3
  HostName 203.0.113.33
  User ubuntu
  Port 22
  IdentityFile ~/.ssh/maju_ed25519
  IdentitiesOnly yes

# A private pipe to the databases and other services: run "ssh -N maju-tunnel" and keep it open.
# Then connect to 127.0.0.1 and the local port below.
Host maju-tunnel
  HostName 203.0.113.21
  User ubuntu
  Port 22
  IdentityFile ~/.ssh/maju_ed25519
  IdentitiesOnly yes
  ExitOnForwardFailure yes
  # S3 on data1
  LocalForward 13900 10.0.0.21:3900
  # S3 on data2
  LocalForward 13901 10.0.0.22:3900
  # S3 on data3
  LocalForward 13902 10.0.0.23:3900
  # PostgreSQL on data1
  LocalForward 15432 10.0.0.21:5432
  # PostgreSQL on data2
  LocalForward 15433 10.0.0.22:5432
  # PostgreSQL on data3
  LocalForward 15434 10.0.0.23:5432
  # Redis on data1
  LocalForward 16379 10.0.0.21:6379
  # Redis on data2
  LocalForward 16380 10.0.0.22:6379
  # Redis on data3
  LocalForward 16381 10.0.0.23:6379
```

# Lampiran E. Daftar periksa penggantian kata sandi {#appendix-passwords .unnumbered}

Centang setiap kata sandi yang sudah diganti, paling lambat 7 hari setelah serah terima. [Bab 6](#credentials) menjelaskan caranya.

| Cek | Akun | Entri di file kredensial | Diganti pada | Oleh |
|:----|:-------------------|:------------------------------|:-------------|:-------------|
| `☐` | Authelia | `01 Login web/Authelia` | | |
| `☐` | Garage S3 | `03 Penyimpanan S3/Garage S3` | | |
| `☐` | Grafana | `01 Login web/Grafana` | | |
| `☐` | Portainer | `01 Login web/Portainer` | | |
| `☐` | PostgreSQL | `02 Database dan cache/PostgreSQL` | | |
| `☐` | Redis | `02 Database dan cache/Redis` | | |
| `☐` | Image registry | `04 Infrastruktur/Image registry` | | |
| `☐` | Backup (restic) | `05 Pemulihan (darurat)/Backup (restic)` | | |
| `☐` | Traefik | `01 Login web/Traefik` | | |
| `☐` | Uptime Kuma | `01 Login web/Uptime Kuma` | | |
| `☐` | Frasa sandi file kredensial | | | |

# Lampiran F. Masalah yang diketahui dan rekomendasi {#appendix-issues .unnumbered}

- **Kata sandi dari aplikasi yang sudah dihapus (`swarmpit_admin`).** Kata sandi ini disimpan di kelompok "07 Lama (aplikasi yang sudah dihapus)" pada file kredensial, jadi tidak ada yang hilang. Kata sandi ini boleh dihapus jika Anda setuju.
- **Daftar izin `ssh.allow_from` kosong.** SSH dapat dijangkau dari alamat internet mana pun. Rekomendasi: cantumkan alamat kantor dan staf Anda.
- **Sertifikat self-signed.** Browser menampilkan peringatan di setiap halaman. Rekomendasi: pakai sertifikat dari otoritas sertifikat (CA) perusahaan Anda (`tls: custom`).
- **Notifikasi Uptime Kuma.** Notifikasi harus ditambahkan manual di menu "Settings" Uptime Kuma, lalu diuji.
- Notifikasi Uptime Kuma diatur klien setelah serah terima.

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
| uji penerimaan | `tests/check.py`, dijalankan pada 2026-11-04 |

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
| Patroni | Program yang memilih primary PostgreSQL baru saat primary berhenti. |
| Pemulihan (restore) | Mengembalikan data dari backup. |
| Peringatan (alert) | Pesan yang dikirim saat ada masalah. |
| Port | Pintu bernomor di server untuk satu jenis koneksi. |
| Primary | Satu-satunya server dalam kelompoknya yang menerima penulisan; server lain menyimpan salinan. |
| restic | Program backup. |
| Sentinel | Program yang memilih primary cache baru saat primary berhenti. |
| Sertifikat | File yang membuktikan sebuah halaman web asli dan mengenkripsi koneksinya. |
| Snapshot | Satu backup lengkap pada satu waktu tertentu. |
| SSH | Cara aman untuk login ke server dan mengetik perintah di sana. |
| state/ | Folder milik program instalasi yang berisi salinan semua kata sandi. |
| TLS | Enkripsi halaman web (huruf "s" pada https). |
| Traefik | Pintu masuk semua halaman web. |
| Tunnel | Jalur privat melalui SSH dari laptop ke sebuah layanan di server. |
| ufw | Program firewall di setiap server. |
| WireGuard | Jaringan terenkripsi antarserver. |
