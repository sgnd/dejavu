---
title: "HANDOVER AND ACCEPTANCE CERTIFICATE"
short-title: "Handover and Acceptance Certificate"
lang: en
docnumber: "001/BAST/NUSA/XI/2026"
version: "1.0"
date: "Wednesday, 4 November 2026"
classification: "CONFIDENTIAL"
labels: {page: "Page", of: "of", toc: "Contents"}
kop:
  name: "PT Nusantara Teknologi"
  address: "Jl. Gatot Subroto No. 9, Jakarta"
signatories:
  - {role: "THE PROVIDER", company: "PT Nusantara Teknologi", name: "Rina Wijaya", title: "Project Manager", meterai: false}

  - {role: "THE CLIENT", company: "PT Maju Bersama", name: "Siti Rahma", title: "Kepala Infrastruktur", meterai: true}

meterai-label: "Stamp duty (meterai) Rp10,000"
mengetahui-label: "Acknowledged by"
mengetahui-count: 1
mengetahui:
  - {name: "Hendra Gunawan", title: "Direktur TI", company: "PT Maju Bersama"}
---

```{=typst}
#align(center)[
```

**HANDOVER AND ACCEPTANCE CERTIFICATE**\
Number: 001/BAST/NUSA/XI/2026

```{=typst}
]
```

Basis: Pembangunan Platform Aplikasi, number SPK-017/MAJU/IX/2026, dated Tuesday, 1 September 2026.

On Wednesday, 4 November 2026, in Jakarta, the undersigned:

1. **Rina Wijaya**, Project Manager, acting for and on behalf of **PT Nusantara Teknologi**, Jl. Gatot Subroto No. 9, Jakarta, hereinafter called **the Provider**.
2. **Siti Rahma**, Kepala Infrastruktur, acting for and on behalf of **PT Maju Bersama**, Jl. Sudirman No. 1, Jakarta, hereinafter called **the Client**.

## 1. What is handed over {#bast-items}

The Provider hands over to the Client, and the Client states that it has received, the work and the items in the table below, in the condition stated there.
The system is in good and working order: the acceptance test of 2026-11-04 passed with no failures (Annex 1).

| No    | Item                       | Quantity and specification                                   | Condition       | Remarks                                       |
|:------|:---------------------------|:-------------------------------------------------------------|:----------------|:----------------------------------------------|
| 1 | The system (Produksi) | Docker Swarm cluster of 9 servers (data1, data2, data3, manager1, manager2, manager3, worker1, worker2, worker3), domain nusa.example.co.id, installed with ansibro 1.2.0 | Good and working | Last install 2026-11-03 |
| 2 | Applications | authelia 4.39.28, garage v2.5.0, portainer 2.45.3, postgres 18 (Spilo 4.1-p2), redis 8.10.3, traefik v3.7.17, uptimekuma 2.5.8, victoria v1.155.0 | Good and working | Details in chapter 4 of the technical documentation |
| 3 | Laptop access guide (Linux) | `en/maju-laptop-guide-linux.pdf`, version 1.0 | Complete | SHA-<size> `<sha<size>>` (Annex 3) |
| 4 | Laptop access guide (macOS) | `en/maju-laptop-guide-macos.pdf`, version 1.0 | Complete | SHA-<size> `<sha<size>>` (Annex 3) |
| 5 | Laptop access guide (Windows) | `en/maju-laptop-guide-windows.pdf`, version 1.0 | Complete | SHA-<size> `<sha<size>>` (Annex 3) |
| 6 | Technical documentation | `en/maju-technical-documentation.pdf`, version 1.0 | Complete | SHA-<size> `<sha<size>>` (Annex 3) |
| 7 | Technical documentation (Indonesian) | `id/maju-dokumentasi-teknis.pdf`, version 1.0 | Complete | SHA-<size> `<sha<size>>` (Annex 3) |
| 8 | Laptop access guide (Linux) (Indonesian) | `id/maju-panduan-laptop-linux.pdf`, version 1.0 | Complete | SHA-<size> `<sha<size>>` (Annex 3) |
| 9 | Laptop access guide (macOS) (Indonesian) | `id/maju-panduan-laptop-macos.pdf`, version 1.0 | Complete | SHA-<size> `<sha<size>>` (Annex 3) |
| 10 | Laptop access guide (Windows) (Indonesian) | `id/maju-panduan-laptop-windows.pdf`, version 1.0 | Complete | SHA-<size> `<sha<size>>` (Annex 3) |
| 11 | SSH settings for laptops | `ssh_config.txt` | Complete | SHA-256 `<sha256>` (Annex 3) |
| 12 | Credentials file (encrypted) | `maju-kredensial.kdbx`, <size> bytes; handed over via USB diserahkan langsung on Wednesday, 4 November <size> | Complete, encrypted | SHA-<size> `<sha<size>>` (Annex 3). The passphrase was given separately via telepon to Siti Rahma. These documents contain no passwords. |
| 13 | Domain and DNS | nusa.example.co.id; DNS: public DNS at Cloudflare | In use | Domain holder: PT Maju Bersama |
| 14 | Backup repository | restic, s3 at s3.example.com, every night at 02:00 (UTC) | In use | Its password is in the credentials file, group "05 Pemulihan (darurat)" |
| 15 | Accounts | Names only, no values: see Annex 2 | Handed over | Values only in the credentials file |

