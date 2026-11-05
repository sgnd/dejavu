---
title: "Technical Handover Documentation"
subtitle: "Production · platform.example.com"
short-title: "Technical Documentation · Maju"
lang: en
docnumber: "001/DOK/NUSA/XI/2026"
version: "1.0"
date: "Wednesday, 4 November 2026"
classification: "CONFIDENTIAL"
numbered: true
labels: {page: "Page", of: "of", toc: "Contents"}
cover:
  kicker: "HANDOVER DOCUMENTATION"
  rows:
    - {label: "For", value: "PT Maju Bersama"}
    - {label: "By", value: "PT Nusantara Teknologi"}
    - {label: "System", value: "Production, platform.example.com"}
    - {label: "Document number", value: "001/DOK/NUSA/XI/2026"}
    - {label: "Version", value: "1.0"}
    - {label: "Date", value: "Wednesday, 4 November 2026"}
    - {label: "Classification", value: "CONFIDENTIAL"}
    - {label: "Distribution", value: "PT Maju Bersama and PT Nusantara Teknologi only"}
  footer: "Made with dejavu 1.0.0 from ansibro 1.2.0. This document holds no password. It describes how the system is reached, so keep it confidential."
---

# Document control {#control .unnumbered}

| Role | Name |
|:---------------|:--------------------------------------------------------|
| Prepared by | Rina Wijaya |
| Reviewed by | Andi Saputra |
| Approved by | Dewi Lestari |

| Version | Date | By | Change |
|:--------|:-----------|:----------------|:-----------------------------------------|
| 1.0 | 2026-11-04 | Rina Wijaya | Terbitan pertama |

This document was made with dejavu 1.0.0 from ansibro 1.2.0, configuration `config`, last install Tuesday, 3 November 2026.
It contains no password. Every password is in the credentials file `maju-credentials.kdbx`.
Where an answer was not given, the text says *Not provided*.

## How to read this document {#how-to-read .unnumbered}

