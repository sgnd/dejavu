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

  - {role: "THE CLIENT", company: "PT Maju Bersama", name: "Siti Rahma", title: "Kepala Infrastruktur", meterai: false}

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
Number: 001/BAST/NUSA/XI/2026\
Provisional handover (PHO)

```{=typst}
]
```

Basis: Pembangunan Platform Aplikasi, number SPK-017/MAJU/IX/2026, dated Tuesday, 1 September 2026.

On Wednesday, 4 November 2026, in Jakarta, the undersigned:

1. **Rina Wijaya**, Project Manager, acting for and on behalf of **PT Nusantara Teknologi**, Jl. Gatot Subroto No. 9, Jakarta, hereinafter called **the Provider**.
2. **Siti Rahma**, Kepala Infrastruktur, acting for and on behalf of **PT Maju Bersama**, Jl. Sudirman No. 1, Jakarta, hereinafter called **the Client**.

## 1. What is handed over {#bast-items}

The Provider states that the work is 100% complete, and hands it over provisionally to the Client. The Client accepts it, in the condition stated in the table below. The final handover is planned for Thursday, 4 February 2027. The warranty period starts on the date of this certificate.
The system has not yet been tested: the acceptance test has not been run. The checks are in Annex 1.

| No    | Item                       | Quantity and specification                                   | Condition       | Remarks                                       |
|:------|:---------------------------|:-------------------------------------------------------------|:----------------|:----------------------------------------------|
| 1 | The system (Production) | Kubernetes (k3s) cluster of 8 servers (data1, data2, data3, master1, master2, master3, worker1, worker2), domain platform.example.com, installed with ansibro 1.2.0 | Not yet tested | Last install 2026-11-03 |
| 2 | Applications | beszel 0.21.1, keycloak 26.8.1, kong 3.9.4, openbao 2.7.2, portainer 2.45.3, postgres 18 (Spilo 4.1-p2), traefik k3s v1.36.5+k3s1, valkey 9.1.3 | Not yet tested | Details in chapter 4 of the technical documentation |
| 3 | Laptop access guide (Windows) | `en/maju-laptop-guide-windows.pdf`, version 1.0 | Complete | SHA-<size> `<sha<size>>` (Annex 3) |
| 4 | Technical documentation | `en/maju-technical-documentation.pdf`, version 1.0 | Complete | SHA-<size> `<sha<size>>` (Annex 3) |
| 5 | Hosts file lines | `hosts.txt` | Complete | SHA-256 `<sha256>` (Annex 3) |
| 6 | SSH settings for laptops | `ssh_config.txt` | Complete | SHA-256 `<sha256>` (Annex 3) |
| 7 | Credentials file (encrypted) | `maju-credentials.kdbx`, <size> bytes; handed over via USB diserahkan langsung on Wednesday, 4 November <size> | Complete, encrypted | SHA-<size> `<sha<size>>` (Annex 3). The passphrase was given separately via telepon to Siti Rahma. These documents contain no passwords. |
| 8 | Domain and DNS | platform.example.com; DNS: hosts file (no DNS) | In use | Domain holder: Not provided |
| 9 | Backup repository | None | Not present | No backup is set up (see point 5) |
| 10 | Accounts | Names only, no values: see Annex 2 | Handed over | Values only in the credentials file |

## 2. Duties after receipt {#bast-duties}

1. The Client changes every password meant for people (Annex 2) within 7 (seven) days of the date of this certificate, as described in chapter 6 and Appendix E of the technical documentation, and changes the passphrase of the credentials file. The Client keeps the credentials file as the record of the accounts.
2. On Friday, 4 December 2026, the Provider's SSH key and internet addresses are removed from the servers and the allow-lists.
3. The Provider keeps the installer's records (ansibro's state/ folder), which are needed to change the system later. When the Client changes a password of the kind that the installer also uses, the Client sends the new value back to the Provider in a re-encrypted credentials file; otherwise the next install undoes the change or fails. The Client also has a copy of these records in the credentials file, so it can change provider at any time.

## 3. Warranty and maintenance {#bast-warranty}

- Warranty period: 3 (three) months, until Thursday, 4 February 2027.
- Scope: Perbaikan kesalahan konfigurasi dari pekerjaan ini.
- Support hours: Senin-Jumat 09.00-17.00 WIB. Response time: Respons dalam 4 jam kerja.
- From the date of this certificate, the risk for the system passes to the Client.

| Name                       | Role                     | Phone                    | Email                            |
|:---------------------------|:-------------------------|:-------------------------|:---------------------------------|
| Rina Wijaya | Project Manager | \+62 812 0000 1111 | rina\@nusa.example |

## 4. Acceptance test {#bast-acceptance}

The acceptance test has not been run yet. The checks are in Annex 1, to be done together during the handover session.
Last restore test: never done.

## 5. Notes {#bast-notes}

