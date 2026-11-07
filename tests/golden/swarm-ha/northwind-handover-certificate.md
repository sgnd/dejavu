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
The system is in good and working order: the acceptance test of 2026-11-04 passed with no failures (Annex 1).

| No    | Item                       | Quantity and specification                                   | Condition       | Remarks                                       |
|:------|:---------------------------|:-------------------------------------------------------------|:----------------|:----------------------------------------------|
| 1 | The system (Production) | Docker Swarm cluster of 9 servers (data1, data2, data3, manager1, manager2, manager3, worker1, worker2, worker3), domain northwind.example.org, installed with ansibro 1.2.0 | Good and working | Last install 2026-11-03 |
| 2 | Applications | authelia 4.39.28, garage v2.5.0, portainer 2.45.3, postgres 18 (Spilo 4.1-p2), redis 8.10.3, traefik v3.7.17, uptimekuma 2.5.8, victoria v1.155.0 | Good and working | Details in chapter 4 of the technical documentation |
| 3 | Laptop access guide (Linux) | `northwind-laptop-guide-linux.pdf`, version 1.0 | Complete | SHA-<size> `<sha<size>>` (Annex 3) |
| 4 | Laptop access guide (macOS) | `northwind-laptop-guide-macos.pdf`, version 1.0 | Complete | SHA-<size> `<sha<size>>` (Annex 3) |
| 5 | Laptop access guide (Windows) | `northwind-laptop-guide-windows.pdf`, version 1.0 | Complete | SHA-<size> `<sha<size>>` (Annex 3) |
| 6 | Technical documentation | `northwind-technical-documentation.pdf`, version 1.0 | Complete | SHA-<size> `<sha<size>>` (Annex 3) |
| 7 | The Client's SSH public key | `northwind_ed25519.pub` | Complete | SHA-256 `<sha256>` (Annex 3) |
| 8 | SSH settings for laptops | `ssh_config.txt` | Complete | SHA-256 `<sha256>` (Annex 3) |
| 9 | Credentials file (encrypted) | `northwind-credentials.kdbx`, <size> bytes; handed over via USB stick handed over in person on Wednesday, 4 November <size> | Complete, encrypted | SHA-<size> `<sha<size>>` (Annex 3). The passphrase was given separately via phone call to Sarah Miller. These documents contain no passwords. |
| 10 | Domain and DNS | northwind.example.org; DNS: public DNS at Cloudflare | In use | Domain holder: Northwind Logistics Ltd |
| 11 | Backup repository | restic, s3 at s3.example.com, every night at 02:00 (UTC) | In use | Its password is in the credentials file, group "05 Recovery (break-glass)" |
| 12 | Accounts | Names only, no values: see Annex 2 | Handed over | Values only in the credentials file |

## 2. Duties after receipt {#certificate-duties}

1. The Client changes every password meant for people (Annex 2) within 7 (seven) days of the date of this certificate, as described in chapter 6 and Appendix E of the technical documentation, and changes the passphrase of the credentials file. The Client keeps the credentials file as the record of the accounts.
2. On Friday, 4 December 2026, the Provider's SSH key and internet addresses are removed from the servers and the allow-lists.
3. The Client keeps the installer's records (ansibro's state/ folder), from the credentials file, group "06 Internal (re-run ansibro)". The Provider deletes its own copy when the parties agree.

## 3. Warranty and maintenance {#certificate-warranty}

- Warranty period: 3 (three) months, until Thursday, 4 February 2027.
- Scope: Fixes for configuration errors in this work.
- Support hours: Mon-Fri 09:00-17:00 UK time. Response time: Response within 4 business hours.
- From the date of this certificate, the risk for the system passes to the Client.

| Name                       | Role                     | Phone                    | Email                            |
|:---------------------------|:-------------------------|:-------------------------|:---------------------------------|
| Emma Clarke | Project Manager | \+44 20 7946 0111 | emma\@bluewave.example |

## 4. Acceptance test {#certificate-acceptance}

The acceptance test ran on 2026-11-04: 9 passed, 0 failed, 1 skipped.
Last restore test: Monday, 2 November 2026.

## 5. Notes {#certificate-notes}

