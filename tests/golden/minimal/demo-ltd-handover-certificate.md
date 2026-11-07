---
title: "HANDOVER AND ACCEPTANCE CERTIFICATE"
short-title: "Handover and Acceptance Certificate"
lang: en
docnumber: "Not provided"
version: "1.0"
date: "Not provided"
classification: "CONFIDENTIAL"
draft: true
labels: {page: "Page", of: "of", toc: "Contents"}
letterhead:
  name: "Not provided"
  address: "Not provided"
signatories:
  - {role: "THE PROVIDER", company: "Not provided", name: "Not provided", title: "Not provided"}

  - {role: "THE CLIENT", company: "Demo Ltd", name: "Not provided", title: "Not provided"}

---

```{=typst}
#align(center)[
```

**HANDOVER AND ACCEPTANCE CERTIFICATE**\
Number: Not provided

```{=typst}
]
```

Basis: Not provided, number Not provided, dated Not provided.

On Not provided, in Not provided, the undersigned:

1. **Not provided**, Not provided, acting for and on behalf of **Not provided**, Not provided, hereinafter called **the Provider**.
2. **Not provided**, Not provided, acting for and on behalf of **Demo Ltd**, Not provided, hereinafter called **the Client**.

## 1. What is handed over {#certificate-items}

The Provider hands over to the Client, and the Client states that it has received, the work and the items in the table below, in the condition stated there.
The system has not yet been tested: the acceptance test has not been run. The checks are in Annex 1.

| No    | Item                       | Quantity and specification                                   | Condition       | Remarks                                       |
|:------|:---------------------------|:-------------------------------------------------------------|:----------------|:----------------------------------------------|
| 1 | The system (demo.example.net) | Docker Swarm cluster of 1 servers (srv), domain demo.example.net, installed with ansibro 1.2.0 | Not yet tested | Last install 2026-11-03 |
| 2 | Applications | postgres 18.6, traefik v3.7.17 | Not yet tested | Details in chapter 4 of the technical documentation |
| 3 | Laptop access guide (Linux) | `demo-ltd-laptop-guide-linux.pdf`, version 1.0 | Complete | SHA-<size> `<sha<size>>` (Annex 3) |
| 4 | Laptop access guide (macOS) | `demo-ltd-laptop-guide-macos.pdf`, version 1.0 | Complete | SHA-<size> `<sha<size>>` (Annex 3) |
| 5 | Laptop access guide (Windows) | `demo-ltd-laptop-guide-windows.pdf`, version 1.0 | Complete | SHA-<size> `<sha<size>>` (Annex 3) |
| 6 | Technical documentation | `demo-ltd-technical-documentation.pdf`, version 1.0 | Complete | SHA-<size> `<sha<size>>` (Annex 3) |
| 7 | SSH settings for laptops | `ssh_config.txt` | Complete | SHA-256 `<sha256>` (Annex 3) |
| 8 | Credentials file (encrypted) | `demo-ltd-credentials.kdbx`, <size> bytes; handed over via Not provided on Not provided | Complete, encrypted | SHA-<size> `<sha<size>>` (Annex 3). The passphrase was given separately via Not provided to Not provided. These documents contain no passwords. |
| 9 | Domain and DNS | demo.example.net; DNS: public DNS | In use | Domain holder: Not provided |
| 10 | Backup repository | None | Not present | No backup is set up (see point 5) |
| 11 | Accounts | Names only, no values: see Annex 2 | Handed over | Values only in the credentials file |

## 2. Duties after receipt {#certificate-duties}

1. The Client changes every password meant for people (Annex 2) within 7 (seven) days of the date of this certificate, as described in chapter 6 and Appendix E of the technical documentation, and changes the passphrase of the credentials file. The Client keeps the credentials file as the record of the accounts.
2. On Not provided, the Provider's SSH key and internet addresses are removed from the servers and the allow-lists.
3. The Provider keeps the installer's records (ansibro's state/ folder), which are needed to change the system later. When the Client changes a password of the kind that the installer also uses, the Client sends the new value back to the Provider in a re-encrypted credentials file; otherwise the next install undoes the change or fails. The Client also has a copy of these records in the credentials file, so it can change provider at any time.

