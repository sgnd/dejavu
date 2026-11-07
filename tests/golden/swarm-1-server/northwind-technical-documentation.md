---
title: "Technical Handover Documentation"
subtitle: "Production · northwind.example.com"
short-title: "Technical Documentation · Northwind"
lang: en
docnumber: "DOC-2026-001"
version: "1.0"
date: "Wednesday, 4 November 2026"
classification: "CONFIDENTIAL"
numbered: true
labels: {page: "Page", of: "of", toc: "Contents"}
cover:
  kicker: "HANDOVER DOCUMENTATION"
  rows:
    - {label: "For", value: "Northwind Logistics Ltd"}
    - {label: "By", value: "Bluewave Systems Ltd"}
    - {label: "System", value: "Production, northwind.example.com"}
    - {label: "Document number", value: "DOC-2026-001"}
    - {label: "Version", value: "1.0"}
    - {label: "Date", value: "Wednesday, 4 November 2026"}
    - {label: "Classification", value: "CONFIDENTIAL"}
    - {label: "Distribution", value: "Northwind Logistics Ltd and Bluewave Systems Ltd only"}
  footer: "Made with dejavu 1.1.0 from ansibro 1.2.0. This document holds no password. It describes how the system is reached, so keep it confidential."
---

# Document control {#control .unnumbered}

| Role | Name |
|:---------------|:--------------------------------------------------------|
| Prepared by | Emma Clarke |
| Reviewed by | Daniel Reed |
| Approved by | Laura Bennett |

| Version | Date | By | Change |
|:--------|:-----------|:----------------|:-----------------------------------------|
| 1.0 | 2026-11-04 | Emma Clarke | First issue |

This document was made with dejavu 1.1.0 from ansibro 1.2.0, configuration `config`, last install Tuesday, 3 November 2026.
It contains no password. Every password is in the credentials file `northwind-credentials.kdbx`.
Where an answer was not given, the text says *Not provided*.

## How to read this document {#how-to-read .unnumbered}