- Known issue: The client sets up the Uptime Kuma notifications after the handover.
- Open point: The allow-list ssh.allow_from is empty: open to anyone.
- Open point: The web pages have no trusted certificate (selfsigned): browsers show a warning.
- Open point: Uptime Kuma notifications must be set up by hand.
- Open point: Password files of removed apps remain (swarmpit_admin); they are kept in the credentials file, group "07 Old (removed apps)".
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
| □ | <https://authelia.northwind.example.org/> opens | Open it in a browser (a certificate warning is expected) | | | |
| □ | <https://portainer.northwind.example.org/> opens | Open it in a browser (a certificate warning is expected) | | | |
| □ | <https://traefik.northwind.example.org/dashboard/> opens | Open it in a browser (a certificate warning is expected) | | | |
| □ | <https://uptimekuma.northwind.example.org/> opens | Open it in a browser (a certificate warning is expected) | | | |
| □ | <https://grafana.northwind.example.org/> opens | Open it in a browser (a certificate warning is expected) | | | |
| □ | <https://alertmanager.northwind.example.org/> opens | Open it in a browser (a certificate warning is expected) | | | |
| □ | <https://metrics.northwind.example.org/vmui> opens | Open it in a browser (a certificate warning is expected) | | | |
| □ | <https://logs.northwind.example.org/select/vmui> opens | Open it in a browser (a certificate warning is expected) | | | |
| □ | Each login works | Log in with each web entry of Annex 2 | | | |
| □ | 2FA set up on the Client's phone | Log in to an admin page with the 6-digit code | | | |
| □ | Credentials file opens, SHA-256 matches | Compare with Annex 3, then open it with the passphrase | | | |
| □ | Laptop access: Tom Hughes | Web pages, SSH and the tunnel from Windows | | | |
| □ | Laptop access: Sarah Miller | Web pages from macOS | | | |
| □ | Laptop access: Priya Shah | Web pages, SSH, the tunnel and the installer from Linux | | | |
| □ | The Client's SSH key is on every server | `ssh northwind-<server>` works for each server | | | |
| □ | The Client's addresses are allowed | Admin pages and SSH open from the Client's address | | | |
| □ | A backup under 26 hours old | `sudo ansibro-backup snapshots` on a server | | | |
| □ | Restore test | Done on 2026-11-02 | | | |
| □ | A test alert is received | The alert arrives on the agreed channel | | | |
| □ | Notifications set in Uptime Kuma | Each app's notification settings show a channel | | | |
| □ | System test (check.py) | `.venv/bin/python tests/check.py` | 9 PASS / 0 FAIL / 1 SKIP | | |

```{=typst}
#pagebreak()
```

## Annex 2. Accounts {#certificate-annex-accounts}

The names of the accounts in the credentials file **northwind-credentials.kdbx**. No password is written here. The address is in each entry.

| App            | User          | Entry in the credentials file                   | Used for                      | How to change it                      |
|:---------------|:--------------|:------------------------------------------------|:------------------------------|:--------------------------------------|
| authelia | admin | 01 Web logins/Authelia | People log in with it | In the app, then the file |
| garage | GK… (access key) | 03 S3 storage/Garage S3 | People log in with it | Edit the file, run the installer |
| victoria | admin | 01 Web logins/Grafana | People log in with it | In the app, then the file (not tested) |
| portainer | admin | 01 Web logins/Portainer | People log in with it | In the app, then the file |
| postgres | postgres | 02 Databases and cache/PostgreSQL | People log in with it | In the app and the file together (not tested) |
| redis | — | 02 Databases and cache/Redis | People log in with it | Edit the file, run the installer |
| registry | ansibro | 04 Infrastructure/Image registry | Recovery (keep it safe) | In the app and the file together |
| backup | — | 05 Recovery (break-glass)/Backup (restic) | Recovery (keep it safe) | In the app and the file together |
| traefik | admin | 01 Web logins/Traefik | People log in with it | Edit the file, run the installer |
| uptimekuma | admin | 01 Web logins/Uptime Kuma | People log in with it | In the app, then the file |
| config.yml | — | 05 Recovery (break-glass)/config.yml backup.s3_access_key | Recovery (keep it safe) | In config.yml, run the installer |
| config.yml | — | 05 Recovery (break-glass)/config.yml backup.s3_secret_key | Recovery (keep it safe) | In config.yml, run the installer |
| config.yml | — | 05 Recovery (break-glass)/config.yml monitoring.webhook | Recovery (keep it safe) | In config.yml, run the installer |
| SSH | — | 04 Infrastructure/SSH key (client) | The Client's SSH key (attachment) | Make a new key, replace it on every server |
| ansibro | — | 06 Internal (re-run ansibro)/ansibro installer files | To run the installer again (attachment) | Goes out of date after password changes |

The group "06 Internal (re-run ansibro)" also holds 12 internal entries that no person types, and "07 Old (removed apps)" holds 1 from removed apps. The technical documentation, chapter 6, explains each change.

```{=typst}
#pagebreak()
```

## Annex 3. Delivered files {#certificate-annex-files}

Each file with its size and SHA-256 code (a fingerprint of its content: the smallest change gives another code). The code of this certificate itself is in the file SHA256SUMS.

| File                                         | Size (bytes)   | SHA-256                                  |
|:---------------------------------------------|:---------------|:-----------------------------------------|
| `northwind-credentials.kdbx` | <size> | `<sha<size>>` `<sha<size>>` |
| `northwind-laptop-guide-linux.pdf` | <size> | `<sha<size>>` `<sha<size>>` |
| `northwind-laptop-guide-macos.pdf` | <size> | `<sha<size>>` `<sha<size>>` |
| `northwind-laptop-guide-windows.pdf` | <size> | `<sha<size>>` `<sha<size>>` |
| `northwind-technical-documentation.pdf` | <size> | `<sha<size>>` `<sha<size>>` |
| `northwind_ed25519.pub` | 98 | `<sha256>` `<sha256>` |
| `ssh_config.txt` | 2,264 | `<sha256>` `<sha256>` |

To check a file: `Get-FileHash <file> -Algorithm SHA256` (Windows), `shasum -a 256 <file>` (macOS), `sha256sum <file>` (Linux).
