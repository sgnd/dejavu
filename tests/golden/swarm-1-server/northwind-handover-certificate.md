---
title: "HANDOVER AND ACCEPTANCE CERTIFICATE"
short-title: "Handover and Acceptance Certificate"
lang: en
docnumber: "HC-2026-001"
version: "1.0"
date: "Wednesday, 4 November 2026"
classification: "CONFIDENTIAL"
labels: {page: "Page", of: "of", toc: "Contents"}
letterhead:
  name: "Bluewave Systems Ltd"
  address: "9 Market Square, London"
signatories:
  - {role: "THE PROVIDER", company: "Bluewave Systems Ltd", name: "Emma Clarke", title: "Project Manager"}

  - {role: "THE CLIENT", company: "Northwind Logistics Ltd", name: "Sarah Miller", title: "Head of Infrastructure"}

acknowledged-label: "Acknowledged by"
acknowledged-count: 1
acknowledged:
  - {name: "James Carter", title: "IT Director", company: "Northwind Logistics Ltd"}
---

```{=typst}
#align(center)[
```

**HANDOVER AND ACCEPTANCE CERTIFICATE**\
Number: HC-2026-001

```{=typst}
]
```

Basis: Application Platform Build, number PO-2026-017, dated Tuesday, 1 September 2026.

On Wednesday, 4 November 2026, in London, the undersigned:

1. **Emma Clarke**, Project Manager, acting for and on behalf of **Bluewave Systems Ltd**, 9 Market Square, London, hereinafter called **the Provider**.
2. **Sarah Miller**, Head of Infrastructure, acting for and on behalf of **Northwind Logistics Ltd**, 1 Harbour Street, London, hereinafter called **the Client**.

## 1. What is handed over {#certificate-items}

The Provider hands over to the Client, and the Client states that it has received, the work and the items in the table below, in the condition stated there.
The system has not yet been tested: the acceptance test has not been run. The checks are in Annex 1.

| No    | Item                       | Quantity and specification                                   | Condition       | Remarks                                       |
|:------|:---------------------------|:-------------------------------------------------------------|:----------------|:----------------------------------------------|
| 1 | The system (Production) | Docker Swarm cluster of 1 servers (server1), domain northwind.example.com, installed with ansibro 1.2.0 | Not yet tested | Last install 2026-11-03 |
| 2 | Applications | portainer 2.45.3, postgres 18.6, redis 8.10.3, rustfs 1.0.4, traefik v3.7.17, victoria v1.155.0 | Not yet tested | Details in chapter 4 of the technical documentation |
| 3 | Laptop access guide (macOS) | `northwind-laptop-guide-macos.pdf`, version 1.0 | Complete | SHA-<size> `<sha<size>>` (Annex 3) |
| 4 | Laptop access guide (Windows) | `northwind-laptop-guide-windows.pdf`, version 1.0 | Complete | SHA-<size> `<sha<size>>` (Annex 3) |
| 5 | Technical documentation | `northwind-technical-documentation.pdf`, version 1.0 | Complete | SHA-<size> `<sha<size>>` (Annex 3) |
| 6 | SSH settings for laptops | `ssh_config.txt` | Complete | SHA-256 `<sha256>` (Annex 3) |
| 7 | Credentials file (encrypted) | `northwind-credentials.kdbx`, <size> bytes; handed over via USB stick handed over in person on Wednesday, 4 November <size> | Complete, encrypted | SHA-<size> `<sha<size>>` (Annex 3). The passphrase was given separately via phone call to Sarah Miller. These documents contain no passwords. |
| 8 | Domain and DNS | northwind.example.com; DNS: public DNS at Cloudflare | In use | Domain holder: Northwind Logistics Ltd |
| 9 | Backup repository | restic, s3 at s3.example.com, every night at 02:00 (Europe/London) | In use | Its password is in the credentials file, group "05 Recovery (break-glass)" |
| 10 | Accounts | Names only, no values: see Annex 2 | Handed over | Values only in the credentials file |

## 2. Duties after receipt {#certificate-duties}

1. The Client changes every password meant for people (Annex 2) within 7 (seven) days of the date of this certificate, as described in chapter 6 and Appendix E of the technical documentation, and changes the passphrase of the credentials file. The Client keeps the credentials file as the record of the accounts.
2. On Friday, 4 December 2026, the Provider's SSH key and internet addresses are removed from the servers and the allow-lists.
3. The Provider keeps the installer's records (ansibro's state/ folder), which are needed to change the system later. When the Client changes a password of the kind that the installer also uses, the Client sends the new value back to the Provider in a re-encrypted credentials file; otherwise the next install undoes the change or fails. The Client also has a copy of these records in the credentials file, so it can change provider at any time.

## 3. Warranty and maintenance {#certificate-warranty}

- Warranty period: 3 (three) months, until Thursday, 4 February 2027.
- Scope: Fixes for configuration errors in this work.
- Support hours: Mon-Fri 09:00-17:00 UK time. Response time: Response within 4 business hours.
- From the date of this certificate, the risk for the system passes to the Client.

| Name                       | Role                     | Phone                    | Email                            |
|:---------------------------|:-------------------------|:-------------------------|:---------------------------------|
| Emma Clarke | Project Manager | \+44 20 7946 0111 | emma\@bluewave.example |

## 4. Acceptance test {#certificate-acceptance}