- **Everyone** (people who only use the web pages): read [chapter 1](#summary), [chapter 5](#access), [chapter 6](#credentials) and [chapter 11](#support).
- **Operators** (people who look after the servers): read everything.
- Technical words are explained the first time they appear, and again in the [glossary](#appendix-glossary) (Appendix H).
- A red box marks something you must act on.

# Summary {#summary}

## What was built {#summary-built}

Bluewave Systems Ltd built a system of 1 server for Northwind Logistics Ltd.
The system answers on the web address `northwind.example.com` and the pages below it, such as `traefik.northwind.example.com`.
It was set up with ansibro, an installer that puts the same programs on every server in the same way.
It runs these programs:

- **Portainer**: A web page to see and manage the containers and stacks of the cluster.
- **PostgreSQL**: An SQL database for your apps (and for Kong, Keycloak and Authelia).
- **Redis**: An in-memory key-value store, for cache and login sessions.
- **RustFS**: S3-compatible file storage for your apps.
- **Traefik**: The front door for every web page. It receives HTTPS for the domain and sends each subdomain to its app, with certificates.
- **Victoria monitoring**: Full monitoring. Metrics, logs, alert rules, Grafana, and alerts to Telegram, email or a webhook.

## Six things to know first {#summary-six}

1. **Where the passwords are.** Every password is in one locked file, `northwind-credentials.kdbx`. Open it with KeePassXC (see [chapter 5](#access)). The words that open it were given separately by phone call to Sarah Miller.
2. **Change the passwords within 7 days.** The vendor knows them today. [Chapter 6](#credentials) says how, and [Appendix E](#appendix-passwords) is the checklist.
3. **How to open the admin pages.** Use a web browser and go to the addresses in [chapter 4](#apps), for example <https://portainer.northwind.example.com/>. They open only from the internet addresses on the allow-list.
4. **Backup is on.** Every night at 02:00 (Europe/London) each server copies its data to `s3.example.com`.
5. **Alerts are on.** Problems are reported to telegram. See [chapter 8](#monitoring).
6. **Who to call.** Emma Clarke (Project Manager), \+44 20 7946 0111, emma\@bluewave.example, Mon-Fri 09:00-17:00 UK time. See [chapter 11](#support).

## Scope {#summary-scope}

**Part of this work:**

- 1 server set up with ansibro, and the 6 programs listed above.
- This document, the laptop guides, the handover certificate and the credentials file.

**Not part of this work:**

- The client's business applications

# Architecture {#architecture}

![The servers and the apps on them](architecture.svg)

## Cluster and high availability {#architecture-ha}

The server runs as a *cluster* of one. A cluster is a group of servers that work as one; more servers can be added later.
The cluster is run by *Docker Swarm*, which starts each app in a *container* (an app packed with everything it needs) and restarts it when it stops.
*Managers* are the servers that steer the cluster. The cluster keeps working while more than half of its managers are up.

*High availability* (HA) means that a part keeps working when one server stops. This is the HA level of each part:

| Part | How it is set up | If one server stops |
|:----------------|:--------------------------------------|:--------------------------------------|
| Cluster managers | 1 manager: server1 | The cluster cannot be steered until the manager is back |
| Web entry (Traefik) | On server1 | No web page opens until that server is back |
| Database (PostgreSQL) | One server: server1 | The database stops until the server is back |
| Cache (Redis) | One server: server1 | The cache stops until the server is back |
| Storage (RustFS) | One server: server1 | Storage stops until the server is back |

## How a visitor reaches an app {#architecture-traffic}

1. *DNS* (the internet's address book) turns `anything.northwind.example.com` into the public address of server1.
2. The browser connects to *Traefik*, the front door, on port 443 (HTTPS). Port 80 only redirects to 443.
3. Traefik checks who may pass. Each page has one *guard*:
   - **admin**: the visitor's address must be on the admin allow-list, then the admin login asks for a password;
   - **admin-ip**: the address must be on the admin allow-list; the app then shows its own login;
   - **public**: anyone may open it; the app has its own login, or none.
4. Traefik sends the visitor to the app, wherever it runs in the cluster.

The admin allow-list (`admin_allow_from`) is 198.51.100.0/24.

## The first manager {#architecture-first}

`server1` is the *first manager*. It has jobs the other servers do not have:

- ansibro and its acceptance test run their checks from it.
- Portainer keeps its data on it.
- Its nightly backup also holds the Swarm state, a copy of `config.yml` and a copy of every password file.
- It holds the certificate authority of the private image registry.
- **It must never be removed from the cluster.**

## Components {#architecture-components}

ansibro also installs these parts. They are not apps you chose, but they belong to the system.

| Component | Where | Port | Version | License | What it does |
|:-----------|:------------|:-----|:-------------|:----------|:------------------------------------|
| registry | managers | 5000 | 3.1.2 | Apache-2.0 | A private image registry on every manager. All servers pull images from it. |
| monitoring-agents | every server | 9100 | v1.12.1 | Apache-2.0 | node-exporter, cAdvisor, Vector and the database exporters on every server, plus the ansibro-metrics timer. |
| backup | every server |  |  | BSD-2-Clause | The ansibro-backup timer with restic, every night on every server. |

# Servers and network {#servers}

## Servers {#servers-list}

The *cluster IP* is the address the servers use among themselves. The *SSH address* is where people and the installer log in.

| Server | Role | Tier | Cluster IP | SSH address | Public IP |
|:-----------|:-----------|:---------|:-------------|:--------------|:--------------|
| server1 (first manager) | manager | data | 10.10.0.10 | 203.0.113.10 | same as SSH address |

| Server | Provider | Region | Size | Operating system |
|:-----------|:---------------|:-------------|:---------------------------|:------------------|
| server1 | DigitalOcean | *Not provided* | *Not checked* | *Not checked* |

| Server | Host-key fingerprint (ED25519) |
|:-----------|:--------------------------------------------------------------|
| server1 | *Not checked* |

The *host-key fingerprint* lets you check, on your first SSH login, that you reach the real server. [Chapter 5](#access) shows how to read it.

Apps that run on a fixed server (all other apps run in the cluster):

| Server | Apps |
|:-------------|:----------------------------------------------------------|
| server1 | PostgreSQL, Redis, RustFS, Victoria monitoring |

## DNS {#servers-dns}

| Setting | Value |
|:--------------------|:---------------------------------------------------|
| Mode | public DNS |
| Record | `*.northwind.example.com` (type A) |
| Points to | 203.0.113.10 (server1) |
| DNS provider | Cloudflare |
| Domain owner | Northwind Logistics Ltd |
| CDN in front | no |

With Let's Encrypt, Traefik runs on server1 only, because Let's Encrypt must reach the server that asked for the certificate.

## Certificates (TLS) {#servers-tls}

A *certificate* proves to the browser that the page is really `northwind.example.com`, and encrypts the connection (*TLS*, the "s" in https).

| Setting | Value |
|:--------------------|:---------------------------------------------------|
| Mode | Let's Encrypt (free public certificates, made automatically) |
| Issuer | Let's Encrypt |
| Contact email | it@northwind.example.com |
| Expiry | Each certificate lasts a few months; Traefik renews it before it ends |
| Renewal | Automatic. DNS must point at server1 and port 80 must stay open |

## Firewall {#servers-firewall}

A *firewall* decides which connections may reach a server. Each server runs the firewall *ufw*.

- ansibro owns the firewall. It rewrites the rules when they change, and **rules added by hand are removed**. Change the lists below in `config.yml`, then run `./install.sh`.
- Ports published by Docker containers go past ufw.
- An *allow-list* is a list of internet addresses that may connect. An empty list means anyone may connect.

| List | What it guards | Addresses | Whose |
|:----------------|:-------------------|:----------------------|:----------------------|
| `ssh.allow_from` | SSH to every server | 198.51.100.0/24 | Sarah Miller |
| `admin_allow_from` | the admin web pages | 198.51.100.0/24 | Sarah Miller |

## Ports {#servers-ports}

A *port* is a numbered door on a server for one kind of connection.

| Port | What | On which servers | Open to |
|:---------|:-------------------|:-------------------------|:-------------------------|
| 22/tcp | SSH | all | 198.51.100.0/24 |
| 80, 443/tcp | Web pages (Traefik) | server1 | anyone; admin pages also check `admin_allow_from` |
| 5432/tcp | PostgreSQL | server1 | the other cluster servers only |
| 6379/tcp | Redis | server1 | the other cluster servers only |
| 9000/tcp | RustFS S3 | server1 | the other cluster servers only |
| 5000/tcp | registry | server1 | the other cluster servers only |
| 9100/tcp | monitoring-agents | all | the other cluster servers only |

The databases, cache, storage and queues are reached from a laptop through an SSH tunnel (see [chapter 5](#access)).

## Network between the servers {#servers-wireguard}

WireGuard is off. The servers talk to each other on their cluster IPs, and ansibro does not encrypt that traffic. This is fine on a private network of the provider.

## Time and internet {#servers-time}

- Time zone: **Europe/London**. Backup times and logs use it.
- The servers use the internet to get programs and the correct time.

# Applications {#apps}

## Overview {#apps-overview}

| App | What it is for | Runs on | Version | License |
|:-----------|:-------------------------------|:-------------------|:-----------|:-----------|
| Portainer | cluster management page | server1 | 2.45.3 | zlib |
| PostgreSQL | database | server1 | 18.6 | PostgreSQL |
| Redis | cache | server1 | 8.10.3 | AGPL-3.0 |
| RustFS | file storage (S3) | server1 | 1.0.4 | Apache-2.0 |
| Traefik | web front door | server1 | v3.7.17 | MIT |
| Victoria monitoring | monitoring | server1 | victoria-metrics v1.155.0 | Apache-2.0 |

## Web pages {#apps-web}

| Address | App | Who can open it | Login |
|:------------------------------------|:-----------|:--------------------|:--------------------|
| <https://portainer.northwind.example.com/> | Portainer | admin allow-list | the app's own login |
| <https://rustfs.northwind.example.com/rustfs/console/> | RustFS | admin allow-list | the app's own login |
| <https://traefik.northwind.example.com/dashboard/> | Traefik | admin allow-list | Traefik login (user admin) |
| <https://grafana.northwind.example.com/> | Victoria monitoring | admin allow-list | the app's own login |
| <https://alertmanager.northwind.example.com/> | Victoria monitoring | admin allow-list | Traefik login (user admin) |
| <https://metrics.northwind.example.com/vmui> | Victoria monitoring | admin allow-list | Traefik login (user admin) |
| <https://logs.northwind.example.com/select/vmui> | Victoria monitoring | admin allow-list | Traefik login (user admin) |

## Portainer {#app-portainer}

A web page to see and manage the containers and stacks of the cluster.

| Item | Detail |
|:----------------|:-------------------------------------------------------|
| Runs on | server1 |
| Web page | <https://portainer.northwind.example.com/> (its own login) |
| From a laptop | a web browser |
| Credentials | `01 Web logins/Portainer` |
| Data | `/opt/ansibro/portainer` |
| Backup | Copied while paused |
| Health check | `POST /api/auth` |

- The password file is read only at Portainer's first start. After that, change the password in Portainer itself.

## PostgreSQL {#app-postgres}

An SQL database for your apps (and for Kong, Keycloak and Authelia).

| Item | Detail |
|:----------------|:-------------------------------------------------------|
| Runs on | server1 |
| PostgreSQL | `10.10.0.10:5432` |
| From a laptop | an SSH tunnel ([chapter 5](#access)) |
| Credentials | `02 Databases and cache/PostgreSQL` |
| Data | `/opt/ansibro/postgres` on server1 |
| Backup | Database dump |
| Health check | `pg_isready` |

- On 2 or more servers PostgreSQL runs with Patroni. The primary can move; apps in the cluster use the database-proxy.
- A major version upgrade (for example 18 to 19) needs a manual dump and restore.

## Redis {#app-redis}

An in-memory key-value store, for cache and login sessions.

| Item | Detail |
|:----------------|:-------------------------------------------------------|
| Runs on | server1 |
| Redis | `10.10.0.10:6379` |
| From a laptop | an SSH tunnel ([chapter 5](#access)) |
| Credentials | `02 Databases and cache/Redis` |
| Data | `/opt/ansibro/redis` on server1 |
| Backup | Copied while paused |
| Health check | `redis-cli ping` |

- On 3 servers there is one primary and two copies, watched by Sentinel (port 26379, master name "ansibro").

## RustFS {#app-rustfs}

S3-compatible file storage for your apps.

| Item | Detail |
|:----------------|:-------------------------------------------------------|
| Runs on | server1 |
| Web page | <https://rustfs.northwind.example.com/rustfs/console/> (its own login) |
| S3 | `10.10.0.10:9000` |
| From a laptop | an SSH tunnel ([chapter 5](#access)) |
| Credentials | `03 S3 storage/RustFS S3` |
| Data | `/opt/ansibro/rustfs` on server1 |
| Backup | Copied while running |
| Health check | `TCP 9000` |

- The S3 region is us-east-1.

## Traefik {#app-traefik}

The front door for every web page. It receives HTTPS for the domain and sends each subdomain to its app, with certificates.

| Item | Detail |
|:----------------|:-------------------------------------------------------|
| Runs on | server1 |
| Web page | <https://traefik.northwind.example.com/dashboard/> (Traefik login (user admin)) |
| From a laptop | a web browser |
| Credentials | `01 Web logins/Traefik` |
| Data | `/opt/ansibro/traefik` |
| Backup | Copied while paused |
| Health check | `traefik healthcheck --ping` |

## Victoria monitoring {#app-victoria}

Full monitoring. Metrics, logs, alert rules, Grafana, and alerts to Telegram, email or a webhook.

| Item | Detail |
|:----------------|:-------------------------------------------------------|
| Runs on | server1 |
| Web page | <https://grafana.northwind.example.com/> (its own login) |
|  | <https://alertmanager.northwind.example.com/> (Traefik login (user admin)) |
|  | <https://metrics.northwind.example.com/vmui> (Traefik login (user admin)) |
|  | <https://logs.northwind.example.com/select/vmui> (Traefik login (user admin)) |
| From a laptop | a web browser |
| Credentials | `01 Web logins/Grafana` |
| Data | `/opt/ansibro/victoria`, `/opt/ansibro/monitoring-agent` on server1 |
| Backup | Partly saved |
| Health check | `Watchdog alert` |

- The metrics and logs history is not backed up; the settings, Grafana and Alertmanager are.

# Access from your laptop {#access}

This chapter shows, step by step, how to reach the system from a Windows, macOS or Linux laptop.

## Who needs what {#access-who}

This part explains how to reach the system from your own computer, step by step. It is written for Windows, macOS. On Windows you type the commands in **PowerShell** (Start menu, type "PowerShell"). On macOS you type the commands in the **Terminal** app. Each step says what you want to do, what to type, what you should see, and what to do if it fails.

Commands marked *(not tested)* have not been tried on a real laptop yet. If one of them fails, tell the vendor.

Not everyone needs every part. Find your role in this table:

|                          | Viewer (web pages only)       | Operator (also servers)         | Successor (runs the installer)   |
|:-------------------------|:------------------------------|:--------------------------------|:---------------------------------|
| Tools                    | A browser, KeePassXC | The same, plus the SSH program; optional database tools | The same, plus git, Python 3.12 or newer, age; macOS or Linux only |
| Web pages                | Yes                           | Yes                             | Yes                              |
| SSH and tunnels          | No                            | Yes                             | Yes                              |
| Runs the installer       | No                            | No                              | Yes                              |

The people named for this handover:

| Name                      | Role          | Laptop       | Internet address                  |
|:--------------------------|:--------------|:-------------|:----------------------------------|
| Tom Hughes | Operator | Windows | 198.51.100.7 |
| Sarah Miller | Viewer | macOS | 198.51.100.0/24 |

Before your first visit, the vendor does two things for you:

1. Adds your internet address to the allow-lists, if the lists are in use (see [Your internet address](#access-ip)).
2. Adds your SSH key to every server, if you are an operator (see [SSH](#access-ssh)).

## Open the credentials file {#access-kdbx}

All passwords are in one encrypted file, **northwind-credentials.kdbx**. It opens with KeePassXC, a free password manager. The passphrase that opens it (7 words) is given to you separately, by phone call, to Sarah Miller. It is never in the same message or on the same USB stick as the file.

### Install KeePassXC {#access-kdbx-install}

Goal: have KeePassXC on your computer.

Windows (PowerShell):

```powershell
winget install KeePassXCTeam.KeePassXC
```

macOS (Terminal):

```sh
brew install --cask keepassxc
```

On Windows you can also download the installer (MSI) from <https://keepassxc.org/download>. The winget package name is *(not tested)*.
On macOS you can also download the DMG from <https://keepassxc.org/download>. On the first start, if macOS refuses to open it, right-click the app and choose Open.

On a phone, KeePassDX (Android), KeePassium or Strongbox (iPhone) can open the file to look things up.

**What you should see:** KeePassXC in your list of apps.

**If it fails:** on a company laptop you may not be allowed to install apps. Ask your IT team, or ask the vendor to install it during the handover session.

### Check the file {#access-kdbx-hash}

Goal: make sure the file you received is exactly the one listed in the Handover Certificate. Open PowerShell or Terminal in the folder that holds the file, then type:

Windows (PowerShell):

```powershell
Get-FileHash .\northwind-credentials.kdbx -Algorithm SHA<size>
```

macOS (Terminal):

```sh
shasum -a <size> northwind-credentials.kdbx
```

**What you should see:** a long code of 64 letters and digits. It must be the same as the SHA-<size> of northwind-credentials.kdbx in Annex 3 of the Handover Certificate.

**If it fails:** if the code is different, do not use the file. Ask the vendor for a new copy.

### Open it and copy a password {#access-kdbx-open}

Goal: read a password without typing it by hand.

1. Open KeePassXC, choose Open Database, and pick northwind-credentials.kdbx.
2. Type the 7 words of the passphrase, with a space between the words.
3. Pick a group on the left (for example "01 Web logins"), then click an entry.
4. Copy the password with Ctrl+C (Cmd+C on a Mac) and paste it into the login page. KeePassXC clears the clipboard after a few seconds.
5. Files inside an entry (attachments) are under the entry's Attachments: right-click one to save it.

Keep a backup copy of the file on a USB stick in a safe place. After the handover, change the passphrase (Database, then Database Security) and change the passwords within 7 days, as this document explains.

**What you should see:** the groups and entries of the file.

**If it fails:** "Invalid credentials" means a word is wrong. Check the spelling and the spaces, and try again.

## Your internet address {#access-ip}

Goal: know the internet address (IP address) of your connection, because some pages and the servers only accept known addresses.

macOS (Terminal):

```sh
curl -4 https://ifconfig.me
```

Windows (PowerShell):

```powershell
curl.exe -4 https://ifconfig.me
```

You can also open <https://ifconfig.me> in a browser. It is a service run by a third party.

**What you should see:** four numbers with dots, for example 198.51.100.7.

The system has two lists of allowed addresses (allow-lists):

| List                 | What it protects                       | Addresses allowed now                         |
|:---------------------|:---------------------------------------|:----------------------------------------------|
| `ssh.allow_from`     | SSH, the login to the servers (port 22) | 198.51.100.0/24 |
| `admin_allow_from`   | The admin web pages                    | 198.51.100.0/24 |

When a list is set, an address that is not on it gets "403 Forbidden" on the admin pages, or no answer (a timeout) on SSH. This also happens when your home address changes, behind a company proxy, or on a connection with only an IPv6 address.

**If it fails:** only the operator can add an address: they add it to the list in the installer's settings (config.yml) and run the installer again. Send your address to the vendor or your operator.

## Web pages {#access-web}

### Check the name {#access-web-dns}

Goal: make sure your computer finds the system's web pages under northwind.example.com.

macOS (Terminal):

```sh
ping -c 1 portainer.northwind.example.com
```

Windows (PowerShell):

```powershell
ping -n 1 portainer.northwind.example.com
```

**What you should see:** the address 203.0.113.10. That is the server that answers the web pages. A reply is not needed: some networks block ping, but the address must be right.

The names come from the public DNS (the internet's phone book), with one record for every name under northwind.example.com.

**If it fails:** "could not find host" means the name is not known. Ask the vendor to check the DNS record.

### Certificates {#access-web-tls}

The certificates come from Let's Encrypt, a public authority. Your browser trusts them already: there is nothing to do.

### The pages {#access-web-pages}

Goal: know which pages exist, who can open them, and which entry of the credentials file holds the login.

| Address                                  | App              | Who can open it           | Login                       | Entry in the credentials file        |
|:-----------------------------------------|:-----------------|:--------------------------|:----------------------------|:-------------------------------------|
| <https://portainer.northwind.example.com/> | portainer | Allowed addresses only | The app's own login | 01 Web logins/Portainer |
| <https://rustfs.northwind.example.com/rustfs/console/> | rustfs | Allowed addresses only | The app's own login | None |
| <https://traefik.northwind.example.com/dashboard/> | traefik | Allowed addresses only | Admin login (Traefik) | 01 Web logins/Traefik |
| <https://grafana.northwind.example.com/> | victoria | Allowed addresses only | The app's own login | 01 Web logins/Grafana |
| <https://alertmanager.northwind.example.com/> | victoria | Allowed addresses only | Admin login (Traefik) | 01 Web logins/Traefik |
| <https://metrics.northwind.example.com/vmui> | victoria | Allowed addresses only | Admin login (Traefik) | 01 Web logins/Traefik |
| <https://logs.northwind.example.com/select/vmui> | victoria | Allowed addresses only | Admin login (Traefik) | 01 Web logins/Traefik |

**What you should see:** the login page of the app, or the admin login first (Traefik).

**If it fails:** "403 Forbidden" means your internet address is not on the admin allow-list (see [Your internet address](#access-ip)). A page that never loads usually means a name problem (see [Check the name](#access-web-dns)).

## SSH: the login to the servers {#access-ssh}

This part is for operators. SSH (Secure Shell) is the safe way to type commands on a server. You log in with a key: a pair of files, one private (it stays on your laptop) and one public (it goes to the servers). The vendor's own key is never handed over.

### Check the SSH program {#access-ssh-client}

Goal: make sure your computer has the OpenSSH program.

Windows (PowerShell):

```powershell
ssh -V
```

macOS (Terminal):

```sh
ssh -V
```

**What you should see:** a version, for example "OpenSSH_9.6".

**If it fails:** on Windows, install it from PowerShell opened as administrator: `Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0`. macOS always has it. Use OpenSSH, not PuTTY: PuTTY needs its own key format.

### Make your own key {#access-ssh-key}

Goal: make your key pair, then send only the public part (the file ending in .pub) to the vendor.

macOS (Terminal):

```sh
mkdir -p ~/.ssh
ssh-keygen -t ed25519 -f ~/.ssh/northwind_ed25519 -C "your name"
```

Windows (PowerShell):

```powershell
New-Item -ItemType Directory -Force "$env:USERPROFILE\.ssh"
ssh-keygen -t ed25519 -f $env:USERPROFILE\.ssh\northwind_ed25519 -C "your name"
```

Choose a passphrase for the key when asked; it protects the key if your laptop is lost.

**What you should see:** two new files: northwind_ed25519 (private: never send it) and northwind_ed25519.pub (public: send this one to the vendor).

**If it fails:** "No such file or directory" means the .ssh folder is missing: run the first line again.

### The vendor adds your key {#access-ssh-add}

Goal: the vendor puts your public key on every server. ansibro does not do this, so the operator does it by hand, once per server, with their own access:

```sh
cat northwind_ed25519.pub | ssh -p 22 ubuntu@<server> \
  "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys \
  && chmod 600 ~/.ssh/authorized_keys"
```

`<server>` is each address in the next table. This is a row of the acceptance checklist (Annex 1 of the Handover Certificate).

### Add the SSH settings {#access-ssh-config}

Goal: give each server a short name, so `ssh northwind-server1` is all you type. The file **ssh_config.txt** from the handover pack has the settings; add it to the end of your SSH settings file:

macOS (Terminal):

```sh
cat ssh_config.txt >> ~/.ssh/config
```

Windows (PowerShell):

```powershell
Get-Content .\ssh_config.txt |
  Add-Content -Encoding ascii "$env:USERPROFILE\.ssh\config"
```

It gives these names:

| Name                        | Server          | Address           | Goes through                  |
|:----------------------------|:----------------|:------------------|:------------------------------|
| `northwind-server1` | server1 | 203.0.113.10 | Direct |

Every name logs in as ubuntu on port 22, with the key ~/.ssh/northwind_ed25519.
On macOS you can add two lines under each `Host` line so the key passphrase is kept in the Keychain: `UseKeychain yes` and `AddKeysToAgent yes`.

**What you should see:** the `Host` lines at the end of the file.

**If it fails:** if you already had a `Host` with the same name, remove the old one.

### First connection {#access-ssh-first}

Goal: log in to the first server once and check that it is the real one.

macOS (Terminal):

```sh
ssh northwind-server1
```

Windows (PowerShell):

```powershell
ssh northwind-server1
```

The first time, SSH shows the server's fingerprint (a code starting with SHA256:) and asks to continue. Compare it with this table, then type `yes`. If they differ, type `no` and call the vendor.

| Server          | Host-key fingerprint                                                          |
|:----------------|:------------------------------------------------------------------------------|
| server1 | Not checked |

The fingerprints were not checked by the acceptance test. Ask the vendor to read them out from each server with `ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub`.

**What you should see:** a prompt like `ubuntu@server1:~$`. Type `exit` to leave. Commands for the system need `sudo` in front, because its files under /opt/ansibro belong to the administrator (root).

**If it fails:**

- "Permission denied (publickey)": your key is not on that server yet, or the key file name is wrong.
- "Connection timed out": your address is not in ssh.allow_from, or the provider's firewall blocks port 22.
- "UNPROTECTED PRIVATE KEY FILE": the key file is readable by others. Fix it:

macOS (Terminal):

```sh
chmod 600 ~/.ssh/northwind_ed25519
```

Windows (PowerShell):

```powershell
icacls $env:USERPROFILE\.ssh\northwind_ed25519 /inheritance:r `
  /grant:r "$($env:USERNAME):(R)"
```

### Remember the key passphrase {#access-ssh-agent}

Goal: type the key's passphrase once per session instead of at every login.

Windows (PowerShell):

```powershell
Get-Service ssh-agent | Set-Service -StartupType Automatic
Start-Service ssh-agent
ssh-add $env:USERPROFILE\.ssh\northwind_ed25519
```

macOS (Terminal):

```sh
ssh-add --apple-use-keychain ~/.ssh/northwind_ed25519
```

On Windows, the first two lines need PowerShell opened as administrator.

**What you should see:** "Identity added".

**If it fails:** "Could not open a connection to your authentication agent" means the agent is not running: run the Windows lines as administrator.

## Databases and other services: an SSH tunnel {#access-tunnel}

The databases and similar services listen only inside the cluster, and their traffic is not encrypted. To reach them, you open an SSH tunnel: a private pipe through SSH from your laptop to the server. The tunnel also encrypts the traffic.

### Start the tunnel {#access-tunnel-start}

Goal: open all the pipes at once with the name `northwind-tunnel` from ssh_config.txt.

macOS (Terminal):

```sh
ssh -N northwind-tunnel
```

Windows (PowerShell):

```powershell
ssh -N northwind-tunnel
```

Keep this window open while you work; close it (Ctrl+C) when you are done. Then connect your tools to 127.0.0.1 (your own laptop) and the port in this table:

| Service              | Server        | On the server            | On your laptop          |
|:---------------------|:--------------|:-------------------------|:------------------------|
| PostgreSQL | server1 | 10.10.0.10:5432 | 127.0.0.1:15432 |
| Redis | server1 | 10.10.0.10:6379 | 127.0.0.1:16379 |
| S3 | server1 | 10.10.0.10:9000 | 127.0.0.1:19000 |

**What you should see:** nothing: no prompt, and the window stays open. That means the tunnel works.

**If it fails:** "Address already in use" or "port forwarding failed" means another program on your laptop uses that port. Close it, or change the first number of that `LocalForward` line in your SSH settings.

### Connect your tools {#access-tunnel-tools}

Goal: use the database or service through the tunnel. The passwords are in the group "02 Databases and cache" and "03 S3 storage" of the credentials file.

PostgreSQL:

macOS (Terminal):

```sh
psql "host=127.0.0.1 port=15432 user=postgres"
```

Windows (PowerShell):

```powershell
psql "host=127.0.0.1 port=15432 user=postgres"
```

Redis *(not tested)*:

macOS (Terminal):

```sh
redis-cli -h 127.0.0.1 -p 16379 --askpass
```

Windows (PowerShell):

```powershell
redis-cli -h 127.0.0.1 -p 16379 --askpass
```

RustFS (S3 file storage): the easy way is its web console at <https://rustfs.northwind.example.com/rustfs/console/>. From the command line *(not tested)*:

macOS (Terminal):

```sh
aws --endpoint-url http://127.0.0.1:19000 s3 ls
```

Windows (PowerShell):

```powershell
aws --endpoint-url http://127.0.0.1:19000 s3 ls
```

Programs with a window (DBeaver, TablePlus, RedisInsight, WinSCP, Cyberduck) work the same way: start the tunnel, then connect to host 127.0.0.1 and the laptop port. They can also make the tunnel themselves: in their SSH settings, use host 203.0.113.10, port 22, user ubuntu and your key file; then connect to the address "on the server" from the table.

**What you should see:** the tool connects and asks for the password, or shows the data.

**If it fails:** "connection refused" means the tunnel is not running. Start it again in its own window.

## Managing the cluster {#access-cluster}

### Docker Swarm {#access-cluster-swarm}

Goal: see and manage the running apps (services).

The easy way is the browser: Portainer at <https://portainer.northwind.example.com/>.

From the command line, on the first server:

macOS (Terminal):

```sh
ssh -t northwind-server1 sudo docker service ls
```

Windows (PowerShell):

```powershell
ssh -t northwind-server1 sudo docker service ls
```

**What you should see:** a list of services, each with "REPLICAS" like 1/1.

**If it fails:** see [SSH](#access-ssh). A remote Docker connection (`docker context create northwind --docker host=ssh://northwind-server1`) only works if the SSH user may use Docker without sudo. ansibro does not set this up, and it gives full control of the server, so the vendor decides.

### Your own images {#access-cluster-images}

Goal: run your own app images. The image registry (registry.ansibro:5000) is reachable only from the servers, so you send the image over SSH and push it on the first server:

macOS (Terminal):

```sh
docker save app:1 | ssh northwind-server1 "sudo docker load"
ssh northwind-server1 "sudo docker tag app:1 registry.ansibro:5000/app:1 && \
  sudo docker push registry.ansibro:5000/app:1"
```

Windows (PowerShell):

```powershell
docker save app:1 | ssh northwind-server1 "sudo docker load"
ssh northwind-server1 ("sudo docker tag app:1 registry.ansibro:5000/app:1 && " +
  "sudo docker push registry.ansibro:5000/app:1")
```

`app:1` is your image name and version. On a Mac with Apple Silicon, build the image with `--platform linux/amd64`: the servers use Intel or AMD processors. The registry is not in the backup: after a restore, push your images again.

## Troubleshooting {#access-trouble}

| Problem                                 | What to do                                                            |
|:----------------------------------------|:----------------------------------------------------------------------|
| "403 Forbidden" on a web page           | Your address is not on the admin allow-list. See [Your internet address](#access-ip). |
| A certificate warning                   | See [Certificates](#access-web-tls). |
| SSH: "Connection timed out"             | Your address is not in ssh.allow_from, or the provider's firewall blocks the port. |
| SSH: "Permission denied (publickey)"    | Your key is not on that server, or the key file name in the settings is wrong. |
| Tunnel: "Address already in use"        | Another program uses that laptop port. Close it, or change the port. |
| Nobody can log in to a server any more  | The operator opens the provider's web console, runs `sudo ufw disable`, fixes the list and runs the installer again. |

When you are stuck, call the vendor (Mon-Fri 09:00-17:00 UK time). Never send a password by email or chat.

| Name                     | Role                  | Phone                  | Email                          |
|:-------------------------|:----------------------|:-----------------------|:-------------------------------|
| Emma Clarke | Project Manager | \+44 20 7946 0111 | emma\@bluewave.example |

# Credentials and password changes {#credentials}

## The credentials file {#credentials-file}

Every password is in one locked file, `northwind-credentials.kdbx`. It is a KeePass file. Open it with KeePassXC ([chapter 5](#access)).
The words that open it (the *passphrase*) travelled separately, by phone call, to Sarah Miller. Neither this document nor the handover certificate holds a password.

The file has these groups:

| Group | What it holds | Who needs it |
|:-------------------------------|:------------------------------------------|:-------------------|
| 01 Web logins | Grafana, Portainer, Traefik | everyone who manages the web pages |
| 02 Databases and cache | PostgreSQL, Redis | operators |
| 03 S3 storage | RustFS S3 | operators |
| 04 Infrastructure | Image registry | operators |
| 05 Recovery (break-glass) | Backup (restic), config.yml backup.s3_access_key, config.yml backup.s3_secret_key, config.yml monitoring.telegram.bot_token | keep safe; only to restore |
| 06 Internal (re-run ansibro) | 4 technical passwords, plus the file "ansibro installer files" (to run ansibro again) | only to run ansibro again |

## Accounts {#credentials-accounts}

These are the accounts people use. The class says how to change the password (see the next section).

| Account | For | Entry in the credentials file | How to change | Deadline |
|:----------------|:-----------|:------------------------------|:----------------|:-----------|
| Grafana | daily use | `01 Web logins/Grafana` | App and file together (not tested) | within 7 days |
| Portainer | daily use | `01 Web logins/Portainer` | App first | within 7 days |
| PostgreSQL | daily use | `02 Databases and cache/PostgreSQL` | App and file together (not tested) | within 7 days |
| Redis | daily use | `02 Databases and cache/Redis` | File first | within 7 days |
| Image registry | recovery | `04 Infrastructure/Image registry` | App and file together | when the vendor's access ends |
| Backup (restic) | recovery | `05 Recovery (break-glass)/Backup (restic)` | App and file together | when the vendor's access ends |
| RustFS S3 | daily use | `03 S3 storage/RustFS S3` | App and file together (not tested) | within 7 days |
| Traefik | daily use | `01 Web logins/Traefik` | File first | within 7 days |
| Passphrase of the credentials file | everyone | (the file itself) | KeePassXC | within 7 days |

## How to change a password {#credentials-change}

ansibro keeps a copy of every password in a folder called `state/` on the computer that runs the installer. It uses that copy each time it runs. So a password must be changed in the right place, or the next install undoes it or fails.

### File first {#credentials-file-first}

For: Redis, Traefik.
ansibro writes these passwords into the app every time it runs. A change made only in the app is undone at the next install.

1. On the installer computer, put the new password in the file `state/secrets/<name>`.
2. Run `./install.sh`.
3. Update the credentials file, and every app of yours that uses this password.

### App and file together {#credentials-both}

For: PostgreSQL, Image registry, Backup (restic), Grafana, RustFS S3.
ansibro logs in with these passwords, or they are needed to restore. If only one place changes, the next install fails.

1. Change the password in the app.
2. At the same time, put the same password in `state/secrets/<name>` on the installer computer.
3. Run `./install.sh`, then the acceptance test (`tests/check.py`).
4. Update the credentials file.

- **Backup (restic):** run `sudo restic -r <repository> key passwd` on one server, then put the new password in `state/secrets/restic`, then run `./install.sh` (it rewrites `/opt/ansibro/backup/password` on every server). Keep the old password until the new one works: without it, old backups cannot be read.
- Grafana, PostgreSQL, RustFS S3: how the app takes a new password was not tested, so treat them as "app and file together".

### App first {#credentials-app-first}

For: Portainer.
The app reads these passwords only the first time it starts. After that the app owns them.

1. Change the password in the app.
2. Put the same password in `state/secrets/<name>`, so the records and the acceptance test stay right.
3. Update the credentials file.

### Do not change {#credentials-internal}

The passwords in the group "06 Internal (re-run ansibro)" are used only between programs. No person types them. Change them only if they leaked, and let the ansibro operator do it.

> **Important:** ansibro's own summary file says "change them in the app, then update the file too". That is wrong for the classes "file first" and "app and file together". Follow this chapter instead.

## Who keeps state/ {#credentials-state}

**Bluewave Systems Ltd keeps `state/`** (the installer's copy of the passwords).
After you change a password of the class "file first" or "app and file together", send the new value to the vendor **inside a credentials file with its own passphrase**, never in an email or chat. Otherwise the next install by the vendor undoes your change ("file first") or fails ("app and file together").

## Ending the vendor's access {#credentials-revoke}

Planned date: Friday, 4 December 2026. On that date:

1. Remove the vendor's SSH key from `~/.ssh/authorized_keys` of the user `ubuntu` on every server. ansibro does not manage SSH keys.
2. Remove the vendor's addresses from `ssh.allow_from` and `admin_allow_from` in `config.yml`, then run `./install.sh`.
3. Change the passwords as above.
4. Know that old values stay in `/opt/ansibro/backup/installer/state/secrets/` on server1 and in older backups.
5. The vendor deletes its copy of `state/` when you agree it may.

## Changing the passphrase of the credentials file {#credentials-passphrase}

In KeePassXC: menu **Database → Database Security**, then set a new password. (In KeePass 2: **File → Change Master Key**.) Keep a backup copy of the file in a safe place.

## Adding a staff member {#credentials-staff}

- Add their internet address to `admin_allow_from` (web pages) and `ssh.allow_from` (SSH, operators only) in `config.yml`, then run `./install.sh`.
- For operators: add their SSH public key to `~/.ssh/authorized_keys` of `ubuntu` on every server.

# Backup and restore {#backup}

A *backup* is a copy of the data kept somewhere else, so it can be put back (*restored*) after a loss.

## Settings {#backup-settings}

| Setting | Value |
|:--------------------|:---------------------------------------------------|
| Backup | On, with *restic* (a backup program) on every server |
| Where | s3: `https://s3.example.com/northwind-backup` |
| When | Every night at 02:00 (Europe/London). A missed run starts at the next boot |
| Kept | 7 daily, 4 weekly and 6 monthly *snapshots* per server |
| Password | `05 Recovery (break-glass)/Backup (restic)` in the credentials file |

A *snapshot* is one complete backup at one moment.

## What is saved {#backup-what}

| App | How | Meaning |
|:-----------|:---------------------|:------------------------------------------------|
| Portainer | Copied while paused | the app is paused for a moment and its folder copied |
| PostgreSQL | Database dump | a full export of the databases |
| Redis | Copied while paused | the app is paused for a moment and its folder copied |
| RustFS | Copied while running | copied while it runs; not guaranteed to be consistent |
| Traefik | Copied while paused | the app is paused for a moment and its folder copied |
| Victoria monitoring | Partly saved | only some folders are saved (see the app's notes) |
| Image registry | Not saved | images are pulled again |
| server1 | Extra | the Swarm state, `config.yml` and the password files |

Not saved: Docker volumes, and your own apps unless their files are in `/opt/ansibro/<name>/`.

## How to check {#backup-check}

On any server, after SSH:

```sh
sudo ansibro-backup snapshots
systemctl is-active ansibro-backup.timer
journalctl -u ansibro-backup
```

`sudo ansibro-backup` makes a backup now.
The alert **BackupTooOld** fires when a server has had no good backup for 26 hours.

## Restoring everything {#backup-restore}

ansibro restores the whole system at once, onto new servers.

1. Make new, empty servers (Ubuntu 24.04 or 26.04) with **the same names and the same cluster IPs**.
2. Keep the same `backup:` settings in `config.yml`, and the same `state/`.
3. Run:

   ```sh
   ./install.sh -e restore=true
   ```

4. Each server gets its newest snapshot back, then the apps start. Run `tests/check.py` to check.

**If `state/` is lost too,** get it back from the backup of server1 first. You need the restic password and the storage credentials from the credentials file:

```sh
restic -r <repository> restore latest --host server1 \
  --include /opt/ansibro/backup/stage/installer --target .
```

Not supported: restoring one app, one database, or an earlier point in time, and restoring onto a running cluster.

Last restore drill (a test restore): **never**.

> **Important:** a backup that was never restored is not proven. Plan a restore drill on spare servers.

# Monitoring and alerts {#monitoring}

*Monitoring* watches the servers and apps. An *alert* is a message sent when something is wrong.

## The monitoring system {#monitoring-tool}

The Victoria monitoring runs on server1. It keeps metrics and logs for 30 days.

| Page | Address |
|:----------------------|:-------------------------------------------------|
| Grafana (dashboards) | <https://grafana.northwind.example.com/> |
| Alertmanager (alerts, silences) | <https://alertmanager.northwind.example.com/> |
| Metrics | <https://metrics.northwind.example.com/vmui> |
| Logs | <https://logs.northwind.example.com/select/vmui> |

Alerts go to:
**telegram**.
Warnings and critical alerts go to the same place. An alert repeats every 4 hours while it lasts.

**Who watches the monitoring server?**

> **Important:** nothing watches the monitoring server. If it stops, no alert is sent. Add Uptime Kuma on another server, or a heartbeat service.

**Silencing:** to stop an alert for a while (for example during planned work), open Alertmanager and create a *silence*.

## Alert rules {#monitoring-rules}

34 rules apply to this system. *Critical* means act now; *warning* means look soon. The alert texts arrive in English.

| Apps alerts | Level | What it means |
|:-------------------------|:---------|:------------------------------------------------|
| AppDown | critical | An app does not answer on its port. |
| ContainerDown | critical | A container (a packaged app) has stopped. |
| ContainerRestarting | warning | Container \<container\> on \<node\> restarted … times in 15 minutes. |
| ContainerOutOfMemory | warning | Container \<container\> on \<node\> was stopped because it used too much memory. |
| SwarmServiceDown | critical | A cluster app runs fewer copies than it should. |
| SwarmNodeDown | critical | The cluster says one of its servers is not ready. |
| WebAppDown | critical | A web page cannot be reached through the front door (Traefik). |
| WebAppErrors | warning | … of the requests to \<service\> fail with a 5xx error. |
| CertificateEndsSoon | warning | The certificate for \<sans\> ends in … days. |

| Backup alerts | Level | What it means |
|:-------------------------|:---------|:------------------------------------------------|
| BackupTooOld | critical | The last good backup of a server is more than 26 hours old. |

| Databases alerts | Level | What it means |
|:-------------------------|:---------|:------------------------------------------------|
| PostgresDown | critical | A PostgreSQL database server does not answer. |
| PostgresTooManyConnections | warning | PostgreSQL on \<node\> uses … of its connections. |
| PostgresNoPrimary | critical | No database server accepts writes, so apps cannot save data. |
| PostgresReplicaBehind | warning | The PostgreSQL replica on \<node\> is … behind the primary. |
| CacheDown | critical | A cache server does not answer. |
| CacheNoPrimary | critical | No cache server accepts writes. |
| CacheMemoryFull | warning | \<job\> on \<node\> uses … of its memory limit. |
| CacheRejectsConnections | warning | \<job\> on \<node\> refused connections (too many clients). |

| Monitoring alerts | Level | What it means |
|:-------------------------|:---------|:------------------------------------------------|
| TargetDown | critical | The monitoring server cannot read one of its sources, so part of the system is not watched. |
| AlertsNotSent | warning | Alertmanager could not send alerts to \<integration\>. Check monitoring: in config.yml. |
| AlertRulesFailing | warning | Some alert rules cannot be checked, so their alerts would not fire. |
| MetricsScriptNotRunning | warning | ansibro-metrics did not run on \<node\> for 5 minutes. App, backup and swarm checks there are blind. |
| LogsNotSent | warning | The log agent on \<node\> cannot send logs to the monitoring server. |

| Servers alerts | Level | What it means |
|:-------------------------|:---------|:------------------------------------------------|
| NodeDown | critical | A server is off or cannot be reached. |
| NodeRebooted | warning | Server \<node\> restarted. |
| DiskAlmostFull | warning | Disk \<mountpoint\> on \<node\> is … full. |
| DiskFull | critical | A disk is almost completely full. Apps on it can stop or lose data. |
| DiskFillsSoon | warning | At this speed, disk \<mountpoint\> on \<node\> is full within a day. |
| InodesAlmostFull | warning | Disk \<mountpoint\> on \<node\> has almost no free inodes (too many small files). |
| MemoryAlmostFull | warning | Memory on \<node\> is … used. |
| OutOfMemoryKill | warning | Linux stopped a program on \<node\> because memory was full. |
| CpuBusy | warning | CPU on \<node\> is … busy for 15 minutes. |
| ClockNotSynced | warning | The clock on \<node\> is not in sync. Certificates, logins and the swarm need the right time. |
| SystemdServiceFailed | warning | … system service(s) failed on \<node\>. Run: systemctl --failed |

# Operations runbook {#runbook}

## Golden rules {#runbook-rules}

1. **Every change goes through `config.yml`,** then `./install.sh`. It changes only what differs, and it is safe to run again after a failure.
2. **Always run it from the computer that has `state/`.** Elsewhere it makes new passwords that do not match the running system.
3. `--check` (a dry run) is not supported.

**Who can run the installer:** a macOS or Linux computer with Python 3.12 or newer, ansibro 1.2.0, `config.yml` and `state/`. Today that is Bluewave Systems Ltd.

## Procedures {#runbook-procedures}

All commands on a server run after SSH (see [chapter 5](#access)). `/opt/ansibro` belongs to root, so they use `sudo`.

### Add or remove an app {#runbook-app}

- **Add:** add it under `apps:` in `config.yml`, then run `./install.sh`.
- **Remove:** remove it from `config.yml`, then run `./install.sh`. The app stops; its data stays in `/opt/ansibro/<app>` until you delete it with `sudo rm -rf`.
- **Check:** `tests/check.py`.

### Add or remove a server {#runbook-server}

- **Add:** add it to `nodes:` **after** server1, then run `./install.sh`.
- **Remove:** move its apps away first, remove it from `config.yml`, then run:

  ```sh
  ./install.sh -e remove_nodes=true
  ```

- **Never remove server1.**

### Promote or demote a server {#runbook-promote}

On server1: `sudo docker node promote <name>` (worker to manager) or `sudo docker node demote <name>`.

### Upgrade an app or Docker {#runbook-upgrade}

1. In `versions.yml`, change the app's tag **and** digest. Read the digest with `docker buildx imagetools inspect <image>:<tag>`.
2. Run `./install.sh`. Docker is upgraded one server at a time.
3. A major PostgreSQL upgrade (for example 18 to 19) needs a manual dump and restore.

### Get the Let's Encrypt certificates again {#runbook-certs}

DNS must be right and port 80 open. On server1:

```sh
sudo docker service update --force traefik_traefik
```

### Restart an app {#runbook-restart}

- A cluster app: `sudo docker service update --force <stack>_<service>` on server1. See the services with `sudo docker service ls`.
- An app on a fixed server: `cd /opt/ansibro/<app> && sudo docker compose restart` on that server.

### After a server restarts {#runbook-reboot}

- The apps start by themselves. A missed backup runs at boot.

### Locked out of SSH {#runbook-locked}

Open the server's console in the provider's web page, log in, and run `sudo ufw disable`. Then fix `ssh.allow_from` and run `./install.sh` (it turns the firewall back on).

### Docker Hub limit (toomanyrequests) {#runbook-dockerhub}

Wait, or log in to Docker Hub with `sudo docker login` on server1.

### Server labels {#runbook-labels}

ansibro only adds labels. Remove one with `sudo docker node update --label-rm <label> <name>`.

## Incident playbooks {#runbook-incidents}

What to do when a critical alert arrives. First check, then fix, then escalate to support ([chapter 11](#support)) if it is not solved within an hour.

### NodeDown {#incident-nodedown}

- **Means:** a server is off or cannot be reached.
- **Check:** the server's state in the provider's web page; then try SSH.
- **Fix:** start the server. When it is back, the apps return by themselves.
- **Escalate:** when the server does not start.

### DiskFull {#incident-diskfull}

- **Means:** a disk is more than 95% full.
- **Check:** `df -h` on that server.
- **Fix:** delete old files you do not need, or make the disk larger at the provider.
- **Escalate:** when you do not know what fills it.

### AppDown and ContainerDown {#incident-appdown}

- **Means:** an app does not answer, or its container stopped.
- **Check:** `sudo docker ps` and `sudo docker logs <app>` on that server.
- **Fix:** `cd /opt/ansibro/<app> && sudo docker compose restart`.
- **Escalate:** when it stops again.

### SwarmServiceDown {#incident-servicedown}

- **Means:** a cluster app runs fewer copies than it should.
- **Check:** `sudo docker service ps <service>` and `sudo docker service logs <stack>_<service>` on server1.
- **Fix:** `sudo docker service update --force <stack>_<service>`.
- **Escalate:** when the copies do not come back.

### BackupTooOld {#incident-backup}

- **Means:** a server has had no good backup for 26 hours.
- **Check:** `journalctl -u ansibro-backup` and `systemctl is-active ansibro-backup.timer` on that server.
- **Fix:** solve the error in the log, then run `sudo ansibro-backup`.
- **Escalate:** when the backup storage is unreachable or full.

### CertificateEndsSoon {#incident-cert}

- **Means:** a web certificate ends within 14 days.
- **Check:** the date in the browser's lock icon.
- **Fix:** check DNS and port 80, then `sudo docker service update --force traefik_traefik`.
- **Escalate:** a week before it ends.

## What ansibro does not do {#runbook-not}

| Task | Recommended owner |
|:------------------------------------|:------------------------------------------|
| Security updates of the operating system | Northwind Logistics Ltd's operator, or support |
| Upgrading ansibro itself | whoever keeps `state/` (Bluewave Systems Ltd) |
| Renewing the registry certificate (valid 10 years from the first install) | whoever keeps `state/` |
| Adding and removing SSH keys | Northwind Logistics Ltd's operator |

# Security {#security}

## What is open to the internet {#security-exposure}

No web page is open to anyone without a login.

Who can reach the rest:

- SSH: 198.51.100.0/24.
- Admin pages: 198.51.100.0/24.

## Traffic inside the cluster {#security-plaintext}

These services talk without encryption, so they are open only to the cluster servers: PostgreSQL, Redis, RustFS.
Inside the cluster, the monitoring ports (8428, 9428, 8880, 9093 and 3000) have no login.

## Copies of the passwords on the servers {#security-copies}

The servers hold copies of the passwords, readable by root only:

- `/opt/ansibro/backup/installer/state/secrets/` on server1: **every password**, refreshed on each install, and inside every backup of server1.
- `/opt/ansibro/backup/password` on every server: the backup password.
- `.env` files in `/opt/ansibro/<app>/` of the apps that use them.
- `/opt/ansibro/portainer/admin_password`.
- `/root/.docker/config.json` (the registry login).

So anyone with root on server1, or with the backup password and storage, has every password.
On the installer computer, `state/` is **not encrypted**. Recommended: turn on ansibro's encryption (age).

## SSH keys {#security-ssh}

An *SSH key* is a pair of files that lets a person log in without a password. ansibro does not add or remove SSH keys. Who may log in is the list in `~/.ssh/authorized_keys` of `ubuntu` on each server; keep it short and remove keys of people who leave.

## Licenses to note {#security-agpl}

Redis, Victoria monitoring use the AGPL license (for Victoria: Grafana). Using them is free. If you change their code and offer it over a network, you must publish your changes. See [Appendix B](#appendix-licenses).

## Certificate dates {#security-certs}

| Certificate | Ends |
|:------------------------------|:------------------------------------------|
| Web pages (Let's Encrypt) | renewed automatically |
| Image registry (internal) | 10 years after the first install |

# Support {#support}

Call or write to these people, in this order:

| Name | Role | Phone | Email |
|:-------------------|:-------------------|:-------------------|:------------------------------|
| Emma Clarke | Project Manager | \+44 20 7946 0111 | emma\@bluewave.example |

| Item | Detail |
|:--------------------|:---------------------------------------------------|
| Company | Bluewave Systems Ltd |
| Phone | \+44 20 7946 0101 |
| Email | support\@bluewave.example |
| Website | https://bluewave.example |
| Hours | Mon-Fri 09:00-17:00 UK time |
| Response time | Response within 4 business hours |
| Warranty | 3 months, until Thursday, 4 February 2027 |
| Warranty covers | Fixes for configuration errors in this work |
| Vendor access ends | Friday, 4 December 2026 |

**How to report a problem.** Say what you saw, when it started, which page or server, and what you already tried. A screenshot helps.

> **Important:** never send a password in a report, email or chat. Support never asks for one.

# Acceptance test {#acceptance}

ansibro has its own *acceptance test* (`tests/check.py`). It logs in to every app and checks the cluster, the backups and the monitoring.

The acceptance test was **not run** for this document, so no result is recorded. Run it before signing the handover certificate.

The handover certificate has a checklist for the handover session (its first attachment): every web page opens, every login works, 2FA is enrolled, the credentials file opens, laptop access works, a recent backup exists, a test alert arrives.

# Appendix A. Software versions {#appendix-versions .unnumbered}

| App | Image | Tag | Digest |
|:-----------|:--------------------------------------|:-----------------|:-------------|
| Portainer | `docker.io/portainer/portainer-ce` | 2.45.3 | `3609c307943b` |
|  | `docker.io/portainer/agent` | 2.45.3 | `6e6d2d5d8967` |
| PostgreSQL | `docker.io/library/postgres` | 18.6 | `979bccfde354` |
| Redis | `docker.io/library/redis` | 8.10.3 | `298641b35ac5` |
| RustFS | `docker.io/rustfs/rustfs` | 1.0.4 | `ed9210d6411d` |
| Traefik | `docker.io/library/traefik` | v3.7.17 | `30ff62491aac` |
| Victoria monitoring | `docker.io/victoriametrics/victoria-metrics` | v1.155.0 | `f60dc268b54e` |
|  | `docker.io/victoriametrics/victoria-logs` | v1.53.0 | `251121fa882a` |
|  | `docker.io/victoriametrics/vmalert` | v1.155.0 | `3256cba5ddac` |
|  | `docker.io/prom/alertmanager` | v0.34.2 | `39d8bb3966c6` |
|  | `docker.io/grafana/grafana` | 13.2.5 | `9f7aa1e1e324` |

| Component | Version |
|:--------------------|:---------------------------------------------------|
| registry | 3.1.2 |
| monitoring-agents | v1.12.1 |
| docker-ce | 29.9.2-1 |
| docker-ce-cli | 29.9.2-1 |
| containerd.io | 2.4.2-3 |
| docker-buildx-plugin | 0.38.1-1 |
| docker-compose-plugin | 5.6.1-1 |
| ansibro | 1.2.0 |
| dejavu | 1.1.0 |

The digest is the first 12 characters of the image's fingerprint (sha256). It pins the exact image.

# Appendix B. Licenses {#appendix-licenses .unnumbered}

All parts are open source.

| Part | License |
|:-----------------|:------------------------------------------------------|
| Portainer | zlib |
| PostgreSQL | PostgreSQL |
| Redis | AGPL-3.0 (Redis 8 is tri-licensed, used under AGPL) |
| RustFS | Apache-2.0 |
| Traefik | MIT |
| Victoria monitoring | Apache-2.0 (VictoriaMetrics, VictoriaLogs, Alertmanager), AGPL-3.0 (Grafana) |
| registry | Apache-2.0 |
| monitoring-agents | Apache-2.0 |
| backup | BSD-2-Clause |

# Appendix C. Configuration {#appendix-config .unnumbered}

This is `config.yml` as ansibro read it, rebuilt by dejavu. The comments of the original are lost, some values are defaults, and each secret is replaced by its place in the credentials file.

```yaml
domain: northwind.example.com
orchestrator: swarm
tls: letsencrypt
acme_email: it@northwind.example.com
timezone: Europe/London
ssh:
  user: ubuntu
  port: 22
  key: <your SSH private key>
  allow_from: [198.51.100.0/24]
admin_allow_from: [198.51.100.0/24]
nodes:
  - {name: server1, ip: 10.10.0.10, host: 203.0.113.10, role: manager}
apps:
  portainer: swarm
  postgres: server1
  redis: server1
  rustfs: server1
  traefik: swarm
  victoria: server1
monitoring:
  telegram:
    bot_token: <kdbx: 05 Recovery (break-glass)/config.yml monitoring.telegram.bot_token>
    chat_id: <not recorded>
  keep_days: 30
backup:
  repository: s3:https://s3.example.com/northwind-backup
  s3_access_key: <kdbx: 05 Recovery (break-glass)/config.yml backup.s3_access_key>
  s3_secret_key: <kdbx: 05 Recovery (break-glass)/config.yml backup.s3_secret_key>
  time: "02:00"
  keep_daily: 7
  keep_weekly: 4
  keep_monthly: 6
```

# Appendix D. SSH settings {#appendix-ssh .unnumbered}

These lines go into the SSH settings file of a laptop (`~/.ssh/config`; on Windows `%USERPROFILE%\.ssh\config`). The same lines are in the file `ssh_config.txt`.

```text
# SSH settings for Northwind Logistics Ltd (northwind.example.com), made by dejavu 1.1.0.
# Add these lines to ~/.ssh/config (Windows: %USERPROFILE%\.ssh\config).
# The key file is your own key (or the one from the credentials file), never the vendor's.

Host northwind-server1
  HostName 203.0.113.10
  User ubuntu
  Port 22
  IdentityFile ~/.ssh/northwind_ed25519
  IdentitiesOnly yes

# A private pipe to the databases and other services: run "ssh -N northwind-tunnel" and keep it open.
# Then connect to 127.0.0.1 and the local port below.
Host northwind-tunnel
  HostName 203.0.113.10
  User ubuntu
  Port 22
  IdentityFile ~/.ssh/northwind_ed25519
  IdentitiesOnly yes
  ExitOnForwardFailure yes
  # PostgreSQL on server1
  LocalForward 15432 10.10.0.10:5432
  # Redis on server1
  LocalForward 16379 10.10.0.10:6379
  # S3 on server1
  LocalForward 19000 10.10.0.10:9000
```

# Appendix E. Password-change checklist {#appendix-passwords .unnumbered}

Tick each password when it is changed, within 7 days of the handover. [Chapter 6](#credentials) says how.

| Done | Account | Entry in the credentials file | Changed on | By |
|:----|:-------------------|:------------------------------|:-------------|:-------------|
| `☐` | Grafana | `01 Web logins/Grafana` | | |
| `☐` | Portainer | `01 Web logins/Portainer` | | |
| `☐` | PostgreSQL | `02 Databases and cache/PostgreSQL` | | |
| `☐` | Redis | `02 Databases and cache/Redis` | | |
| `☐` | Image registry | `04 Infrastructure/Image registry` | | |
| `☐` | Backup (restic) | `05 Recovery (break-glass)/Backup (restic)` | | |
| `☐` | RustFS S3 | `03 S3 storage/RustFS S3` | | |
| `☐` | Traefik | `01 Web logins/Traefik` | | |
| `☐` | Passphrase of the credentials file | | | |

# Appendix F. Known issues and recommendations {#appendix-issues .unnumbered}

No known issues.

# Appendix G. Data sources {#appendix-sources .unnumbered}

Every fact in this document comes from one of these places. dejavu never opened a password file.

| Facts | Source |
|:------------------------------------------|:------------------------------------------|
| nodes, apps, domain, tls, ssh, allow-lists, backup, monitoring, versions | inventory.py --list |
| traefik_nodes, admin_sso, database, cache, monitoring app | group_vars/all.yml (ansible debug) |
| alerts | roles/observability/files/alerts.yml |
| pages, ports, data, backup kind, change of passwords | dejavu assets/apps.yml |
| secret names | state/secrets (names only) |
| last install | the date of state/summary.md (never opened) |
| ansibro version | git describe / CHANGELOG.md |
| names, dates, contacts, scope, notes | the answers of the vendor (`handover.yml`) |

# Appendix H. Glossary {#appendix-glossary .unnumbered}

| Word | Meaning |
|:-----------------|:----------------------------------------------------------------|
| 2FA | Two-factor login: a password plus a code from an app on your phone. |
| Alert | A message sent when something is wrong. |
| Allow-list | A list of internet addresses that may connect. Empty means anyone. |
| ansibro | The installer that set up this system. |
| Authenticator app | A phone app that shows a new 6-digit code every 30 seconds. |
| Backup | A copy of the data kept somewhere else. |
| Certificate | A file that proves a web page is genuine and encrypts the connection. |
| Cluster | A group of servers that work as one. |
| Container | An app packed with everything it needs, so it runs the same everywhere. |
| Credentials file | The locked KeePass file (`.kdbx`) that holds every password. |
| DNS | The internet's address book: it turns a name into a server's address. |
| Docker Swarm | The program that runs the containers across the cluster. |
| Firewall | A filter that decides which connections may reach a server. |
| High availability | A part keeps working when one server stops. |
| Image | The packed form of an app, from which containers start. |
| KeePassXC | A free program that opens the credentials file. |
| Manager | A server that steers the cluster. |
| Passphrase | The words that open the credentials file. |
| Port | A numbered door on a server for one kind of connection. |
| restic | The backup program. |
| Restore | Putting the data back from a backup. |
| Snapshot | One complete backup at one moment. |
| SSH | A safe way to log in to a server and type commands on it. |
| SSH key | A pair of files that lets a person log in without a password. |
| state/ | The installer's folder with a copy of every password. |
| TLS | The encryption of web pages (the "s" in https). |
| Traefik | The front door of the web pages. |
| Tunnel | A private pipe through SSH from a laptop to a service on a server. |
| ufw | The firewall program on each server. |