## 2. Duties after receipt {#bast-duties}

1. The Client changes every password meant for people (Annex 2) within 7 (seven) days of the date of this certificate, as described in chapter 6 and Appendix E of the technical documentation, and changes the passphrase of the credentials file. The Client keeps the credentials file as the record of the accounts.
2. On Friday, 4 December 2026, the Provider's SSH key and internet addresses are removed from the servers and the allow-lists.
3. The Client keeps the installer's records (ansibro's state/ folder), from the credentials file, group "06 Internal (menjalankan ulang ansibro)". The Provider deletes its own copy when the parties agree.

## 3. Warranty and maintenance {#bast-warranty}

- Warranty period: 3 (three) months, until Thursday, 4 February 2027.
- Scope: Perbaikan kesalahan konfigurasi dari pekerjaan ini.
- Support hours: Senin-Jumat 09.00-17.00 WIB. Response time: Respons dalam 4 jam kerja.
- From the date of this certificate, the risk for the system passes to the Client.

| Name                       | Role                     | Phone                    | Email                            |
|:---------------------------|:-------------------------|:-------------------------|:---------------------------------|
| Rina Wijaya | Project Manager | \+62 812 0000 1111 | rina\@nusa.example |

## 4. Acceptance test {#bast-acceptance}

The acceptance test ran on 2026-11-04: 9 passed, 0 failed, 1 skipped.
Last restore test: Monday, 2 November 2026.

## 5. Notes {#bast-notes}

- Known issue: Notifikasi Uptime Kuma diatur klien setelah serah terima.
- Open point: The allow-list ssh.allow_from is empty: open to anyone.
- Open point: The web pages have no trusted certificate (selfsigned): browsers show a warning.
- Open point: Uptime Kuma notifications must be set up by hand.
- Open point: Password files of removed apps remain (swarmpit_admin); they are kept in the credentials file, group "07 Lama (aplikasi yang sudah dihapus)".
- Not part of the work: Aplikasi bisnis milik klien

```{=typst}
#block(breakable: false)[
```

## 6. Closing {#bast-closing}

This certificate is made truthfully in 2 (two) copies, each with the same legal force, one for each party. It is also made in Indonesian; if the two versions differ in meaning, the Indonesian version prevails.

```{=typst}
#signatures()
```

```{=typst}
]
```

```{=typst}
#pagebreak()
```

## Annex 1. Acceptance checklist {#bast-annex-checklist}

Done together during the handover session. Each party initials each row.