The acceptance test has not been run yet. The checks are in Annex 1, to be done together during the handover session.
Last restore test: never done.

## 5. Notes {#certificate-notes}

- Not part of the work: The client's business applications

```{=typst}
#block(breakable: false)[
```

## 6. Closing {#certificate-closing}

This certificate is signed in 2 (two) copies, each with the same legal force, one for each party.

```{=typst}
#signatures()
```

```{=typst}
]
```

```{=typst}
#pagebreak()
```

## Annex 1. Acceptance checklist {#certificate-annex-checklist}

Done together during the handover session. Each party initials each row.

| □ | Item                                   | How to check                                             | Result     | Provider   | Client     |
|:--|:---------------------------------------|:---------------------------------------------------------|:-----------|:-----------|:-----------|
| □ | <https://portainer.northwind.example.com/> opens | Open it in a browser | | | |
| □ | <https://rustfs.northwind.example.com/rustfs/console/> opens | Open it in a browser | | | |
| □ | <https://traefik.northwind.example.com/dashboard/> opens | Open it in a browser | | | |
| □ | <https://grafana.northwind.example.com/> opens | Open it in a browser | | | |
| □ | <https://alertmanager.northwind.example.com/> opens | Open it in a browser | | | |
| □ | <https://metrics.northwind.example.com/vmui> opens | Open it in a browser | | | |
| □ | <https://logs.northwind.example.com/select/vmui> opens | Open it in a browser | | | |
| □ | Each login works | Log in with each web entry of Annex 2 | | | |
| □ | Credentials file opens, SHA-256 matches | Compare with Annex 3, then open it with the passphrase | | | |
| □ | Laptop access: Tom Hughes | Web pages, SSH and the tunnel from Windows | | | |
| □ | Laptop access: Sarah Miller | Web pages from macOS | | | |
| □ | The Client's SSH key is on every server | `ssh northwind-<server>` works for each server | | | |
| □ | The Client's addresses are allowed | Admin pages and SSH open from the Client's address | | | |
| □ | A backup under 26 hours old | `sudo ansibro-backup snapshots` on a server | | | |
| □ | Restore test | Not done | | | |
| □ | A test alert is received | The alert arrives on the agreed channel | | | |
| □ | System test (check.py) | `.venv/bin/python tests/check.py` |  | | |

```{=typst}
#pagebreak()
```

## Annex 2. Accounts {#certificate-annex-accounts}

The names of the accounts in the credentials file **northwind-credentials.kdbx**. No password is written here. The address is in each entry.

| App            | User          | Entry in the credentials file                   | Used for                      | How to change it                      |
|:---------------|:--------------|:------------------------------------------------|:------------------------------|:--------------------------------------|
| victoria | admin | 01 Web logins/Grafana | People log in with it | In the app, then the file (not tested) |
| portainer | admin | 01 Web logins/Portainer | People log in with it | In the app, then the file |
| postgres | postgres | 02 Databases and cache/PostgreSQL | People log in with it | In the app and the file together (not tested) |
| redis | — | 02 Databases and cache/Redis | People log in with it | Edit the file, run the installer |
| registry | ansibro | 04 Infrastructure/Image registry | Recovery (keep it safe) | In the app and the file together |
| backup | — | 05 Recovery (break-glass)/Backup (restic) | Recovery (keep it safe) | In the app and the file together |
| rustfs | … (access key) | 03 S3 storage/RustFS S3 | People log in with it | Edit the file, run the installer (not tested) |
| traefik | admin | 01 Web logins/Traefik | People log in with it | Edit the file, run the installer |
| config.yml | — | 05 Recovery (break-glass)/config.yml backup.s3_access_key | Recovery (keep it safe) | In config.yml, run the installer |
| config.yml | — | 05 Recovery (break-glass)/config.yml backup.s3_secret_key | Recovery (keep it safe) | In config.yml, run the installer |
| config.yml | — | 05 Recovery (break-glass)/config.yml monitoring.telegram.bot_token | Recovery (keep it safe) | In config.yml, run the installer |
| ansibro | — | 06 Internal (re-run ansibro)/ansibro installer files | To run the installer again (attachment) | Goes out of date after password changes |

The group "06 Internal (re-run ansibro)" also holds 4 internal entries that no person types. The technical documentation, chapter 6, explains each change.

```{=typst}
#pagebreak()
```

## Annex 3. Delivered files {#certificate-annex-files}

Each file with its size and SHA-256 code (a fingerprint of its content: the smallest change gives another code). The code of this certificate itself is in the file SHA256SUMS.

| File                                         | Size (bytes)   | SHA-256                                  |
|:---------------------------------------------|:---------------|:-----------------------------------------|
| `northwind-credentials.kdbx` | <size> | `<sha<size>>` `<sha<size>>` |
| `northwind-laptop-guide-macos.pdf` | <size> | `<sha<size>>` `<sha<size>>` |
| `northwind-laptop-guide-windows.pdf` | <size> | `<sha<size>>` `<sha<size>>` |
| `northwind-technical-documentation.pdf` | <size> | `<sha<size>>` `<sha<size>>` |
| `ssh_config.txt` | 878 | `<sha256>` `<sha256>` |

To check a file: `Get-FileHash <file> -Algorithm SHA256` (Windows), `shasum -a 256 <file>` (macOS), `sha256sum <file>` (Linux).