- Open point: The allow-list ssh.allow_from is empty: open to anyone.
- Open point: The allow-list admin_allow_from is empty: open to anyone.
- Open point: No backup is set up.
- Open point: Beszel alerts must be set up by hand.
- Not part of the work: The client's business applications

```{=typst}
#block(breakable: false)[
```

## 6. Closing {#bast-closing}

This certificate is made truthfully in 2 (two) copies, each with the same legal force, one for each party.

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
| □ | <https://beszel.platform.example.com/> opens | Open it in a browser | | | |
| □ | <https://keycloak.platform.example.com/> opens | Open it in a browser | | | |
| □ | <https://oauth.platform.example.com/> opens | Open it in a browser | | | |
| □ | <https://kong.platform.example.com/> opens | Open it in a browser | | | |
| □ | <https://kong-manager.platform.example.com/> opens | Open it in a browser | | | |
| □ | <https://openbao.platform.example.com/ui/> opens | Open it in a browser | | | |
| □ | <https://portainer.platform.example.com/> opens | Open it in a browser | | | |
| □ | <https://traefik.platform.example.com/dashboard/> opens | Open it in a browser | | | |
| □ | Each login works | Log in with each web entry of Annex 2 | | | |
| □ | 2FA set up on the Client's phone | Log in to an admin page with the 6-digit code | | | |
| □ | Credentials file opens, SHA-256 matches | Compare with Annex 3, then open it with the passphrase | | | |
| □ | Laptop access: Budi Santoso | Web pages, SSH and the tunnel from Windows | | | |
| □ | The Client's SSH key is on every server | `ssh maju-<server>` works for each server | | | |
| □ | The Client's addresses are allowed | The lists are empty (open to anyone): the Client confirms this | | | |
| □ | kubeconfig copied | `kubectl get nodes` works through the tunnel | | | |
| □ | Restore test | Not done | | | |
| □ | A test alert is received | The alert arrives on the agreed channel | | | |
| □ | Notifications set in Beszel | Each app's notification settings show a channel | | | |
| □ | The Client holds the OpenBao unseal key | Entry "05 Recovery (break-glass)/OpenBao unseal key" | | | |
| □ | System test (check.py) | `.venv/bin/python tests/check.py` |  | | |

```{=typst}
#pagebreak()
```

## Annex 2. Accounts {#bast-annex-accounts}

The names of the accounts in the credentials file **maju-credentials.kdbx**. No password is written here. The address is in each entry.

| App            | User          | Entry in the credentials file                   | Used for                      | How to change it                      |
|:---------------|:--------------|:------------------------------------------------|:------------------------------|:--------------------------------------|
| beszel | admin\@platform.example.com | 01 Web logins/Beszel | People log in with it | In the app and the file together |
| keycloak | admin | 01 Web logins/Keycloak (master) | People log in with it | In the app and the file together |
| keycloak | admin | 01 Web logins/Keycloak SSO (realm ansibro) | People log in with it | In the app, then the file |
| openbao | root | 01 Web logins/OpenBao root token | People log in with it | In the app and the file together |
| openbao | — | 05 Recovery (break-glass)/OpenBao unseal key | Recovery (keep it safe) | Only if it leaked |
| portainer | admin | 01 Web logins/Portainer | People log in with it | In the app, then the file |
| postgres | postgres | 02 Databases and cache/PostgreSQL | People log in with it | In the app and the file together (not tested) |
| registry | ansibro | 04 Infrastructure/Image registry | Recovery (keep it safe) | In the app and the file together |
| traefik | admin | 01 Web logins/Traefik | People log in with it | Edit the file, run the installer |
| valkey | — | 02 Databases and cache/Valkey | People log in with it | Edit the file, run the installer |
| ansibro | — | 06 Internal (re-run ansibro)/ansibro installer files | To run the installer again (attachment) | Goes out of date after password changes |

The group "06 Internal (re-run ansibro)" also holds 9 internal entries that no person types. The technical documentation, chapter 6, explains each change.

```{=typst}
#pagebreak()
```

## Annex 3. Delivered files {#bast-annex-files}

Each file with its size and SHA-256 code (a fingerprint of its content: the smallest change gives another code). The code of this certificate itself is in the file SHA256SUMS.

| File                                         | Size (bytes)   | SHA-256                                  |
|:---------------------------------------------|:---------------|:-----------------------------------------|
| `en/maju-laptop-guide-windows.pdf` | <size> | `<sha<size>>` `<sha<size>>` |
| `en/maju-technical-documentation.pdf` | <size> | `<sha<size>>` `<sha<size>>` |
| `hosts.txt` | 520 | `<sha256>` `<sha256>` |
| `maju-credentials.kdbx` | <size> | `<sha<size>>` `<sha<size>>` |
| `ssh_config.txt` | 2,143 | `<sha256>` `<sha256>` |

To check a file: `Get-FileHash <file> -Algorithm SHA256` (Windows), `shasum -a 256 <file>` (macOS), `sha256sum <file>` (Linux).