- **Everyone** (people who only use the web pages): read [chapter 1](#summary), [chapter 5](#access), [chapter 6](#credentials) and [chapter 11](#support).
- **Operators** (people who look after the servers): read everything.
- Technical words are explained the first time they appear, and again in the [glossary](#appendix-glossary) (Appendix H).
- A red box marks something you must act on.

# Summary {#summary}

## What was built {#summary-built}

PT Nusantara Teknologi built a system of 8 servers for PT Maju Bersama.
The system answers on the web address `platform.example.com` and the pages below it, such as `traefik.platform.example.com`.
It was set up with ansibro, an installer that puts the same programs on every server in the same way.
It runs these programs:

- **Beszel**: A simple dashboard of CPU, memory, disk and containers on every server, with alerts set in its own page.
- **Keycloak**: A single sign-on server. One login (OIDC/SAML) for your apps and users.
- **Kong**: An API gateway. One address for your APIs, with API keys, rate limits and routes.
- **OpenBao**: A safe for your apps' secrets (passwords, API keys). Apps read them through an API.
- **Portainer**: A web page to see and manage the containers and stacks of the cluster.
- **PostgreSQL**: An SQL database for your apps (and for Kong, Keycloak and Authelia).
- **Traefik**: The front door for every web page. It receives HTTPS for the domain and sends each subdomain to its app, with certificates.
- **Valkey**: An in-memory key-value store (a fully open-source Redis alternative), for cache and login sessions.

Built for the \*payments\* team; see \#42 & \<notes\>.

## Six things to know first {#summary-six}

1. **Where the passwords are.** Every password is in one locked file, `maju-credentials.kdbx`. Open it with KeePassXC (see [chapter 5](#access)). The words that open it were given separately by telepon to Siti Rahma.
2. **Change the passwords within 7 days.** The vendor knows them today. [Chapter 6](#credentials) says how, and [Appendix E](#appendix-passwords) is the checklist.
3. **How to open the admin pages.** Use a web browser and go to the addresses in [chapter 4](#apps), for example <https://beszel.platform.example.com/>. You log in with a password and a code from an app on your phone.
4. **There is no backup.** If a server is lost, its data is lost. See [chapter 7](#backup).
5. **Alerts must still be set up.** Beszel shows the health of the servers, but it sends alerts only after you set them up in its page. See [chapter 8](#monitoring).
6. **Who to call.** Rina Wijaya (Project Manager), \+62 812 0000 1111, rina\@nusa.example, Senin-Jumat 09.00-17.00 WIB. See [chapter 11](#support).

## Scope {#summary-scope}

**Part of this work:**

- 8 servers set up with ansibro, and the 8 programs listed above.
- This document, the laptop guides, the handover certificate and the credentials file.

**Not part of this work:**

- The client's business applications

# Architecture {#architecture}

![The servers and the apps on them](architecture.svg)

## Cluster and high availability {#architecture-ha}

The servers form a *cluster*: a group of servers that work as one.
The cluster is run by *k3s*, a small edition of Kubernetes. It starts each app in a *container* (an app packed with everything it needs) and restarts it when it stops.
*Managers* are the servers that steer the cluster. The cluster keeps working while more than half of its managers are up.

*High availability* (HA) means that a part keeps working when one server stops. This is the HA level of each part:

| Part | How it is set up | If one server stops |
|:----------------|:--------------------------------------|:--------------------------------------|
| Cluster managers | 3 managers: master1, master2, master3 | The cluster keeps working (1 may stop) |
| Web entry (Traefik) | On worker1, worker2 | DNS still points at the stopped server; browsers may try it first |
| Database (PostgreSQL) | Patroni on data1, data2, data3, with etcd and a database-proxy | Another server becomes the primary by itself |
| Cache (Valkey) | Primary and two copies with Sentinel on data1, data2, data3 | Sentinel makes a copy the new primary |

## How a visitor reaches an app {#architecture-traffic}

1. *DNS* (the internet's address book) turns `anything.platform.example.com` into the public address of worker1, worker2.
2. The browser connects to *Traefik*, the front door, on port 443 (HTTPS). Port 80 only redirects to 443.
3. Traefik checks who may pass. Each page has one *guard*:
   - **admin**: the visitor's address must be on the admin allow-list, then the admin login asks for a password and a code (2FA);
   - **admin-ip**: the address must be on the admin allow-list; the app then shows its own login;
   - **public**: anyone may open it; the app has its own login, or none.
4. Traefik sends the visitor to the app, wherever it runs in the cluster.

The admin allow-list (`admin_allow_from`) is anyone (the list is empty).

## The first manager {#architecture-first}

`master1` is the *first manager*. It has jobs the other servers do not have:

- ansibro and its acceptance test run their checks from it.
- Portainer keeps its data on it.
- It holds the certificate authority of the private image registry.
- **It must never be removed from the cluster.**

## Components {#architecture-components}

ansibro also installs these parts. They are not apps you chose, but they belong to the system.

| Component | Where | Port | Version | License | What it does |
|:-----------|:------------|:-----|:-------------|:----------|:------------------------------------|
| registry | managers | 5000 | 3.1.2 | Apache-2.0 | A private image registry on every manager. All servers pull images from it. |
| database-proxy | cluster | 5432 | 3.2.26 | GPL-2.0 | HAProxy in front of the HA database, always pointing at the primary. |
| etcd | managers | 12379 | v3.6.16 | Apache-2.0 | The key-value store Patroni uses to elect the PostgreSQL primary. |
| oauth2-proxy | cluster |  | v7.15.5 | MIT | Connects the admin pages to the Keycloak login, at oauth.platform.example.com. |
| sentinel | cache servers | 26379 |  |  | Watches Redis or Valkey and moves the primary when it goes down. |
| k3s | every server | 6443 | v1.36.5+k3s1 | Apache-2.0 | The small Kubernetes that runs the cluster apps. |

# Servers and network {#servers}

## Servers {#servers-list}

The *cluster IP* is the address the servers use among themselves. The *SSH address* is where people and the installer log in.

| Server | Role | Tier | Cluster IP | SSH address | Public IP |
|:-----------|:-----------|:---------|:-------------|:--------------|:--------------|
| data1 | standalone |  | 10.0.0.21 | 10.0.0.21 | *Not provided* |
| data2 | standalone |  | 10.0.0.22 | 10.0.0.22 | *Not provided* |
| data3 | standalone |  | 10.0.0.23 | 10.0.0.23 | *Not provided* |
| master1 (first manager) | manager | control | 10.0.0.11 | 10.0.0.11 | *Not provided* |
| master2 | manager | control | 10.0.0.12 | 10.0.0.12 | *Not provided* |
| master3 | manager | control | 10.0.0.13 | 10.0.0.13 | *Not provided* |
| worker1 | worker | app | 10.0.0.31 | 203.0.113.31 | same as SSH address |
| worker2 | worker | app | 10.0.0.32 | 10.0.0.32 | *Not provided* |

| Server | Provider | Region | Size | Operating system |
|:-----------|:---------------|:-------------|:---------------------------|:------------------|
| data1 | DigitalOcean | *Not provided* | *Not checked* | *Not checked* |
| data2 | DigitalOcean | *Not provided* | *Not checked* | *Not checked* |
| data3 | DigitalOcean | *Not provided* | *Not checked* | *Not checked* |
| master1 | DigitalOcean | *Not provided* | *Not checked* | *Not checked* |
| master2 | DigitalOcean | *Not provided* | *Not checked* | *Not checked* |
| master3 | DigitalOcean | *Not provided* | *Not checked* | *Not checked* |
| worker1 | DigitalOcean | *Not provided* | *Not checked* | *Not checked* |
| worker2 | DigitalOcean | *Not provided* | *Not checked* | *Not checked* |

| Server | Host-key fingerprint (ED25519) |
|:-----------|:--------------------------------------------------------------|
| data1 | *Not checked* |
| data2 | *Not checked* |
| data3 | *Not checked* |
| master1 | *Not checked* |
| master2 | *Not checked* |
| master3 | *Not checked* |
| worker1 | *Not checked* |
| worker2 | *Not checked* |

The *host-key fingerprint* lets you check, on your first SSH login, that you reach the real server. [Chapter 5](#access) shows how to read it.

Apps that run on a fixed server (all other apps run in the cluster):

| Server | Apps |
|:-------------|:----------------------------------------------------------|
| data1 | PostgreSQL, Valkey |
| data2 | PostgreSQL, Valkey, OpenBao |
| data3 | PostgreSQL, Valkey, Beszel |

## DNS {#servers-dns}

| Setting | Value |
|:--------------------|:---------------------------------------------------|
| Mode | no DNS: a hosts file on each laptop |
| Record | `*.platform.example.com` (type A) |
| Points to | 203.0.113.31 (worker1), 10.0.0.32 (worker2) |
| DNS provider | *Not provided* |
| Domain owner | *Not provided* |
| CDN in front | no |

There is no DNS for `platform.example.com`. Each laptop adds these lines to its *hosts file* (the file `hosts.txt` holds the same lines):

```text
# Lines for the hosts file of platform.example.com, made by dejavu 1.0.0.
# Use them only when there is no DNS for *.platform.example.com. One address per name: no failover.
203.0.113.31  beszel.platform.example.com
203.0.113.31  keycloak.platform.example.com
203.0.113.31  oauth.platform.example.com
203.0.113.31  kong.platform.example.com
203.0.113.31  kong-manager.platform.example.com
203.0.113.31  openbao.platform.example.com
203.0.113.31  portainer.platform.example.com
203.0.113.31  traefik.platform.example.com
```

A hosts file gives one address per name, so there is no fallback to another server.

## Certificates (TLS) {#servers-tls}

A *certificate* proves to the browser that the page is really `platform.example.com`, and encrypts the connection (*TLS*, the "s" in https).

| Setting | Value |
|:--------------------|:---------------------------------------------------|
| Mode | Your own certificate (custom) |
| For | *.platform.example.com, platform.example.com |
| Issuer | CN=\*.platform.example.com |
| Expiry | 2100-10-08 |
| Renewal | By hand: replace the certificate and key files, then run `./install.sh` |

## Firewall {#servers-firewall}

A *firewall* decides which connections may reach a server. Each server runs the firewall *ufw*.

- ansibro owns the firewall. It rewrites the rules when they change, and **rules added by hand are removed**. Change the lists below in `config.yml`, then run `./install.sh`.
- Ports published by Docker containers go past ufw.
- An *allow-list* is a list of internet addresses that may connect. An empty list means anyone may connect.

| List | What it guards | Addresses | Whose |
|:----------------|:-------------------|:----------------------|:----------------------|
| `ssh.allow_from` | SSH to every server | **open to anyone** | |
| `admin_allow_from` | the admin web pages | **open to anyone** | |

> **Important:** SSH is open to anyone on the internet, and the admin pages are open to anyone on the internet (they still ask for a login). Recommended: list your office and staff addresses in `config.yml`, then run `./install.sh`.

## Ports {#servers-ports}

A *port* is a numbered door on a server for one kind of connection.

| Port | What | On which servers | Open to |
|:---------|:-------------------|:-------------------------|:-------------------------|
| 2222/tcp | SSH | all | anyone (the list is empty) |
| 80, 443/tcp | Web pages (Traefik) | worker1, worker2 | anyone; admin pages also check `admin_allow_from` |
| 8200/tcp | OpenBao OpenBao API | data2 | the other cluster servers only |
| 5432/tcp | PostgreSQL | data1, data2, data3 | the other cluster servers only |
| 6379/tcp | Valkey | data1, data2, data3 | the other cluster servers only |
| 5000/tcp | registry | master1, master2, master3 | the other cluster servers only |
| 12379/tcp | etcd | master1, master2, master3 | the other cluster servers only |
| 26379/tcp | sentinel | data1, data2, data3 | the other cluster servers only |
| 6443/tcp | k3s API | master1, master2, master3 | the other cluster servers only |
| 45876/tcp | Beszel agent | all | the other cluster servers only |

The databases, cache, storage and queues are reached from a laptop through an SSH tunnel (see [chapter 5](#access)).

## Network between the servers {#servers-wireguard}

WireGuard is off. The servers talk to each other on their cluster IPs, and ansibro does not encrypt that traffic. This is fine on a private network of the provider.

## Time and internet {#servers-time}

- Time zone: **UTC**. Backup times and logs use it.
- The servers use the internet to get programs and the correct time.

# Applications {#apps}

## Overview {#apps-overview}

| App | What it is for | Runs on | Version | License |
|:-----------|:-------------------------------|:-------------------|:-----------|:-----------|
| Beszel | monitoring | data3 | 0.21.1 | MIT |
| Keycloak | login | cluster, on worker1, worker2 | 26.8.1 | Apache-2.0 |
| Kong | API gateway | cluster, on worker1, worker2 | 3.9.4 | Apache-2.0 |
| OpenBao | secret store | data2 | 2.7.2 | MPL-2.0 |
| Portainer | cluster management page | master1 | 2.45.3 | zlib |
| PostgreSQL | database | data1 (main at install time), data2, data3 | spilo-18 4.1-p2 | PostgreSQL |
| Traefik | web front door | worker1, worker2 | k3s v1.36.5+k3s1 | MIT |
| Valkey | cache | data1 (main at install time), data2, data3 | 9.1.3 | BSD-3-Clause |

## Web pages {#apps-web}

| Address | App | Who can open it | Login |
|:------------------------------------|:-----------|:--------------------|:--------------------|
| <https://beszel.platform.example.com/> | Beszel | anyone | the app's own login |
| <https://keycloak.platform.example.com/> | Keycloak | anyone | the app's own login |
| <https://oauth.platform.example.com/> | Keycloak | anyone | the app's own login |
| <https://kong.platform.example.com/> | Kong | anyone | none |
| <https://kong-manager.platform.example.com/> | Kong | anyone | Keycloak login (realm ansibro) with a code from your phone (2FA) |
| <https://openbao.platform.example.com/ui/> | OpenBao | anyone | the app's own login |
| <https://portainer.platform.example.com/> | Portainer | anyone | the app's own login |
| <https://traefik.platform.example.com/dashboard/> | Traefik | anyone | Keycloak login (realm ansibro) with a code from your phone (2FA) |

## Beszel {#app-beszel}

A simple dashboard of CPU, memory, disk and containers on every server, with alerts set in its own page.

| Item | Detail |
|:----------------|:-------------------------------------------------------|
| Runs on | data3 |
| Web page | <https://beszel.platform.example.com/> (its own login) |
| From a laptop | a web browser |
| Credentials | `01 Web logins/Beszel` |
| Data | `/opt/ansibro/beszel`, `/opt/ansibro/beszel-agent` on data3 |
| Backup | Not saved |
| Health check | `beszel health` |

- Beszel alerts are set up in Beszel's own page. The installer logs in with the admin password on every run.

## Keycloak {#app-keycloak}

A single sign-on server. One login (OIDC/SAML) for your apps and users.

| Item | Detail |
|:----------------|:-------------------------------------------------------|
| Runs on | cluster, on worker1, worker2 |
| Web page | <https://keycloak.platform.example.com/> (its own login) |
|  | <https://oauth.platform.example.com/> (its own login) |
| From a laptop | a web browser |
| Credentials | `01 Web logins/Keycloak (master)`, `01 Web logins/Keycloak SSO (realm ansibro)` |
| Data | `/opt/ansibro/keycloak` |
| Backup | Not saved |
| Health check | `/health/ready` |

- Keycloak's page is open to anyone (no IP limit), because the users of your apps log in there.
- When Keycloak is the admin login, the realm "ansibro" with user admin guards the admin pages. The authenticator app is set up at the first login; if the vendor logged in first, reset it.
- The admin pages are connected to Keycloak through <https://oauth.platform.example.com/>.

## Kong {#app-kong}

An API gateway. One address for your APIs, with API keys, rate limits and routes.

| Item | Detail |
|:----------------|:-------------------------------------------------------|
| Runs on | cluster, on worker1, worker2 |
| Web page | <https://kong.platform.example.com/> (no login) |
|  | <https://kong-manager.platform.example.com/> (Keycloak login (realm ansibro) with a code from your phone (2FA)) |
| From a laptop | a web browser |
| Data | `/opt/ansibro/kong` |
| Backup | Not saved |
| Health check | `kong health` |

- Kong keeps its settings in the PostgreSQL database "kong". Your API services must join the network "kong".
- kong.platform.example.com is open to anyone; it is the address of your APIs.

## OpenBao {#app-openbao}

A safe for your apps' secrets (passwords, API keys). Apps read them through an API.

| Item | Detail |
|:----------------|:-------------------------------------------------------|
| Runs on | data2 |
| Web page | <https://openbao.platform.example.com/ui/> (its own login) |
| OpenBao API | `10.0.0.22:8200` |
| From a laptop | a web browser |
| Credentials | `01 Web logins/OpenBao root token`, `05 Recovery (break-glass)/OpenBao unseal key` |
| Data | `/opt/ansibro/openbao` on data2 |
| Backup | Not saved |
| Health check | `/v1/sys/health` |

- OpenBao is sealed after every restart, and its health check stays green while sealed. Unseal it with the unseal key in the web page, or run ./install.sh again.
- The installer uses the root token on every run; revoking it breaks the next install.

## Portainer {#app-portainer}

A web page to see and manage the containers and stacks of the cluster.

| Item | Detail |
|:----------------|:-------------------------------------------------------|
| Runs on | master1 |
| Web page | <https://portainer.platform.example.com/> (its own login) |
| From a laptop | a web browser |
| Credentials | `01 Web logins/Portainer` |
| Data | `/opt/ansibro/portainer` |
| Backup | Not saved |
| Health check | `POST /api/auth` |

- The password file is read only at Portainer's first start. After that, change the password in Portainer itself.

## PostgreSQL {#app-postgres}

An SQL database for your apps (and for Kong, Keycloak and Authelia).

| Item | Detail |
|:----------------|:-------------------------------------------------------|
| Runs on | data1 (main at install time), data2, data3 |
| PostgreSQL | `10.0.0.21:5432`, `10.0.0.22:5432`, `10.0.0.23:5432`; apps in the cluster use `database-proxy.ansibro.svc.cluster.local:5432` |
| From a laptop | an SSH tunnel ([chapter 5](#access)) |
| Credentials | `02 Databases and cache/PostgreSQL` |
| Data | `/opt/ansibro/postgres` on data1, data2, data3 |
| Backup | Not saved |
| Health check | `pg_isready` |

- On 2 or more servers PostgreSQL runs with Patroni. The primary can move; apps in the cluster use the database-proxy.
- A major version upgrade (for example 18 to 19) needs a manual dump and restore.

## Traefik {#app-traefik}

The front door for every web page. It receives HTTPS for the domain and sends each subdomain to its app, with certificates.

| Item | Detail |
|:----------------|:-------------------------------------------------------|
| Runs on | worker1, worker2 |
| Web page | <https://traefik.platform.example.com/dashboard/> (Keycloak login (realm ansibro) with a code from your phone (2FA)) |
| From a laptop | a web browser |
| Credentials | `01 Web logins/Traefik` |
| Data | `/opt/ansibro/traefik` |
| Backup | Not saved |
| Health check | `traefik healthcheck --ping` |

- On k3s this is the Traefik built into k3s, with the version that comes with k3s.
- The Traefik password is not needed for the admin pages: they use the Keycloak login (realm ansibro) with a code from your phone (2FA).

## Valkey {#app-valkey}

An in-memory key-value store (a fully open-source Redis alternative), for cache and login sessions.

| Item | Detail |
|:----------------|:-------------------------------------------------------|
| Runs on | data1 (main at install time), data2, data3 |
| Valkey | `10.0.0.21:6379`, `10.0.0.22:6379`, `10.0.0.23:6379` |
| From a laptop | an SSH tunnel ([chapter 5](#access)) |
| Credentials | `02 Databases and cache/Valkey` |
| Data | `/opt/ansibro/valkey` on data1, data2, data3 |
| Backup | Not saved |
| Health check | `valkey-cli ping` |

- On 3 servers there is one primary and two copies, watched by Sentinel (port 26379, master name "ansibro").

# Access from your laptop {#access}

This chapter shows, step by step, how to reach the system from a Windows, macOS or Linux laptop.

## Who needs what {#access-who}

This part explains how to reach the system from your own computer, step by step. It is written for Windows. On Windows you type the commands in **PowerShell** (Start menu, type "PowerShell"). Each step says what you want to do, what to type, what you should see, and what to do if it fails.

Commands marked *(not tested)* have not been tried on a real laptop yet. If one of them fails, tell the vendor.

Not everyone needs every part. Find your role in this table:

|                          | Viewer (web pages only)       | Operator (also servers)         | Successor (runs the installer)   |
|:-------------------------|:------------------------------|:--------------------------------|:---------------------------------|
| Tools                    | A browser, KeePassXC, an authenticator app | The same, plus the SSH program, kubectl; optional database tools | The same, plus git, Python 3.12 or newer, age; macOS or Linux only |
| Web pages                | Yes                           | Yes                             | Yes                              |
| SSH and tunnels          | No                            | Yes                             | Yes                              |
| Runs the installer       | No                            | No                              | Yes                              |

The people named for this handover:

| Name                      | Role          | Laptop       | Internet address                  |
|:--------------------------|:--------------|:-------------|:----------------------------------|
| Budi Santoso | Operator | Windows | 198.51.100.7 |

Before your first visit, the vendor does two things for you:

1. Adds your internet address to the allow-lists, if the lists are in use (see [Your internet address](#access-ip)).
2. Adds your SSH key to every server, if you are an operator (see [SSH](#access-ssh)).

## Open the credentials file {#access-kdbx}

All passwords are in one encrypted file, **maju-credentials.kdbx**. It opens with KeePassXC, a free password manager. The passphrase that opens it (7 words) is given to you separately, by telepon, to Siti Rahma. It is never in the same message or on the same USB stick as the file.

### Install KeePassXC {#access-kdbx-install}

Goal: have KeePassXC on your computer.

Windows (PowerShell):

```powershell
winget install KeePassXCTeam.KeePassXC
```

On Windows you can also download the installer (MSI) from <https://keepassxc.org/download>. The winget package name is *(not tested)*.

On a phone, KeePassDX (Android), KeePassium or Strongbox (iPhone) can open the file to look things up.

**What you should see:** KeePassXC in your list of apps.

**If it fails:** on a company laptop you may not be allowed to install apps. Ask your IT team, or ask the vendor to install it during the handover session.

### Check the file {#access-kdbx-hash}

Goal: make sure the file you received is exactly the one listed in the Handover Certificate. Open PowerShell in the folder that holds the file, then type:

Windows (PowerShell):

```powershell
Get-FileHash .\maju-credentials.kdbx -Algorithm SHA<size>
```

**What you should see:** a long code of 64 letters and digits. It must be the same as the SHA-<size> of maju-credentials.kdbx in Annex 3 of the Handover Certificate.

**If it fails:** if the code is different, do not use the file. Ask the vendor for a new copy.

### Open it and copy a password {#access-kdbx-open}

Goal: read a password without typing it by hand.

1. Open KeePassXC, choose Open Database, and pick maju-credentials.kdbx.
2. Type the 7 words of the passphrase, with a space between the words.
3. Pick a group on the left (for example "01 Web logins"), then click an entry.
4. Copy the password with Ctrl+C (Cmd+C on a Mac) and paste it into the login page. KeePassXC clears the clipboard after a few seconds.
5. Files inside an entry (attachments) are under the entry's Attachments: right-click one to save it.

Keep a backup copy of the file on a USB stick in a safe place. After the handover, change the passphrase (Database, then Database Security) and change the passwords within 7 days, as this document explains.

**What you should see:** the groups and entries of the file.

**If it fails:** "Invalid credentials" means a word is wrong. Check the spelling and the spaces, and try again.

## Your internet address {#access-ip}

Goal: know the internet address (IP address) of your connection, because some pages and the servers only accept known addresses.

Windows (PowerShell):

```powershell
curl.exe -4 https://ifconfig.me
```

You can also open <https://ifconfig.me> in a browser. It is a service run by a third party.

**What you should see:** four numbers with dots, for example 198.51.100.7.

The system has two lists of allowed addresses (allow-lists):

| List                 | What it protects                       | Addresses allowed now                         |
|:---------------------|:---------------------------------------|:----------------------------------------------|
| `ssh.allow_from`     | SSH, the login to the servers (port 2222) | Empty: open to anyone |
| `admin_allow_from`   | The admin web pages                    | Empty: open to anyone |

An empty list means the system is **open to anyone** on the internet: the passwords are the only protection.

**If it fails:** only the operator can add an address: they add it to the list in the installer's settings (config.yml) and run the installer again. Send your address to the vendor or your operator.

## Web pages {#access-web}

### Check the name {#access-web-dns}

Goal: make sure your computer finds the system's web pages under platform.example.com.

Windows (PowerShell):

```powershell
ping -n 1 beszel.platform.example.com
```

**What you should see:** the address 203.0.113.31 or 10.0.0.32. That is the server that answers the web pages. A reply is not needed: some networks block ping, but the address must be right.

There is no DNS for platform.example.com, so you add the names to your computer's hosts file (next step).

**If it fails:** "could not find host" means the name is not known. Add the hosts lines below.

### Add the names to the hosts file {#access-web-hosts}

Goal: tell your computer the address of each web page, because there is no DNS. These are the lines from the file hosts.txt:

```text
203.0.113.31  beszel.platform.example.com
203.0.113.31  keycloak.platform.example.com
203.0.113.31  oauth.platform.example.com
203.0.113.31  kong.platform.example.com
203.0.113.31  kong-manager.platform.example.com
203.0.113.31  openbao.platform.example.com
203.0.113.31  portainer.platform.example.com
203.0.113.31  traefik.platform.example.com
```

A hosts file cannot use wildcards, so every page has its own line, and each name has one address only: when that server is down, the pages are down for you. A record in your company DNS is the better solution; ask your IT team.

Windows (PowerShell): open Notepad as administrator, paste the lines at the end, save, then clear the name cache. Company laptops often block this.

```powershell
Start-Process notepad "$env:SystemRoot\System32\drivers\etc\hosts" -Verb RunAs
ipconfig /flushdns
```

**What you should see:** the ping in the step above now shows the right address.

**If it fails:** a browser with "secure DNS" turned on may skip the hosts file *(not tested)*. Turn that setting off in the browser, or ask your IT team.

### Certificates {#access-web-tls}

The system uses its own certificate, valid until 2100-10-08. When it comes from a public authority there is nothing to do. When it comes from your company's own authority, your IT team installs that authority on the laptops.

### The pages {#access-web-pages}

Goal: know which pages exist, who can open them, and which entry of the credentials file holds the login.

| Address                                  | App              | Who can open it           | Login                       | Entry in the credentials file        |
|:-----------------------------------------|:-----------------|:--------------------------|:----------------------------|:-------------------------------------|
| <https://beszel.platform.example.com/> | beszel | Anyone (the allow-list is empty) | The app's own login | 01 Web logins/Beszel |
| <https://keycloak.platform.example.com/> | keycloak | Anyone | The app's own login | 01 Web logins/Keycloak (master); 01 Web logins/Keycloak SSO (realm ansibro) |
| <https://oauth.platform.example.com/> | keycloak | Anyone | The app's own login | 01 Web logins/Keycloak (master); 01 Web logins/Keycloak SSO (realm ansibro) |
| <https://kong.platform.example.com/> | kong | Anyone | None | None |
| <https://kong-manager.platform.example.com/> | kong | Anyone (the allow-list is empty) | Admin login (Keycloak SSO) | 01 Web logins/Keycloak SSO (realm ansibro) |
| <https://openbao.platform.example.com/ui/> | openbao | Anyone (the allow-list is empty) | The app's own login | 01 Web logins/OpenBao root token |
| <https://portainer.platform.example.com/> | portainer | Anyone (the allow-list is empty) | The app's own login | 01 Web logins/Portainer |
| <https://traefik.platform.example.com/dashboard/> | traefik | Anyone (the allow-list is empty) | Admin login (Keycloak SSO) | 01 Web logins/Keycloak SSO (realm ansibro) |

**What you should see:** the login page of the app, or the admin login first (Keycloak SSO).

**If it fails:** "403 Forbidden" means your internet address is not on the admin allow-list (see [Your internet address](#access-ip)). A page that never loads usually means a name problem (see [Check the name](#access-web-dns)).

### First login and 2FA {#access-web-2fa}

Goal: set up the second factor (2FA): a 6-digit code from an app on your phone, asked after the password. Do this during the handover session, with the vendor.

1. Install an authenticator app on your phone: Aegis, Google Authenticator or Microsoft Authenticator.
2. Open an admin page. The Keycloak login asks for the user admin and the password from "01 Web logins/Keycloak SSO (realm ansibro)".
3. At the first login Keycloak shows a QR code. Scan it with the authenticator app and type the 6-digit code.
4. If the vendor already set up their own phone for this user, ask them to reset it first.

**What you should see:** the admin page opens after the code.

**If it fails:** check that your phone's clock is right; the codes depend on the time.

## SSH: the login to the servers {#access-ssh}

This part is for operators. SSH (Secure Shell) is the safe way to type commands on a server. You log in with a key: a pair of files, one private (it stays on your laptop) and one public (it goes to the servers). The vendor's own key is never handed over.

### Check the SSH program {#access-ssh-client}

Goal: make sure your computer has the OpenSSH program.

Windows (PowerShell):

```powershell
ssh -V
```

**What you should see:** a version, for example "OpenSSH_9.6".

**If it fails:** on Windows, install it from PowerShell opened as administrator: `Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0`. Use OpenSSH, not PuTTY: PuTTY needs its own key format.

### Make your own key {#access-ssh-key}

Goal: make your key pair, then send only the public part (the file ending in .pub) to the vendor.

Windows (PowerShell):

```powershell
New-Item -ItemType Directory -Force "$env:USERPROFILE\.ssh"
ssh-keygen -t ed25519 -f $env:USERPROFILE\.ssh\maju_ed25519 -C "your name"
```

Choose a passphrase for the key when asked; it protects the key if your laptop is lost.

**What you should see:** two new files: maju_ed25519 (private: never send it) and maju_ed25519.pub (public: send this one to the vendor).

**If it fails:** "No such file or directory" means the .ssh folder is missing: run the first line again.

### The vendor adds your key {#access-ssh-add}

Goal: the vendor puts your public key on every server. ansibro does not do this, so the operator does it by hand, once per server, with their own access:

```sh
cat maju_ed25519.pub | ssh -p 2222 ops@<server> \
  "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys \
  && chmod 600 ~/.ssh/authorized_keys"
```

`<server>` is each address in the next table. This is a row of the acceptance checklist (Annex 1 of the Handover Certificate).

### Add the SSH settings {#access-ssh-config}

Goal: give each server a short name, so `ssh maju-master1` is all you type. The file **ssh_config.txt** from the handover pack has the settings; add it to the end of your SSH settings file:

Windows (PowerShell):

```powershell
Get-Content .\ssh_config.txt |
  Add-Content -Encoding ascii "$env:USERPROFILE\.ssh\config"
```

It gives these names:

| Name                        | Server          | Address           | Goes through                  |
|:----------------------------|:----------------|:------------------|:------------------------------|
| `maju-data1` | data1 | 10.0.0.21 | `maju-worker1` |
| `maju-data2` | data2 | 10.0.0.22 | `maju-worker1` |
| `maju-data3` | data3 | 10.0.0.23 | `maju-worker1` |
| `maju-master1` | master1 | 10.0.0.11 | `maju-worker1` |
| `maju-master2` | master2 | 10.0.0.12 | `maju-worker1` |
| `maju-master3` | master3 | 10.0.0.13 | `maju-worker1` |
| `maju-worker1` | worker1 | 203.0.113.31 | Direct |
| `maju-worker2` | worker2 | 10.0.0.32 | `maju-worker1` |

Every name logs in as ops on port 2222, with the key ~/.ssh/maju_ed25519.
A server without a public address is reached through another server ("goes through").

**What you should see:** the `Host` lines at the end of the file.

**If it fails:** if you already had a `Host` with the same name, remove the old one.

### First connection {#access-ssh-first}

Goal: log in to the first server once and check that it is the real one.

Windows (PowerShell):

```powershell
ssh maju-master1
```

The first time, SSH shows the server's fingerprint (a code starting with SHA256:) and asks to continue. Compare it with this table, then type `yes`. If they differ, type `no` and call the vendor.

| Server          | Host-key fingerprint                                                          |
|:----------------|:------------------------------------------------------------------------------|
| data1 | Not checked |
| data2 | Not checked |
| data3 | Not checked |
| master1 | Not checked |
| master2 | Not checked |
| master3 | Not checked |
| worker1 | Not checked |
| worker2 | Not checked |

The fingerprints were not checked by the acceptance test. Ask the vendor to read them out from each server with `ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub`.

**What you should see:** a prompt like `ops@master1:~$`. Type `exit` to leave. Commands for the system need `sudo` in front, because its files under /opt/ansibro belong to the administrator (root).

**If it fails:**

- "Permission denied (publickey)": your key is not on that server yet, or the key file name is wrong.
- "Connection timed out": your address is not in ssh.allow_from, or the provider's firewall blocks port 2222.
- "UNPROTECTED PRIVATE KEY FILE": the key file is readable by others. Fix it:

Windows (PowerShell):

```powershell
icacls $env:USERPROFILE\.ssh\maju_ed25519 /inheritance:r `
  /grant:r "$($env:USERNAME):(R)"
```

### Remember the key passphrase {#access-ssh-agent}

Goal: type the key's passphrase once per session instead of at every login.

Windows (PowerShell):

```powershell
Get-Service ssh-agent | Set-Service -StartupType Automatic
Start-Service ssh-agent
ssh-add $env:USERPROFILE\.ssh\maju_ed25519
```

On Windows, the first two lines need PowerShell opened as administrator.

**What you should see:** "Identity added".

**If it fails:** "Could not open a connection to your authentication agent" means the agent is not running: run the Windows lines as administrator.

## Databases and other services: an SSH tunnel {#access-tunnel}

The databases and similar services listen only inside the cluster, and their traffic is not encrypted. To reach them, you open an SSH tunnel: a private pipe through SSH from your laptop to the server. The tunnel also encrypts the traffic.

### Start the tunnel {#access-tunnel-start}

Goal: open all the pipes at once with the name `maju-tunnel` from ssh_config.txt.

Windows (PowerShell):

```powershell
ssh -N maju-tunnel
```

Keep this window open while you work; close it (Ctrl+C) when you are done. Then connect your tools to 127.0.0.1 (your own laptop) and the port in this table:

| Service              | Server        | On the server            | On your laptop          |
|:---------------------|:--------------|:-------------------------|:------------------------|
| OpenBao API | data2 | 10.0.0.22:8200 | 127.0.0.1:18200 |
| PostgreSQL | data1 | 10.0.0.21:5432 | 127.0.0.1:15432 |
| PostgreSQL | data2 | 10.0.0.22:5432 | 127.0.0.1:15433 |
| PostgreSQL | data3 | 10.0.0.23:5432 | 127.0.0.1:15434 |
| Valkey | data1 | 10.0.0.21:6379 | 127.0.0.1:16379 |
| Valkey | data2 | 10.0.0.22:6379 | 127.0.0.1:16380 |
| Valkey | data3 | 10.0.0.23:6379 | 127.0.0.1:16381 |
| Kubernetes API | master1 | 10.0.0.11:6443 | 127.0.0.1:16443 |

**What you should see:** nothing: no prompt, and the window stays open. That means the tunnel works.

**If it fails:** "Address already in use" or "port forwarding failed" means another program on your laptop uses that port. Close it, or change the first number of that `LocalForward` line in your SSH settings.

### Connect your tools {#access-tunnel-tools}

Goal: use the database or service through the tunnel. The passwords are in the group "02 Databases and cache" of the credentials file.

PostgreSQL *(not tested)*:

Windows (PowerShell):

```powershell
psql "host=127.0.0.1,127.0.0.1,127.0.0.1
      port=15432,15433,15434 user=postgres
      target_session_attrs=read-write"
```

The main server (primary) can move between data1, data2, data3; this line tries each port and keeps the one that accepts changes.

Valkey *(not tested)*:

Windows (PowerShell):

```powershell
redis-cli -h 127.0.0.1 -p 16379 --askpass
```

With 3 servers, only the primary accepts changes, and it can move. Find it first; the answer is a server address from the table above, so use the laptop port of that line:

Windows (PowerShell):

```powershell
ssh maju-data1 ("sudo docker exec valkey-sentinel valkey-cli -p 26379 " +
  "sentinel get-master-addr-by-name ansibro")
```

OpenBao (the secrets store): the easy way is its web page <https://openbao.platform.example.com/ui/>, with the token from "01 Web logins/OpenBao root token". From the command line *(not tested)*:

Windows (PowerShell):

```powershell
$env:BAO_ADDR = "http://127.0.0.1:18200"
bao login
```

Programs with a window (DBeaver, TablePlus, RedisInsight, WinSCP, Cyberduck) work the same way: start the tunnel, then connect to host 127.0.0.1 and the laptop port. They can also make the tunnel themselves: in their SSH settings, use host 203.0.113.31, port 2222, user ops and your key file; then connect to the address "on the server" from the table.

**What you should see:** the tool connects and asks for the password, or shows the data.

**If it fails:** "connection refused" means the tunnel is not running. Start it again in its own window.

## Managing the cluster {#access-cluster}

### Kubernetes (k3s) {#access-cluster-k3s}

Goal: use kubectl, the Kubernetes command, from your laptop. The cluster's API (port 6443) is closed to laptops, so kubectl goes through the SSH tunnel.

1. Install kubectl, within one minor version of k3s (v1.36.5+k3s1).

Windows (PowerShell):

```powershell
winget install -e --id Kubernetes.kubectl
```

The winget package name is *(not tested)*.

2. Copy the cluster's access file (kubeconfig). It is a secret: it gives full control of the cluster, so it stays on your laptop.

Windows (PowerShell):

```powershell
mkdir -Force $HOME\.kube
ssh maju-master1 "sudo cat /etc/rancher/k3s/k3s.yaml" |
  Set-Content -Encoding ascii $HOME\.kube\maju.yaml
```

On Windows PowerShell 5.1, `>` writes a format kubectl cannot read, hence `Set-Content` *(not tested)*.

3. Point it at the tunnel (port 16443 on your laptop):

Windows (PowerShell):

```powershell
kubectl config set-cluster default --server=https://127.0.0.1:16443 `
  --kubeconfig $HOME\.kube\maju.yaml
```

4. Start the tunnel (`ssh -N maju-tunnel`, see [the tunnel](#access-tunnel)) in its own window, then:

Windows (PowerShell):

```powershell
kubectl --kubeconfig $HOME\.kube\maju.yaml get nodes
```

**What you should see:** the servers, each with the status Ready.

**If it fails:** "connection refused" means the tunnel is not running. A certificate error means step 3 was skipped.

To reach the database through the cluster's database-proxy, which always points at the primary (use another laptop port while the tunnel runs, because 15432 is taken):

Windows (PowerShell):

```powershell
kubectl --kubeconfig $HOME\.kube\maju.yaml -n ansibro `
  port-forward svc/database-proxy 25432:5432
```

Portainer at <https://portainer.platform.example.com/> can also manage the cluster from the browser.

### Your own images {#access-cluster-images}

Goal: run your own app images. The image registry (registry.ansibro:5000) is reachable only from the servers, so you send the image over SSH and push it on the first server:

Windows (PowerShell):

```powershell
docker save app:1 | ssh maju-master1 "sudo docker load"
ssh maju-master1 ("sudo docker tag app:1 registry.ansibro:5000/app:1 && " +
  "sudo docker push registry.ansibro:5000/app:1")
```

`app:1` is your image name and version. The registry is not in the backup: after a restore, push your images again.

## Troubleshooting {#access-trouble}

| Problem                                 | What to do                                                            |
|:----------------------------------------|:----------------------------------------------------------------------|
| "403 Forbidden" on a web page           | Your address is not on the admin allow-list. See [Your internet address](#access-ip). |
| A certificate warning                   | See [Certificates](#access-web-tls). |
| SSH: "Connection timed out"             | Your address is not in ssh.allow_from, or the provider's firewall blocks the port. |
| SSH: "Permission denied (publickey)"    | Your key is not on that server, or the key file name in the settings is wrong. |
| Tunnel: "Address already in use"        | Another program uses that laptop port. Close it, or change the port. |
| OpenBao says "sealed"                   | After a restart OpenBao is locked. Unlock it on its web page with "05 Recovery (break-glass)/OpenBao unseal key", or the operator runs the installer again. |
| Nobody can log in to a server any more  | The operator opens the provider's web console, runs `sudo ufw disable`, fixes the list and runs the installer again. |

When you are stuck, call the vendor (Senin-Jumat 09.00-17.00 WIB). Never send a password by email or chat.

| Name                     | Role                  | Phone                  | Email                          |
|:-------------------------|:----------------------|:-----------------------|:-------------------------------|
| Rina Wijaya | Project Manager | \+62 812 0000 1111 | rina\@nusa.example |

# Credentials and password changes {#credentials}

## The credentials file {#credentials-file}

Every password is in one locked file, `maju-credentials.kdbx`. It is a KeePass file. Open it with KeePassXC ([chapter 5](#access)).
The words that open it (the *passphrase*) travelled separately, by telepon, to Siti Rahma. Neither this document nor the handover certificate holds a password.

The file has these groups:

| Group | What it holds | Who needs it |
|:-------------------------------|:------------------------------------------|:-------------------|
| 01 Web logins | Beszel, Keycloak (master), Keycloak SSO (realm ansibro), OpenBao root token, Portainer, Traefik | everyone who manages the web pages |
| 02 Databases and cache | PostgreSQL, Valkey | operators |
| 04 Infrastructure | Image registry | operators |
| 05 Recovery (break-glass) | OpenBao unseal key | keep safe; only to restore |
| 06 Internal (re-run ansibro) | 9 technical passwords, plus the file "ansibro installer files" (to run ansibro again) | only to run ansibro again |

## Accounts {#credentials-accounts}

These are the accounts people use. The class says how to change the password (see the next section).

| Account | For | Entry in the credentials file | How to change | Deadline |
|:----------------|:-----------|:------------------------------|:----------------|:-----------|
| Beszel | daily use | `01 Web logins/Beszel` | App and file together | within 7 days |
| Keycloak (master) | daily use | `01 Web logins/Keycloak (master)` | App and file together | within 7 days |
| Keycloak SSO (realm ansibro) | daily use | `01 Web logins/Keycloak SSO (realm ansibro)` | App first | within 7 days |
| OpenBao root token | daily use | `01 Web logins/OpenBao root token` | App and file together | within 7 days |
| OpenBao unseal key | recovery | `05 Recovery (break-glass)/OpenBao unseal key` | Do not change | only if leaked |
| Portainer | daily use | `01 Web logins/Portainer` | App first | within 7 days |
| PostgreSQL | daily use | `02 Databases and cache/PostgreSQL` | App and file together (not tested) | within 7 days |
| Image registry | recovery | `04 Infrastructure/Image registry` | App and file together | when the vendor's access ends |
| Traefik | daily use | `01 Web logins/Traefik` | File first | within 7 days |
| Valkey | daily use | `02 Databases and cache/Valkey` | File first | within 7 days |
| Passphrase of the credentials file | everyone | (the file itself) | KeePassXC | within 7 days |

## How to change a password {#credentials-change}

ansibro keeps a copy of every password in a folder called `state/` on the computer that runs the installer. It uses that copy each time it runs. So a password must be changed in the right place, or the next install undoes it or fails.

### File first {#credentials-file-first}

For: Traefik, Valkey.
ansibro writes these passwords into the app every time it runs. A change made only in the app is undone at the next install.

1. On the installer computer, put the new password in the file `state/secrets/<name>`.
2. Run `./install.sh`.
3. Update the credentials file, and every app of yours that uses this password.

### App and file together {#credentials-both}

For: Beszel, Keycloak (master), OpenBao root token, PostgreSQL, Image registry.
ansibro logs in with these passwords, or they are needed to restore. If only one place changes, the next install fails.

1. Change the password in the app.
2. At the same time, put the same password in `state/secrets/<name>` on the installer computer.
3. Run `./install.sh`, then the acceptance test (`tests/check.py`).
4. Update the credentials file.

- PostgreSQL: how the app takes a new password was not tested, so treat it as "app and file together".

### App first {#credentials-app-first}

For: Keycloak SSO (realm ansibro), Portainer.
The app reads these passwords only the first time it starts. After that the app owns them.

1. Change the password in the app.
2. Put the same password in `state/secrets/<name>`, so the records and the acceptance test stay right.
3. Update the credentials file.

### Do not change {#credentials-internal}

The passwords in the group "06 Internal (re-run ansibro)" are used only between programs. No person types them. Change them only if they leaked, and let the ansibro operator do it.

> **Important:** ansibro's own summary file says "change them in the app, then update the file too". That is wrong for the classes "file first" and "app and file together". Follow this chapter instead.

## Your phone code (2FA) {#credentials-2fa}

The admin login asks for a password and a code from an *authenticator app* on a phone (*2FA*, two-factor login).
The code is set up at the first login of the user admin in the Keycloak realm "ansibro". If the vendor logged in first, the vendor's phone is linked:

1. Ask the vendor to remove its authenticator from the user admin in Keycloak.
2. Log in at <https://oauth.platform.example.com/> and scan the new code with your own phone.

## Who keeps state/ {#credentials-state}

**PT Nusantara Teknologi keeps `state/`** (the installer's copy of the passwords).
After you change a password of the class "file first" or "app and file together", send the new value to the vendor **inside a credentials file with its own passphrase**, never in an email or chat. Otherwise the next install by the vendor undoes your change ("file first") or fails ("app and file together").

## Ending the vendor's access {#credentials-revoke}

Planned date: Friday, 4 December 2026. On that date:

1. Remove the vendor's SSH key from `~/.ssh/authorized_keys` of the user `ops` on every server. ansibro does not manage SSH keys.
2. Remove the vendor's addresses from `ssh.allow_from` and `admin_allow_from` in `config.yml`, then run `./install.sh`.
3. Change the passwords as above.
5. The vendor deletes its copy of `state/` when you agree it may.

## Changing the passphrase of the credentials file {#credentials-passphrase}

In KeePassXC: menu **Database → Database Security**, then set a new password. (In KeePass 2: **File → Change Master Key**.) Keep a backup copy of the file in a safe place.

## Adding a staff member {#credentials-staff}

- Add the person as a user in the Keycloak realm "ansibro".
- Add their internet address to `admin_allow_from` (web pages) and `ssh.allow_from` (SSH, operators only) in `config.yml`, then run `./install.sh`.
- For operators: add their SSH public key to `~/.ssh/authorized_keys` of `ops` on every server.

# Backup and restore {#backup}

A *backup* is a copy of the data kept somewhere else, so it can be put back (*restored*) after a loss.

> **Important:** **there is no backup.** If a server breaks, its data is lost for good. Recommended: add a `backup:` section to `config.yml` with a storage place outside these servers, then run `./install.sh`.

# Monitoring and alerts {#monitoring}

*Monitoring* watches the servers and apps. An *alert* is a message sent when something is wrong.

## The monitoring system {#monitoring-tool}

Beszel shows CPU, memory, disk and containers of every server at <https://beszel.platform.example.com/>. It keeps no logs.

> **Important:** Beszel sends no alert until you set alerts up in its own page. Do this during the handover, and test it.

# Operations runbook {#runbook}

## Golden rules {#runbook-rules}

1. **Every change goes through `config.yml`,** then `./install.sh`. It changes only what differs, and it is safe to run again after a failure.
2. **Always run it from the computer that has `state/`.** Elsewhere it makes new passwords that do not match the running system.
3. `--check` (a dry run) is not supported.

**Who can run the installer:** a macOS or Linux computer with Python 3.12 or newer, ansibro 1.2.0, `config.yml` and `state/`. Today that is PT Nusantara Teknologi.

## Procedures {#runbook-procedures}

All commands on a server run after SSH (see [chapter 5](#access)). `/opt/ansibro` belongs to root, so they use `sudo`.

### Add or remove an app {#runbook-app}

- **Add:** add it under `apps:` in `config.yml`, then run `./install.sh`.
- **Remove:** remove it from `config.yml`, then run `./install.sh`. The app stops; its data stays in `/opt/ansibro/<app>` until you delete it with `sudo rm -rf`.
- **Check:** `tests/check.py`.

### Add or remove a server {#runbook-server}

- **Add:** add it to `nodes:` **after** master1, then run `./install.sh`.
- **Remove:** move its apps away first, remove it from `config.yml`, then run:

  ```sh
  ./install.sh -e remove_nodes=true
  ```

- **Never remove master1.**

### Change the managers when PostgreSQL uses Patroni {#runbook-patroni}

On every manager, stop and wipe etcd, then run `./install.sh`. The database takes no writes for about 60 seconds.

```sh
cd /opt/ansibro/etcd && sudo docker compose down && sudo rm -rf data managers
```

### Upgrade an app or Docker {#runbook-upgrade}

1. In `versions.yml`, change the app's tag **and** digest. Read the digest with `docker buildx imagetools inspect <image>:<tag>`.
2. Run `./install.sh`. Docker is upgraded one server at a time.
3. A major PostgreSQL upgrade (for example 18 to 19) needs a manual dump and restore.

### Restart an app {#runbook-restart}

- A cluster app: see the state with `sudo k3s kubectl get pods -A` on master1.
- An app on a fixed server: `cd /opt/ansibro/<app> && sudo docker compose restart` on that server.

### After a server restarts {#runbook-reboot}

- The apps start by themselves. A missed backup runs at boot.
- **OpenBao starts locked (sealed).** Unseal it in its web page with the unseal key from the credentials file, or run `./install.sh`.

### Locked out of SSH {#runbook-locked}

Open the server's console in the provider's web page, log in, and run `sudo ufw disable`. Then fix `ssh.allow_from` and run `./install.sh` (it turns the firewall back on).

### Docker Hub limit (toomanyrequests) {#runbook-dockerhub}

Wait, or log in to Docker Hub with `sudo docker login` on master1.

## What ansibro does not do {#runbook-not}

| Task | Recommended owner |
|:------------------------------------|:------------------------------------------|
| Security updates of the operating system | PT Maju Bersama's operator, or support |
| Upgrading ansibro itself | whoever keeps `state/` (PT Nusantara Teknologi) |
| Renewing the registry certificate (valid 10 years from the first install) | whoever keeps `state/` |
| Adding and removing SSH keys | PT Maju Bersama's operator |

# Security {#security}

## What is open to the internet {#security-exposure}

These pages are open to anyone. Each has its own login, or is meant to be public:

- <https://keycloak.platform.example.com/>
- <https://oauth.platform.example.com/>
- <https://kong.platform.example.com/> (no login: your APIs)

Who can reach the rest:

- SSH: anyone (the list is empty).
- Admin pages: anyone (the list is empty).

## Traffic inside the cluster {#security-plaintext}

These services talk without encryption, so they are open only to the cluster servers: OpenBao, PostgreSQL, Valkey.

## Copies of the passwords on the servers {#security-copies}

The servers hold copies of the passwords, readable by root only:

- `.env` files in `/opt/ansibro/<app>/` of the apps that use them.
- `/opt/ansibro/portainer/admin_password`.
- `/root/.docker/config.json` (the registry login).

So anyone with root on master1, has every password.
On the installer computer, `state/` is **not encrypted**. Recommended: turn on ansibro's encryption (age).

## SSH keys {#security-ssh}

An *SSH key* is a pair of files that lets a person log in without a password. ansibro does not add or remove SSH keys. Who may log in is the list in `~/.ssh/authorized_keys` of `ops` on each server; keep it short and remove keys of people who leave.

## Certificate dates {#security-certs}

| Certificate | Ends |
|:------------------------------|:------------------------------------------|
| Web pages (custom) | 2100-10-08 |
| Image registry (internal) | 10 years after the first install |

# Support {#support}

Call or write to these people, in this order:

| Name | Role | Phone | Email |
|:-------------------|:-------------------|:-------------------|:------------------------------|
| Rina Wijaya | Project Manager | \+62 812 0000 1111 | rina\@nusa.example |

| Item | Detail |
|:--------------------|:---------------------------------------------------|
| Company | PT Nusantara Teknologi |
| Phone | \+62 21 555 0101 |
| Email | support\@nusa.example |
| Website | https://nusa.example |
| Hours | Senin-Jumat 09.00-17.00 WIB |
| Response time | Respons dalam 4 jam kerja |
| Warranty | 3 months, until Thursday, 4 February 2027 |
| Warranty covers | Perbaikan kesalahan konfigurasi dari pekerjaan ini |
| Final handover | Thursday, 4 February 2027 |
| Vendor access ends | Friday, 4 December 2026 |

**How to report a problem.** Say what you saw, when it started, which page or server, and what you already tried. A screenshot helps.

> **Important:** never send a password in a report, email or chat. Support never asks for one.

# Acceptance test {#acceptance}

ansibro has its own *acceptance test* (`tests/check.py`). It logs in to every app and checks the cluster, the backups and the monitoring.

The acceptance test was **not run** for this document, so no result is recorded. Run it before signing the handover certificate.

The handover certificate has a checklist for the handover session (its first attachment): every web page opens, every login works, 2FA is enrolled, the credentials file opens, laptop access works, a recent backup exists, a test alert arrives, and the client holds the OpenBao unseal key.

# Appendix A. Software versions {#appendix-versions .unnumbered}

| App | Image | Tag | Digest |
|:-----------|:--------------------------------------|:-----------------|:-------------|
| Beszel | `docker.io/henrygd/beszel` | 0.21.1 | `8514a69d9bbb` |
|  | `docker.io/henrygd/beszel-agent` | 0.21.1 | `cb6868012964` |
| Keycloak | `docker.io/keycloak/keycloak` | 26.8.1 | `a78d6b795721` |
|  | `quay.io/oauth2-proxy/oauth2-proxy` | v7.15.5 | `8498b0d0ef0a` |
| Kong | `docker.io/library/kong` | 3.9.4 | `c1f5fbb80cd6` |
| OpenBao | `docker.io/openbao/openbao` | 2.7.2 | `5046911075e1` |
| Portainer | `docker.io/portainer/portainer-ce` | 2.45.3 | `3609c307943b` |
|  | `docker.io/portainer/agent` | 2.45.3 | `6e6d2d5d8967` |
| PostgreSQL | `ghcr.io/zalando/spilo-18` | 4.1-p2 | `258a87d34699` |
|  | `quay.io/coreos/etcd` | v3.6.16 | `a9c7cc12156f` |
|  | `docker.io/library/haproxy` | 3.2.26 | `de853dd229e0` |
| Traefik | k3s v1.36.5+k3s1 | | |
| Valkey | `docker.io/valkey/valkey` | 9.1.3 | `3add1a336a92` |

| Component | Version |
|:--------------------|:---------------------------------------------------|
| registry | 3.1.2 |
| database-proxy | 3.2.26 |
| etcd | v3.6.16 |
| oauth2-proxy | v7.15.5 |
| docker-ce | 29.9.2-1 |
| docker-ce-cli | 29.9.2-1 |
| containerd.io | 2.4.2-3 |
| docker-buildx-plugin | 0.38.1-1 |
| docker-compose-plugin | 5.6.1-1 |
| k3s | v1.36.5+k3s1 |
| ansibro | 1.2.0 |
| dejavu | 1.0.0 |

The digest is the first 12 characters of the image's fingerprint (sha256). It pins the exact image.

# Appendix B. Licenses {#appendix-licenses .unnumbered}

All parts are open source.

| Part | License |
|:-----------------|:------------------------------------------------------|
| Beszel | MIT |
| Keycloak | Apache-2.0 |
| Kong | Apache-2.0 |
| OpenBao | MPL-2.0 |
| Portainer | zlib |
| PostgreSQL | PostgreSQL |
| Traefik | MIT |
| Valkey | BSD-3-Clause |
| registry | Apache-2.0 |
| database-proxy | GPL-2.0 |
| etcd | Apache-2.0 |
| oauth2-proxy | MIT |
| k3s | Apache-2.0 |

# Appendix C. Configuration {#appendix-config .unnumbered}

This is `config.yml` as ansibro read it, rebuilt by dejavu. The comments of the original are lost, some values are defaults, and each secret is replaced by its place in the credentials file.

```yaml
domain: platform.example.com
orchestrator: k3s
tls: custom
tls_cert: <file>   # the certificate file
tls_key: <file>    # the key file, not in this document
timezone: UTC
ssh:
  user: ops
  port: 2222
  key: <your SSH private key>
nodes:
  - {name: data1, ip: 10.0.0.21, host: 10.0.0.21, role: standalone}
  - {name: data2, ip: 10.0.0.22, host: 10.0.0.22, role: standalone}
  - {name: data3, ip: 10.0.0.23, host: 10.0.0.23, role: standalone}
  - {name: master1, ip: 10.0.0.11, host: 10.0.0.11, role: manager}
  - {name: master2, ip: 10.0.0.12, host: 10.0.0.12, role: manager}
  - {name: master3, ip: 10.0.0.13, host: 10.0.0.13, role: manager}
  - {name: worker1, ip: 10.0.0.31, host: 203.0.113.31, role: worker}
  - {name: worker2, ip: 10.0.0.32, host: 10.0.0.32, role: worker}
apps:
  beszel: data3
  keycloak: cluster
  kong: cluster
  openbao: data2
  portainer: cluster
  postgres: [data1, data2, data3]
  traefik: cluster
  valkey: [data1, data2, data3]
```

# Appendix D. SSH settings {#appendix-ssh .unnumbered}

These lines go into the SSH settings file of a laptop (`~/.ssh/config`; on Windows `%USERPROFILE%\.ssh\config`). The same lines are in the file `ssh_config.txt`.

```text
# SSH settings for PT Maju Bersama (platform.example.com), made by dejavu 1.0.0.
# Add these lines to ~/.ssh/config (Windows: %USERPROFILE%\.ssh\config).
# The key file is your own key (or the one from the credentials file), never the vendor's.

Host maju-data1
  HostName 10.0.0.21
  User ops
  Port 2222
  IdentityFile ~/.ssh/maju_ed25519
  IdentitiesOnly yes
  ProxyJump maju-worker1

Host maju-data2
  HostName 10.0.0.22
  User ops
  Port 2222
  IdentityFile ~/.ssh/maju_ed25519
  IdentitiesOnly yes
  ProxyJump maju-worker1

Host maju-data3
  HostName 10.0.0.23
  User ops
  Port 2222
  IdentityFile ~/.ssh/maju_ed25519
  IdentitiesOnly yes
  ProxyJump maju-worker1

Host maju-master1
  HostName 10.0.0.11
  User ops
  Port 2222
  IdentityFile ~/.ssh/maju_ed25519
  IdentitiesOnly yes
  ProxyJump maju-worker1

Host maju-master2
  HostName 10.0.0.12
  User ops
  Port 2222
  IdentityFile ~/.ssh/maju_ed25519
  IdentitiesOnly yes
  ProxyJump maju-worker1

Host maju-master3
  HostName 10.0.0.13
  User ops
  Port 2222
  IdentityFile ~/.ssh/maju_ed25519
  IdentitiesOnly yes
  ProxyJump maju-worker1

Host maju-worker1
  HostName 203.0.113.31
  User ops
  Port 2222
  IdentityFile ~/.ssh/maju_ed25519
  IdentitiesOnly yes

Host maju-worker2
  HostName 10.0.0.32
  User ops
  Port 2222
  IdentityFile ~/.ssh/maju_ed25519
  IdentitiesOnly yes
  ProxyJump maju-worker1

# A private pipe to the databases and other services: run "ssh -N maju-tunnel" and keep it open.
# Then connect to 127.0.0.1 and the local port below.
Host maju-tunnel
  HostName 203.0.113.31
  User ops
  Port 2222
  IdentityFile ~/.ssh/maju_ed25519
  IdentitiesOnly yes
  ExitOnForwardFailure yes
  # OpenBao API on data2
  LocalForward 18200 10.0.0.22:8200
  # PostgreSQL on data1
  LocalForward 15432 10.0.0.21:5432
  # PostgreSQL on data2
  LocalForward 15433 10.0.0.22:5432
  # PostgreSQL on data3
  LocalForward 15434 10.0.0.23:5432
  # Valkey on data1
  LocalForward 16379 10.0.0.21:6379
  # Valkey on data2
  LocalForward 16380 10.0.0.22:6379
  # Valkey on data3
  LocalForward 16381 10.0.0.23:6379
  # Kubernetes API on master1
  LocalForward 16443 10.0.0.11:6443
```

# Appendix E. Password-change checklist {#appendix-passwords .unnumbered}

Tick each password when it is changed, within 7 days of the handover. [Chapter 6](#credentials) says how.

| Done | Account | Entry in the credentials file | Changed on | By |
|:----|:-------------------|:------------------------------|:-------------|:-------------|
| `☐` | Beszel | `01 Web logins/Beszel` | | |
| `☐` | Keycloak (master) | `01 Web logins/Keycloak (master)` | | |
| `☐` | Keycloak SSO (realm ansibro) | `01 Web logins/Keycloak SSO (realm ansibro)` | | |
| `☐` | OpenBao root token | `01 Web logins/OpenBao root token` | | |
| `☐` | Portainer | `01 Web logins/Portainer` | | |
| `☐` | PostgreSQL | `02 Databases and cache/PostgreSQL` | | |
| `☐` | Image registry | `04 Infrastructure/Image registry` | | |
| `☐` | Traefik | `01 Web logins/Traefik` | | |
| `☐` | Valkey | `02 Databases and cache/Valkey` | | |
| `☐` | Passphrase of the credentials file | | | |

# Appendix F. Known issues and recommendations {#appendix-issues .unnumbered}

- **The allow-list `ssh.allow_from` is empty.** SSH can be reached from any internet address. Recommended: list your office and staff addresses.
- **The allow-list `admin_allow_from` is empty.** The admin pages can be reached from any internet address. Recommended: list your office and staff addresses.
- **No backup.** A lost server means lost data. Recommended: add a backup to a storage place outside these servers.
- **Beszel alerts.** They must be set up by hand in Beszel's page, then tested.

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
| Firewall | A filter that decides which connections may reach a server. |
| High availability | A part keeps working when one server stops. |
| Image | The packed form of an app, from which containers start. |
| k3s | A small edition of Kubernetes that runs the containers across the cluster. |
| KeePassXC | A free program that opens the credentials file. |
| Manager | A server that steers the cluster. |
| Passphrase | The words that open the credentials file. |
| Patroni | The program that picks a new PostgreSQL primary when one stops. |
| Port | A numbered door on a server for one kind of connection. |
| Primary | The one server of a group that accepts writes; the others keep copies. |
| restic | The backup program. |
| Restore | Putting the data back from a backup. |
| Sentinel | The program that picks a new cache primary when one stops. |
| Snapshot | One complete backup at one moment. |
| SSH | A safe way to log in to a server and type commands on it. |
| SSH key | A pair of files that lets a person log in without a password. |
| state/ | The installer's folder with a copy of every password. |
| TLS | The encryption of web pages (the "s" in https). |
| Traefik | The front door of the web pages. |
| Tunnel | A private pipe through SSH from a laptop to a service on a server. |
| ufw | The firewall program on each server. |