| □ | Item                                   | How to check                                             | Result     | Provider   | Client     |
|:--|:---------------------------------------|:---------------------------------------------------------|:-----------|:-----------|:-----------|
| □ | <https://authelia.nusa.example.co.id/> opens | Open it in a browser (a certificate warning is expected) | | | |
| □ | <https://portainer.nusa.example.co.id/> opens | Open it in a browser (a certificate warning is expected) | | | |
| □ | <https://traefik.nusa.example.co.id/dashboard/> opens | Open it in a browser (a certificate warning is expected) | | | |
| □ | <https://uptimekuma.nusa.example.co.id/> opens | Open it in a browser (a certificate warning is expected) | | | |
| □ | <https://grafana.nusa.example.co.id/> opens | Open it in a browser (a certificate warning is expected) | | | |
| □ | <https://alertmanager.nusa.example.co.id/> opens | Open it in a browser (a certificate warning is expected) | | | |
| □ | <https://metrics.nusa.example.co.id/vmui> opens | Open it in a browser (a certificate warning is expected) | | | |
| □ | <https://logs.nusa.example.co.id/select/vmui> opens | Open it in a browser (a certificate warning is expected) | | | |
| □ | Each login works | Log in with each web entry of Annex 2 | | | |
| □ | 2FA set up on the Client's phone | Log in to an admin page with the 6-digit code | | | |
| □ | Credentials file opens, SHA-256 matches | Compare with Annex 3, then open it with the passphrase | | | |
| □ | Laptop access: Budi Santoso | Web pages, SSH and the tunnel from Windows | | | |
| □ | Laptop access: Siti Rahma | Web pages from macOS | | | |
| □ | Laptop access: Joko Prasetyo | Web pages, SSH, the tunnel and the installer from Linux | | | |
| □ | The Client's SSH key is on every server | `ssh maju-<server>` works for each server | | | |
| □ | The Client's addresses are allowed | Admin pages and SSH open from the Client's address | | | |
| □ | A backup under 26 hours old | `sudo ansibro-backup snapshots` on a server | | | |
| □ | Restore test | Done on 2026-11-02 | | | |
| □ | A test alert is received | The alert arrives on the agreed channel | | | |
| □ | Notifications set in Uptime Kuma | Each app's notification settings show a channel | | | |
| □ | System test (check.py) | `.venv/bin/python tests/check.py` | 9 PASS / 0 FAIL / 1 SKIP | | |

```{=typst}
#pagebreak()
```

## Annex 2. Accounts {#bast-annex-accounts}

The names of the accounts in the credentials file **maju-kredensial.kdbx**. No password is written here. The address is in each entry.

| App            | User          | Entry in the credentials file                   | Used for                      | How to change it                      |
|:---------------|:--------------|:------------------------------------------------|:------------------------------|:--------------------------------------|
| authelia | admin | 01 Login web/Authelia | People log in with it | In the app, then the file |
| garage | GK… (access key) | 03 Penyimpanan S3/Garage S3 | People log in with it | Edit the file, run the installer |
| victoria | admin | 01 Login web/Grafana | People log in with it | In the app, then the file (not tested) |
| portainer | admin | 01 Login web/Portainer | People log in with it | In the app, then the file |
| postgres | postgres | 02 Database dan cache/PostgreSQL | People log in with it | In the app and the file together (not tested) |
| redis | — | 02 Database dan cache/Redis | People log in with it | Edit the file, run the installer |
| registry | ansibro | 04 Infrastruktur/Image registry | Recovery (keep it safe) | In the app and the file together |
| backup | — | 05 Pemulihan (darurat)/Backup (restic) | Recovery (keep it safe) | In the app and the file together |
| traefik | admin | 01 Login web/Traefik | People log in with it | Edit the file, run the installer |
| uptimekuma | admin | 01 Login web/Uptime Kuma | People log in with it | In the app, then the file |
| config.yml | — | 05 Pemulihan (darurat)/config.yml backup.s3_access_key | Recovery (keep it safe) | In config.yml, run the installer |
| config.yml | — | 05 Pemulihan (darurat)/config.yml backup.s3_secret_key | Recovery (keep it safe) | In config.yml, run the installer |
| config.yml | — | 05 Pemulihan (darurat)/config.yml monitoring.webhook | Recovery (keep it safe) | In config.yml, run the installer |
| SSH | — | 04 Infrastruktur/SSH key (client) | The Client's SSH key (attachment) | Make a new key, replace it on every server |
| ansibro | — | 06 Internal (menjalankan ulang ansibro)/ansibro installer files | To run the installer again (attachment) | Goes out of date after password changes |

The group "06 Internal (menjalankan ulang ansibro)" also holds 12 internal entries that no person types, and "07 Lama (aplikasi yang sudah dihapus)" holds 1 from removed apps. The technical documentation, chapter 6, explains each change.

```{=typst}
#pagebreak()
```

## Annex 3. Delivered files {#bast-annex-files}

Each file with its size and SHA-256 code (a fingerprint of its content: the smallest change gives another code). The code of this certificate itself is in the file SHA256SUMS.

| File                                         | Size (bytes)   | SHA-256                                  |
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
| `ssh_config.txt` | 2,148 | `<sha256>` `<sha256>` |

To check a file: `Get-FileHash <file> -Algorithm SHA256` (Windows), `shasum -a 256 <file>` (macOS), `sha256sum <file>` (Linux).