## 3. Warranty and maintenance {#certificate-warranty}

- Warranty period: Not provided, until Not provided.
- Scope: Not provided.
- Support hours: Not provided. Response time: Not provided.
- From the date of this certificate, the risk for the system passes to the Client.

Support contacts: Not provided.

## 4. Acceptance test {#certificate-acceptance}

The acceptance test has not been run yet. The checks are in Annex 1, to be done together during the handover session.
Last restore test: never done.

## 5. Notes {#certificate-notes}

- Open point: The allow-list ssh.allow_from is empty: open to anyone.
- Open point: The allow-list admin_allow_from is empty: open to anyone.
- Open point: No backup is set up.
- Open point: No monitoring is set up: nobody receives alerts.
- Open point: Password files of removed apps remain (nats); they are kept in the credentials file, group "07 Old (removed apps)".

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
| □ | <https://traefik.demo.example.net/dashboard/> opens | Open it in a browser | | | |
| □ | Each login works | Log in with each web entry of Annex 2 | | | |
| □ | Credentials file opens, SHA-256 matches | Compare with Annex 3, then open it with the passphrase | | | |
| □ | Laptop access | Web pages, SSH and the tunnel from the Client's laptop | | | |
| □ | The Client's SSH key is on every server | `ssh demo-ltd-<server>` works for each server | | | |
| □ | The Client's addresses are allowed | The lists are empty (open to anyone): the Client confirms this | | | |
| □ | Restore test | Not done | | | |
| □ | System test (check.py) | `.venv/bin/python tests/check.py` |  | | |

```{=typst}
#pagebreak()
```

## Annex 2. Accounts {#certificate-annex-accounts}

The names of the accounts in the credentials file **demo-ltd-credentials.kdbx**. No password is written here. The address is in each entry.

| App            | User          | Entry in the credentials file                   | Used for                      | How to change it                      |
|:---------------|:--------------|:------------------------------------------------|:------------------------------|:--------------------------------------|
| postgres | postgres | 02 Databases and cache/PostgreSQL | People log in with it | In the app and the file together (not tested) |
| registry | ansibro | 04 Infrastructure/Image registry | Recovery (keep it safe) | In the app and the file together |
| traefik | admin | 01 Web logins/Traefik | People log in with it | Edit the file, run the installer |
| ansibro | — | 06 Internal (re-run ansibro)/ansibro installer files | To run the installer again (attachment) | Goes out of date after password changes |

The group "06 Internal (re-run ansibro)" also holds 2 internal entries that no person types, and "07 Old (removed apps)" holds 1 from removed apps. The technical documentation, chapter 6, explains each change.

```{=typst}
#pagebreak()
```

## Annex 3. Delivered files {#certificate-annex-files}

Each file with its size and SHA-256 code (a fingerprint of its content: the smallest change gives another code). The code of this certificate itself is in the file SHA256SUMS.

| File                                         | Size (bytes)   | SHA-256                                  |
|:---------------------------------------------|:---------------|:-----------------------------------------|
| `demo-ltd-credentials.kdbx` | <size> | `<sha<size>>` `<sha<size>>` |
| `demo-ltd-laptop-guide-linux.pdf` | <size> | `<sha<size>>` `<sha<size>>` |
| `demo-ltd-laptop-guide-macos.pdf` | <size> | `<sha<size>>` `<sha<size>>` |
| `demo-ltd-laptop-guide-windows.pdf` | <size> | `<sha<size>>` `<sha<size>>` |
| `demo-ltd-technical-documentation.pdf` | <size> | `<sha<size>>` `<sha<size>>` |
| `ssh_config.txt` | 732 | `<sha256>` `<sha256>` |

To check a file: `Get-FileHash <file> -Algorithm SHA256` (Windows), `shasum -a 256 <file>` (macOS), `sha256sum <file>` (Linux).
