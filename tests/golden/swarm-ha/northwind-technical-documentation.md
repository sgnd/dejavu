---
title: "Technical Handover Documentation"
subtitle: "Production · northwind.example.org"
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
    - {label: "System", value: "Production, northwind.example.org"}
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

Bluewave Systems Ltd built a system of 9 servers for Northwind Logistics Ltd.
The system answers on the web address `northwind.example.org` and the pages below it, such as `traefik.northwind.example.org`.
It was set up with ansibro, an installer that puts the same programs on every server in the same way.
It runs these programs:

- **Authelia**: A login page with a second factor (2FA) in front of the admin pages.
- **Garage**: S3-compatible file storage. On 3 servers it keeps 3 copies of every file.
- **Portainer**: A web page to see and manage the containers and stacks of the cluster.
- **PostgreSQL**: An SQL database for your apps (and for Kong, Keycloak and Authelia).
- **Redis**: An in-memory key-value store, for cache and login sessions.
- **Traefik**: The front door for every web page. It receives HTTPS for the domain and sends each subdomain to its app, with certificates.
- **Uptime Kuma**: Checks every minute that your web pages answer, and tells you when one is down.
- **Victoria monitoring**: Full monitoring. Metrics, logs, alert rules, Grafana, and alerts to Telegram, email or a webhook.

## Six things to know first {#summary-six}

1. **Where the passwords are.** Every password is in one locked file, `northwind-credentials.kdbx`. Open it with KeePassXC (see [chapter 5](#access)). The words that open it were given separately by phone call to Sarah Miller.
2. **Change the passwords within 7 days.** The vendor knows them today. [Chapter 6](#credentials) says how, and [Appendix E](#appendix-passwords) is the checklist.
3. **How to open the admin pages.** Use a web browser and go to the addresses in [chapter 4](#apps), for example <https://authelia.northwind.example.org/>. They open only from the internet addresses on the allow-list. You log in with a password and a code from an app on your phone.
4. **Backup is on.** Every night at 02:00 (UTC) each server copies its data to `s3.example.com`.
5. **Alerts are on.** Problems are reported to slack. See [chapter 8](#monitoring).
6. **Who to call.** Emma Clarke (Project Manager), \+44 20 7946 0111, emma\@bluewave.example, Mon-Fri 09:00-17:00 UK time. See [chapter 11](#support).

## Scope {#summary-scope}

**Part of this work:**

- 9 servers set up with ansibro, and the 8 programs listed above.
- This document, the laptop guides, the handover certificate and the credentials file.

**Not part of this work:**

- The client's business applications

# Architecture {#architecture}

![The servers and the apps on them](architecture.svg)

## Cluster and high availability {#architecture-ha}

The servers form a *cluster*: a group of servers that work as one.
The cluster is run by *Docker Swarm*, which starts each app in a *container* (an app packed with everything it needs) and restarts it when it stops.
*Managers* are the servers that steer the cluster. The cluster keeps working while more than half of its managers are up.

*High availability* (HA) means that a part keeps working when one server stops. This is the HA level of each part:

| Part | How it is set up | If one server stops |
|:----------------|:--------------------------------------|:--------------------------------------|
| Cluster managers | 3 managers: manager1, manager2, manager3 | The cluster keeps working (1 may stop) |
| Web entry (Traefik) | On manager1, manager2, manager3 | DNS still points at the stopped server; browsers may try it first |
| Database (PostgreSQL) | Patroni on data1, data2, data3, with etcd and a database-proxy | Another server becomes the primary by itself |
| Cache (Redis) | Primary and two copies with Sentinel on data1, data2, data3 | Sentinel makes a copy the new primary |
| Storage (Garage) | 3 servers, 3 copies of every file | Files stay available from the other copies |

## How a visitor reaches an app {#architecture-traffic}

1. *DNS* (the internet's address book) turns `anything.northwind.example.org` into the public address of manager1, manager2, manager3.
2. The browser connects to *Traefik*, the front door, on port 443 (HTTPS). Port 80 only redirects to 443.
3. Traefik checks who may pass. Each page has one *guard*:
   - **admin**: the visitor's address must be on the admin allow-list, then the admin login asks for a password and a code (2FA);
   - **admin-ip**: the address must be on the admin allow-list; the app then shows its own login;
   - **public**: anyone may open it; the app has its own login, or none.
4. Traefik sends the visitor to the app, wherever it runs in the cluster.

The admin allow-list (`admin_allow_from`) is 198.51.100.0/24, 192.0.2.10.

## The first manager {#architecture-first}

`manager1` is the *first manager*. It has jobs the other servers do not have:

- ansibro and its acceptance test run their checks from it.
- Portainer and Authelia keep their data on it.
- Authelia writes its first 2FA code and password-reset links to a file on it.
- Its nightly backup also holds the Swarm state, a copy of `config.yml` and a copy of every password file.
- It holds the certificate authority of the private image registry.
- **It must never be removed from the cluster.**

## Components {#architecture-components}

ansibro also installs these parts. They are not apps you chose, but they belong to the system.

| Component | Where | Port | Version | License | What it does |
|:-----------|:------------|:-----|:-------------|:----------|:------------------------------------|
| registry | managers | 5000 | 3.1.2 | Apache-2.0 | A private image registry on every manager. All servers pull images from it. |
| database-proxy | cluster | 5432 | 3.2.26 | GPL-2.0 | HAProxy in front of the HA database, always pointing at the primary. |
| etcd | managers | 12379 | v3.6.16 | Apache-2.0 | The key-value store Patroni uses to elect the PostgreSQL primary. |
| sentinel | cache servers | 26379 |  |  | Watches Redis or Valkey and moves the primary when it goes down. |
| monitoring-agents | every server | 9100 | v1.12.1 | Apache-2.0 | node-exporter, cAdvisor, Vector and the database exporters on every server, plus the ansibro-metrics timer. |
| backup | every server |  |  | BSD-2-Clause | The ansibro-backup timer with restic, every night on every server. |
| wireguard | every server | 51820 |  | GPL-2.0 | The encrypted network between the servers only (not a VPN for laptops). |

# Servers and network {#servers}

## Servers {#servers-list}

The *cluster IP* is the address the servers use among themselves. The *SSH address* is where people and the installer log in.

| Server | Role | Tier | Cluster IP | SSH address | Public IP |
|:-----------|:-----------|:---------|:-------------|:--------------|:--------------|
| data1 | standalone |  | 10.0.0.21 | 203.0.113.21 | same as SSH address |
| data2 | standalone |  | 10.0.0.22 | 203.0.113.22 | same as SSH address |
| data3 | standalone |  | 10.0.0.23 | 203.0.113.23 | same as SSH address |
| manager1 (first manager) | manager | gateway | 10.0.0.11 | 203.0.113.11 | same as SSH address |
| manager2 | manager | gateway | 10.0.0.12 | 203.0.113.12 | same as SSH address |
| manager3 | manager | gateway | 10.0.0.13 | 203.0.113.13 | same as SSH address |
| worker1 | worker | app | 10.0.0.31 | 203.0.113.31 | same as SSH address |
| worker2 | worker | app | 10.0.0.32 | 203.0.113.32 | same as SSH address |
| worker3 | worker | app | 10.0.0.33 | 203.0.113.33 | same as SSH address |

| Server | Provider | Region | Size | Operating system |
|:-----------|:---------------|:-------------|:---------------------------|:------------------|
| data1 | DigitalOcean | *Not provided* | 4 vCPU, 8.0 GB memory, 160 GB disk | Ubuntu 24.04 (kernel 6.8.0-88-generic) |
| data2 | DigitalOcean | *Not provided* | 4 vCPU, 8.0 GB memory, 160 GB disk | Ubuntu 24.04 (kernel 6.8.0-88-generic) |
| data3 | DigitalOcean | *Not provided* | 4 vCPU, 8.0 GB memory, 160 GB disk | Ubuntu 24.04 (kernel 6.8.0-88-generic) |
| manager1 | DigitalOcean | LON1 | 2 vCPU, 4.0 GB memory, 80 GB disk | Ubuntu 24.04 (kernel 6.8.0-88-generic) |
| manager2 | DigitalOcean | *Not provided* | 2 vCPU, 4.0 GB memory, 80 GB disk | Ubuntu 24.04 (kernel 6.8.0-88-generic) |
| manager3 | DigitalOcean | *Not provided* | 2 vCPU, 4.0 GB memory, 80 GB disk | Ubuntu 24.04 (kernel 6.8.0-88-generic) |
| worker1 | DigitalOcean | *Not provided* | 4 vCPU, 4.0 GB memory, 80 GB disk | Ubuntu 24.04 (kernel 6.8.0-88-generic) |
| worker2 | DigitalOcean | *Not provided* | 4 vCPU, 4.0 GB memory, 80 GB disk | Ubuntu 24.04 (kernel 6.8.0-88-generic) |
| worker3 | DigitalOcean | *Not provided* | 4 vCPU, 4.0 GB memory, 80 GB disk | Ubuntu 24.04 (kernel 6.8.0-88-generic) |

| Server | Host-key fingerprint (ED25519) |
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

The *host-key fingerprint* lets you check, on your first SSH login, that you reach the real server. [Chapter 5](#access) shows how to read it.

Apps that run on a fixed server (all other apps run in the cluster):

| Server | Apps |
|:-------------|:----------------------------------------------------------|
| data1 | PostgreSQL, Redis, Garage, Victoria monitoring |
| data2 | PostgreSQL, Redis, Garage, Uptime Kuma |
| data3 | PostgreSQL, Redis, Garage |

## DNS {#servers-dns}

| Setting | Value |
|:--------------------|:---------------------------------------------------|
| Mode | public DNS |
| Record | `*.northwind.example.org` (type A) |
| Points to | 203.0.113.11 (manager1), 203.0.113.12 (manager2), 203.0.113.13 (manager3) |
| DNS provider | Cloudflare |
| Domain owner | Northwind Logistics Ltd |
| CDN in front | no |

## Certificates (TLS) {#servers-tls}

A *certificate* proves to the browser that the page is really `northwind.example.org`, and encrypts the connection (*TLS*, the "s" in https).

| Setting | Value |
|:--------------------|:---------------------------------------------------|
| Mode | Self-signed |
| Issuer | Traefik's own built-in certificate |
| Expiry | It is made again each time Traefik starts |
| Renewal | None |

> **Important:** with a self-signed certificate every browser shows a warning on every page, and there is no certificate you can install to stop it. Recommended: switch to `tls: custom` with a certificate from your company's certificate authority.

On 2026-11-04, the served certificate was issued by CN=Test Self-Signed and ends on 2027-11-04.

## Firewall {#servers-firewall}

A *firewall* decides which connections may reach a server. Each server runs the firewall *ufw*.

- ansibro owns the firewall. It rewrites the rules when they change, and **rules added by hand are removed**. Change the lists below in `config.yml`, then run `./install.sh`.
- Ports published by Docker containers go past ufw.
- An *allow-list* is a list of internet addresses that may connect. An empty list means anyone may connect.

| List | What it guards | Addresses | Whose |
|:----------------|:-------------------|:----------------------|:----------------------|
| `ssh.allow_from` | SSH to every server | **open to anyone** | |
| `admin_allow_from` | the admin web pages | 198.51.100.0/24 | Sarah Miller |
|  |  | 192.0.2.10 | *Not provided* |

> **Important:** SSH is open to anyone on the internet. Recommended: list your office and staff addresses in `config.yml`, then run `./install.sh`.

> **Important:** these people's addresses are not on the allow-lists yet, so they cannot connect: Priya Shah (203.0.113.200).

## Ports {#servers-ports}

A *port* is a numbered door on a server for one kind of connection.

| Port | What | On which servers | Open to |
|:---------|:-------------------|:-------------------------|:-------------------------|
| 22/tcp | SSH | all | anyone (the list is empty) |
| 80, 443/tcp | Web pages (Traefik) | manager1, manager2, manager3 | anyone; admin pages also check `admin_allow_from` |
| 3900/tcp | Garage S3 | data1, data2, data3 | the other cluster servers only |
| 5432/tcp | PostgreSQL | data1, data2, data3 | the other cluster servers only |
| 6379/tcp | Redis | data1, data2, data3 | the other cluster servers only |
| 5000/tcp | registry | manager1, manager2, manager3 | the other cluster servers only |
| 12379/tcp | etcd | manager1, manager2, manager3 | the other cluster servers only |
| 26379/tcp | sentinel | data1, data2, data3 | the other cluster servers only |
| 9100/tcp | monitoring-agents | all | the other cluster servers only |
| 51820/udp | wireguard | all | the other cluster servers only |

The databases, cache, storage and queues are reached from a laptop through an SSH tunnel (see [chapter 5](#access)).

## Network between the servers {#servers-wireguard}

The servers talk to each other through *WireGuard*, an encrypted network (UDP port 51820). The cluster IPs above are WireGuard addresses; SSH uses the SSH address.
WireGuard connects the servers only. It is **not** a VPN for laptops.

## Time and internet {#servers-time}

- Time zone: **UTC**. Backup times and logs use it.
- The servers use the internet to get programs and the correct time.

# Applications {#apps}

## Overview {#apps-overview}

| App | What it is for | Runs on | Version | License |
|:-----------|:-------------------------------|:-------------------|:-----------|:-----------|
| Authelia | login | manager1 | 4.39.28 | Apache-2.0 |
| Garage | file storage (S3) | data1, data2, data3 | v2.5.0 | AGPL-3.0 |
| Portainer | cluster management page | manager1 | 2.45.3 | zlib |
| PostgreSQL | database | data1 (main at install time), data2, data3 | spilo-18 4.1-p2 | PostgreSQL |
| Redis | cache | data1 (main at install time), data2, data3 | 8.10.3 | AGPL-3.0 |
| Traefik | web front door | manager1, manager2, manager3 | v3.7.17 | MIT |
| Uptime Kuma | uptime checks | data2 | 2.5.8 | MIT |
| Victoria monitoring | monitoring | data1 | victoria-metrics v1.155.0 | Apache-2.0 |

## Web pages {#apps-web}

| Address | App | Who can open it | Login |
|:------------------------------------|:-----------|:--------------------|:--------------------|
| <https://authelia.northwind.example.org/> | Authelia | anyone | the app's own login |
| <https://portainer.northwind.example.org/> | Portainer | admin allow-list | the app's own login |
| <https://traefik.northwind.example.org/dashboard/> | Traefik | admin allow-list | Authelia login with a code from your phone (2FA) |
| <https://uptimekuma.northwind.example.org/> | Uptime Kuma | admin allow-list | the app's own login |
| <https://grafana.northwind.example.org/> | Victoria monitoring | admin allow-list | the app's own login |
| <https://alertmanager.northwind.example.org/> | Victoria monitoring | admin allow-list | Authelia login with a code from your phone (2FA) |
| <https://metrics.northwind.example.org/vmui> | Victoria monitoring | admin allow-list | Authelia login with a code from your phone (2FA) |
| <https://logs.northwind.example.org/select/vmui> | Victoria monitoring | admin allow-list | Authelia login with a code from your phone (2FA) |

## Authelia {#app-authelia}

A login page with a second factor (2FA) in front of the admin pages.

| Item | Detail |
|:----------------|:-------------------------------------------------------|
| Runs on | manager1 |
| Web page | <https://authelia.northwind.example.org/> (its own login) |
| From a laptop | a web browser |
| Credentials | `01 Web logins/Authelia` |
| Data | `/opt/ansibro/authelia` |
| Backup | Copied while paused |
| Health check | `POST /api/firstfactor` |

- After the install, users.yml on the first manager is the source of truth for Authelia's accounts.
- There is no mail server. The first 2FA code and reset links are written to /opt/ansibro/authelia/config/notification.txt on the first manager.

## Garage {#app-garage}

S3-compatible file storage. On 3 servers it keeps 3 copies of every file.

| Item | Detail |
|:----------------|:-------------------------------------------------------|
| Runs on | data1, data2, data3 |
| S3 | `10.0.0.21:3900`, `10.0.0.22:3900`, `10.0.0.23:3900` |
| From a laptop | an SSH tunnel ([chapter 5](#access)) |
| Credentials | `03 S3 storage/Garage S3` |
| Data | `/opt/ansibro/garage` on data1, data2, data3 |
| Backup | Partly saved |
| Health check | `TCP 3900` |

- The access key is "GK" followed by the garage\_access\_key file; the region is "garage". The number of copies cannot change after the first install.
- Editing the key file adds a second key; the old key stays valid until it is deleted with the garage command.

## Portainer {#app-portainer}

A web page to see and manage the containers and stacks of the cluster.

| Item | Detail |
|:----------------|:-------------------------------------------------------|
| Runs on | manager1 |
| Web page | <https://portainer.northwind.example.org/> (its own login) |
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
| Runs on | data1 (main at install time), data2, data3 |
| PostgreSQL | `10.0.0.21:5432`, `10.0.0.22:5432`, `10.0.0.23:5432`; apps in the cluster use `database-proxy_haproxy:5432` |
| From a laptop | an SSH tunnel ([chapter 5](#access)) |
| Credentials | `02 Databases and cache/PostgreSQL` |
| Data | `/opt/ansibro/postgres` on data1, data2, data3 |
| Backup | Database dump |
| Health check | `pg_isready` |

- On 2 or more servers PostgreSQL runs with Patroni. The primary can move; apps in the cluster use the database-proxy.
- A major version upgrade (for example 18 to 19) needs a manual dump and restore.

## Redis {#app-redis}

An in-memory key-value store, for cache and login sessions.

| Item | Detail |
|:----------------|:-------------------------------------------------------|
| Runs on | data1 (main at install time), data2, data3 |
| Redis | `10.0.0.21:6379`, `10.0.0.22:6379`, `10.0.0.23:6379` |
| From a laptop | an SSH tunnel ([chapter 5](#access)) |
| Credentials | `02 Databases and cache/Redis` |
| Data | `/opt/ansibro/redis` on data1, data2, data3 |
| Backup | Copied while paused |
| Health check | `redis-cli ping` |

- On 3 servers there is one primary and two copies, watched by Sentinel (port 26379, master name "ansibro").

## Traefik {#app-traefik}

The front door for every web page. It receives HTTPS for the domain and sends each subdomain to its app, with certificates.

| Item | Detail |
|:----------------|:-------------------------------------------------------|
| Runs on | manager1, manager2, manager3 |
| Web page | <https://traefik.northwind.example.org/dashboard/> (Authelia login with a code from your phone (2FA)) |
| From a laptop | a web browser |
| Credentials | `01 Web logins/Traefik` |
| Data | `/opt/ansibro/traefik` |
| Backup | Copied while paused |
| Health check | `traefik healthcheck --ping` |

- The Traefik password is not needed for the admin pages: they use the Authelia login with a code from your phone (2FA).

## Uptime Kuma {#app-uptimekuma}

Checks every minute that your web pages answer, and tells you when one is down.

| Item | Detail |
|:----------------|:-------------------------------------------------------|
| Runs on | data2 |
| Web page | <https://uptimekuma.northwind.example.org/> (its own login) |
| From a laptop | a web browser |
| Credentials | `01 Web logins/Uptime Kuma` |
| Data | `/opt/ansibro/uptimekuma` on data2 |
| Backup | Copied while paused |
| Health check | `TCP 3001` |

- The monitors are made once, at the first install. Notifications (email, Telegram and so on) must be set up in Uptime Kuma itself.

## Victoria monitoring {#app-victoria}

Full monitoring. Metrics, logs, alert rules, Grafana, and alerts to Telegram, email or a webhook.

| Item | Detail |
|:----------------|:-------------------------------------------------------|
| Runs on | data1 |
| Web page | <https://grafana.northwind.example.org/> (its own login) |
|  | <https://alertmanager.northwind.example.org/> (Authelia login with a code from your phone (2FA)) |
|  | <https://metrics.northwind.example.org/vmui> (Authelia login with a code from your phone (2FA)) |
|  | <https://logs.northwind.example.org/select/vmui> (Authelia login with a code from your phone (2FA)) |
| From a laptop | a web browser |
| Credentials | `01 Web logins/Grafana` |
| Data | `/opt/ansibro/victoria`, `/opt/ansibro/monitoring-agent` on data1 |
| Backup | Partly saved |
| Health check | `Watchdog alert` |

- The metrics and logs history is not backed up; the settings, Grafana and Alertmanager are.

# Access from your laptop {#access}

This chapter shows, step by step, how to reach the system from a Windows, macOS or Linux laptop.

## Who needs what {#access-who}

This part explains how to reach the system from your own computer, step by step. It is written for Windows, macOS, Linux. On Windows you type the commands in **PowerShell** (Start menu, type "PowerShell"). On macOS and Linux you type the commands in the **Terminal** app. Each step says what you want to do, what to type, what you should see, and what to do if it fails.

Commands marked *(not tested)* have not been tried on a real laptop yet. If one of them fails, tell the vendor.

Not everyone needs every part. Find your role in this table:

|                          | Viewer (web pages only)       | Operator (also servers)         | Successor (runs the installer)   |
|:-------------------------|:------------------------------|:--------------------------------|:---------------------------------|
| Tools                    | A browser, KeePassXC, an authenticator app | The same, plus the SSH program; optional database tools | The same, plus git, Python 3.12 or newer, age; macOS or Linux only |
| Web pages                | Yes                           | Yes                             | Yes                              |
| SSH and tunnels          | No                            | Yes                             | Yes                              |
| Runs the installer       | No                            | No                              | Yes                              |

The people named for this handover:

| Name                      | Role          | Laptop       | Internet address                  |
|:--------------------------|:--------------|:-------------|:----------------------------------|
| Tom Hughes | Operator | Windows | 198.51.100.7 |
| Sarah Miller | Viewer | macOS | 198.51.100.0/24 |
| Priya Shah | Successor | Linux | 203.0.113.200 |

Before your first visit, the vendor does two things for you:

1. Adds your internet address to the allow-lists, if the lists are in use (see [Your internet address](#access-ip)).
2. Adds your SSH key to every server, if you are an operator (see [SSH](#access-ssh)).

> **Important:** these addresses are outside the allow-lists, so these people are blocked until the vendor adds their address and runs the installer again: Priya Shah (203.0.113.200).

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

Linux (Terminal):

```sh
sudo apt install keepassxc
```

On Windows you can also download the installer (MSI) from <https://keepassxc.org/download>. The winget package name is *(not tested)*.
On macOS you can also download the DMG from <https://keepassxc.org/download>. On the first start, if macOS refuses to open it, right-click the app and choose Open.
On Linux, other choices are `sudo dnf install keepassxc` (Fedora) or `flatpak install flathub org.keepassxc.KeePassXC`. On Debian 13 and Ubuntu 26.04 the package may be called `keepassxc-full`.

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

Linux (Terminal):

```sh
sha<size>sum northwind-credentials.kdbx
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

macOS and Linux (Terminal):

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
| `ssh.allow_from`     | SSH, the login to the servers (port 22) | Empty: open to anyone |
| `admin_allow_from`   | The admin web pages                    | 198.51.100.0/24, 192.0.2.10 |

An empty list means the system is **open to anyone** on the internet for that list: the passwords are the only protection.
When a list is set, an address that is not on it gets "403 Forbidden" on the admin pages, or no answer (a timeout) on SSH. This also happens when your home address changes, behind a company proxy, or on a connection with only an IPv6 address.

**If it fails:** only the operator can add an address: they add it to the list in the installer's settings (config.yml) and run the installer again. Send your address to the vendor or your operator.

## Web pages {#access-web}

### Check the name {#access-web-dns}

Goal: make sure your computer finds the system's web pages under northwind.example.org.

macOS and Linux (Terminal):

```sh
ping -c 1 authelia.northwind.example.org
```

Windows (PowerShell):

```powershell
ping -n 1 authelia.northwind.example.org
```

**What you should see:** the address 203.0.113.11 or 203.0.113.12 or 203.0.113.13. That is the server that answers the web pages. A reply is not needed: some networks block ping, but the address must be right.

The names come from the public DNS (the internet's phone book), with one record for every name under northwind.example.org.

**If it fails:** "could not find host" means the name is not known. Ask the vendor to check the DNS record.

### Certificates {#access-web-tls}

The system has no certificate that your computer can trust (the "selfsigned" setting). The browser warns on every page, and again each time the gateway restarts. This is expected. To continue anyway:

- Chrome and Edge: click Advanced, then Proceed.
- Firefox: click Advanced, then Accept the Risk and Continue.
- Safari: click Show Details, then visit this website.

The warning is safe to pass only for the addresses in the table below. Recommended: a real certificate (the "custom" setting, or a private ACME server); see the known issues in this document.

### The pages {#access-web-pages}

Goal: know which pages exist, who can open them, and which entry of the credentials file holds the login.

| Address                                  | App              | Who can open it           | Login                       | Entry in the credentials file        |
|:-----------------------------------------|:-----------------|:--------------------------|:----------------------------|:-------------------------------------|
| <https://authelia.northwind.example.org/> | authelia | Anyone | The app's own login | 01 Web logins/Authelia |
| <https://portainer.northwind.example.org/> | portainer | Allowed addresses only | The app's own login | 01 Web logins/Portainer |
| <https://traefik.northwind.example.org/dashboard/> | traefik | Allowed addresses only | Admin login (Authelia) | 01 Web logins/Authelia |
| <https://uptimekuma.northwind.example.org/> | uptimekuma | Allowed addresses only | The app's own login | 01 Web logins/Uptime Kuma |
| <https://grafana.northwind.example.org/> | victoria | Allowed addresses only | The app's own login | 01 Web logins/Grafana |
| <https://alertmanager.northwind.example.org/> | victoria | Allowed addresses only | Admin login (Authelia) | 01 Web logins/Authelia |
| <https://metrics.northwind.example.org/vmui> | victoria | Allowed addresses only | Admin login (Authelia) | 01 Web logins/Authelia |
| <https://logs.northwind.example.org/select/vmui> | victoria | Allowed addresses only | Admin login (Authelia) | 01 Web logins/Authelia |

**What you should see:** the login page of the app, or the admin login first (Authelia).

**If it fails:** "403 Forbidden" means your internet address is not on the admin allow-list (see [Your internet address](#access-ip)). A page that never loads usually means a name problem (see [Check the name](#access-web-dns)).

### First login and 2FA {#access-web-2fa}

Goal: set up the second factor (2FA): a 6-digit code from an app on your phone, asked after the password. Do this during the handover session, with the vendor.

1. Install an authenticator app on your phone: Aegis, Google Authenticator or Microsoft Authenticator.
2. Log in at <https://authelia.northwind.example.org/> with the user and password from "01 Web logins/Authelia".
3. Choose to register a device. Authelia has no mail server: the operator reads the registration code on the first server:

```sh
ssh -t northwind-manager1 sudo cat /opt/ansibro/authelia/config/notification.txt
```

4. Scan the QR code with the authenticator app, and type the 6-digit code.

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

macOS (Terminal):

```sh
ssh -V
```

Linux (Terminal):

```sh
ssh -V
```

**What you should see:** a version, for example "OpenSSH_9.6".

**If it fails:** on Windows, install it from PowerShell opened as administrator: `Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0`. On Linux, install it with `sudo apt install openssh-client`. macOS always has it. Use OpenSSH, not PuTTY: PuTTY needs its own key format.

### Save your key {#access-ssh-key}

Goal: put the key that the vendor made for you in the right place. It is the attachment northwind_ed25519 of the entry "04 Infrastructure/SSH key (client)" in the credentials file. Save it under this name:

macOS and Linux (Terminal):

```sh
mkdir -p ~/.ssh
# save the attachment as ~/.ssh/northwind_ed25519, then:
chmod 600 ~/.ssh/northwind_ed25519
```

Windows (PowerShell):

```powershell
New-Item -ItemType Directory -Force "$env:USERPROFILE\.ssh"
# save the attachment as $env:USERPROFILE\.ssh\northwind_ed25519
```

**What you should see:** the file northwind_ed25519 in your .ssh folder.

**If it fails:** if the attachment is missing, ask the vendor.

### Add the SSH settings {#access-ssh-config}

Goal: give each server a short name, so `ssh northwind-manager1` is all you type. The file **ssh_config.txt** from the handover pack has the settings; add it to the end of your SSH settings file:

macOS and Linux (Terminal):

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
| `northwind-data1` | data1 | 203.0.113.21 | Direct |
| `northwind-data2` | data2 | 203.0.113.22 | Direct |
| `northwind-data3` | data3 | 203.0.113.23 | Direct |
| `northwind-manager1` | manager1 | 203.0.113.11 | Direct |
| `northwind-manager2` | manager2 | 203.0.113.12 | Direct |
| `northwind-manager3` | manager3 | 203.0.113.13 | Direct |
| `northwind-worker1` | worker1 | 203.0.113.31 | Direct |
| `northwind-worker2` | worker2 | 203.0.113.32 | Direct |
| `northwind-worker3` | worker3 | 203.0.113.33 | Direct |

Every name logs in as ubuntu on port 22, with the key ~/.ssh/northwind_ed25519.
On macOS you can add two lines under each `Host` line so the key passphrase is kept in the Keychain: `UseKeychain yes` and `AddKeysToAgent yes`.

**What you should see:** the `Host` lines at the end of the file.

**If it fails:** if you already had a `Host` with the same name, remove the old one.

### First connection {#access-ssh-first}

Goal: log in to the first server once and check that it is the real one.

macOS and Linux (Terminal):

```sh
ssh northwind-manager1
```

Windows (PowerShell):

```powershell
ssh northwind-manager1
```

The first time, SSH shows the server's fingerprint (a code starting with SHA256:) and asks to continue. Compare it with this table, then type `yes`. If they differ, type `no` and call the vendor.

| Server          | Host-key fingerprint                                                          |
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

**What you should see:** a prompt like `ubuntu@manager1:~$`. Type `exit` to leave. Commands for the system need `sudo` in front, because its files under /opt/ansibro belong to the administrator (root).

**If it fails:**

- "Permission denied (publickey)": your key is not on that server yet, or the key file name is wrong.
- "Connection timed out": your address is not in ssh.allow_from, or the provider's firewall blocks port 22.
- "UNPROTECTED PRIVATE KEY FILE": the key file is readable by others. Fix it:

macOS and Linux (Terminal):

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

Linux (Terminal):

```sh
ssh-add ~/.ssh/northwind_ed25519
```

On Windows, the first two lines need PowerShell opened as administrator.

**What you should see:** "Identity added".

**If it fails:** "Could not open a connection to your authentication agent" means the agent is not running: run the Windows lines as administrator.

## Databases and other services: an SSH tunnel {#access-tunnel}

The databases and similar services listen only inside the cluster, and their traffic is not encrypted. To reach them, you open an SSH tunnel: a private pipe through SSH from your laptop to the server. The tunnel also encrypts the traffic.

### Start the tunnel {#access-tunnel-start}

Goal: open all the pipes at once with the name `northwind-tunnel` from ssh_config.txt.

macOS and Linux (Terminal):

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
| S3 | data1 | 10.0.0.21:3900 | 127.0.0.1:13900 |
| S3 | data2 | 10.0.0.22:3900 | 127.0.0.1:13901 |
| S3 | data3 | 10.0.0.23:3900 | 127.0.0.1:13902 |
| PostgreSQL | data1 | 10.0.0.21:5432 | 127.0.0.1:15432 |
| PostgreSQL | data2 | 10.0.0.22:5432 | 127.0.0.1:15433 |
| PostgreSQL | data3 | 10.0.0.23:5432 | 127.0.0.1:15434 |
| Redis | data1 | 10.0.0.21:6379 | 127.0.0.1:16379 |
| Redis | data2 | 10.0.0.22:6379 | 127.0.0.1:16380 |
| Redis | data3 | 10.0.0.23:6379 | 127.0.0.1:16381 |

**What you should see:** nothing: no prompt, and the window stays open. That means the tunnel works.

**If it fails:** "Address already in use" or "port forwarding failed" means another program on your laptop uses that port. Close it, or change the first number of that `LocalForward` line in your SSH settings.
The servers talk to each other over WireGuard (an encrypted network between the servers only; your laptop cannot join it). SSH goes to the public address, and the tunnel reaches the WireGuard address; the settings already do this.

### Connect your tools {#access-tunnel-tools}

Goal: use the database or service through the tunnel. The passwords are in the group "02 Databases and cache" and "03 S3 storage" of the credentials file.

PostgreSQL *(not tested)*:

macOS and Linux (Terminal):

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

The main server (primary) can move between data1, data2, data3; this line tries each port and keeps the one that accepts changes.

Redis *(not tested)*:

macOS and Linux (Terminal):

```sh
redis-cli -h 127.0.0.1 -p 16379 --askpass
```

Windows (PowerShell):

```powershell
redis-cli -h 127.0.0.1 -p 16379 --askpass
```

With 3 servers, only the primary accepts changes, and it can move. Find it first; the answer is a server address from the table above, so use the laptop port of that line:

macOS and Linux (Terminal):

```sh
ssh northwind-data1 "sudo docker exec redis-sentinel redis-cli -p 26379 \
  sentinel get-master-addr-by-name ansibro"
```

Windows (PowerShell):

```powershell
ssh northwind-data1 ("sudo docker exec redis-sentinel redis-cli -p 26379 " +
  "sentinel get-master-addr-by-name ansibro")
```

Garage (S3 file storage). The access key starts with GK; the region is garage. Give the keys from "03 S3 storage/Garage S3" to `aws configure` first:

macOS and Linux (Terminal):

```sh
aws --endpoint-url http://127.0.0.1:13900 --region garage s3 ls
```

Windows (PowerShell):

```powershell
aws --endpoint-url http://127.0.0.1:13900 --region garage s3 ls
```

Programs with a window (DBeaver, TablePlus, RedisInsight, WinSCP, Cyberduck) work the same way: start the tunnel, then connect to host 127.0.0.1 and the laptop port. They can also make the tunnel themselves: in their SSH settings, use host 203.0.113.21, port 22, user ubuntu and your key file; then connect to the address "on the server" from the table.

**What you should see:** the tool connects and asks for the password, or shows the data.

**If it fails:** "connection refused" means the tunnel is not running. Start it again in its own window.

## Managing the cluster {#access-cluster}

### Docker Swarm {#access-cluster-swarm}

Goal: see and manage the running apps (services).

The easy way is the browser: Portainer at <https://portainer.northwind.example.org/>.

From the command line, on the first server:

macOS and Linux (Terminal):

```sh
ssh -t northwind-manager1 sudo docker service ls
```

Windows (PowerShell):

```powershell
ssh -t northwind-manager1 sudo docker service ls
```

**What you should see:** a list of services, each with "REPLICAS" like 1/1.

**If it fails:** see [SSH](#access-ssh). A remote Docker connection (`docker context create northwind --docker host=ssh://northwind-manager1`) only works if the SSH user may use Docker without sudo. ansibro does not set this up, and it gives full control of the server, so the vendor decides.

### Your own images {#access-cluster-images}

Goal: run your own app images. The image registry (registry.ansibro:5000) is reachable only from the servers, so you send the image over SSH and push it on the first server:

macOS and Linux (Terminal):

```sh
docker save app:1 | ssh northwind-manager1 "sudo docker load"
ssh northwind-manager1 "sudo docker tag app:1 registry.ansibro:5000/app:1 && \
  sudo docker push registry.ansibro:5000/app:1"
```

Windows (PowerShell):

```powershell
docker save app:1 | ssh northwind-manager1 "sudo docker load"
ssh northwind-manager1 ("sudo docker tag app:1 registry.ansibro:5000/app:1 && " +
  "sudo docker push registry.ansibro:5000/app:1")
```

`app:1` is your image name and version. On a Mac with Apple Silicon, build the image with `--platform linux/amd64`: the servers use Intel or AMD processors. The registry is not in the backup: after a restore, push your images again.

## Successor: running the installer {#access-successor}

This part is for the person who will change the system with ansibro (the installer) after the handover. It needs macOS or Linux; Windows is not supported (WSL2 is *not tested*). Always run the installer from this one computer.

1. Install git, Python 3.12 or newer, and age (`brew install age` on macOS, `sudo apt install age` on Ubuntu).
2. Get ansibro and switch to the version this system was built with (1.2.0):

```sh
git clone https://github.com/sgnd/ansibro.git
cd ansibro
git tag --list
```

   Then `git checkout` the tag of version 1.2.0.

3. Save the attachment ansibro-installer.tar.gz of the entry "06 Internal (re-run ansibro)/ansibro installer files" into that folder, then unpack it:

```sh
tar -xzf ansibro-installer.tar.gz
chmod 700 state
```

4. Optional: make a key to keep the installer's records encrypted (state.age):

```sh
mkdir -p ~/.config/ansibro && age-keygen -o ~/.config/ansibro/age.key
```

5. Run the installer, then the system test:

```sh
./install.sh config.yml
.venv/bin/python tests/check.py
```

**What you should see:** the installer ends without "failed", and the test shows PASS lines.

**If it fails:** the passwords in the attachment are the ones of the handover day. After a password change, put the new value into the matching file in state/secrets/ first, as this document explains.

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
| 01 Web logins | Authelia, Grafana, Portainer, Traefik, Uptime Kuma | everyone who manages the web pages |
| 02 Databases and cache | PostgreSQL, Redis | operators |
| 03 S3 storage | Garage S3 | operators |
| 04 Infrastructure | Image registry | operators |
| 05 Recovery (break-glass) | Backup (restic), config.yml backup.s3_access_key, config.yml backup.s3_secret_key, config.yml monitoring.webhook | keep safe; only to restore |
| 06 Internal (re-run ansibro) | 12 technical passwords, plus the file "ansibro installer files" (to run ansibro again) | only to run ansibro again |
| 07 Old (removed apps) | Swarmpit | nobody (left from removed apps) |

## Accounts {#credentials-accounts}

These are the accounts people use. The class says how to change the password (see the next section).

| Account | For | Entry in the credentials file | How to change | Deadline |
|:----------------|:-----------|:------------------------------|:----------------|:-----------|
| Authelia | daily use | `01 Web logins/Authelia` | App first | within 7 days |
| Garage S3 | daily use | `03 S3 storage/Garage S3` | File first | within 7 days |
| Grafana | daily use | `01 Web logins/Grafana` | App and file together (not tested) | within 7 days |
| Portainer | daily use | `01 Web logins/Portainer` | App first | within 7 days |
| PostgreSQL | daily use | `02 Databases and cache/PostgreSQL` | App and file together (not tested) | within 7 days |
| Redis | daily use | `02 Databases and cache/Redis` | File first | within 7 days |
| Image registry | recovery | `04 Infrastructure/Image registry` | App and file together | when the vendor's access ends |
| Backup (restic) | recovery | `05 Recovery (break-glass)/Backup (restic)` | App and file together | when the vendor's access ends |
| Traefik | daily use | `01 Web logins/Traefik` | File first | within 7 days |
| Uptime Kuma | daily use | `01 Web logins/Uptime Kuma` | App first | within 7 days |
| Passphrase of the credentials file | everyone | (the file itself) | KeePassXC | within 7 days |

## How to change a password {#credentials-change}

ansibro keeps a copy of every password in a folder called `state/` on the computer that runs the installer. It uses that copy each time it runs. So a password must be changed in the right place, or the next install undoes it or fails.

### File first {#credentials-file-first}

For: Garage S3, Redis, Traefik.
ansibro writes these passwords into the app every time it runs. A change made only in the app is undone at the next install.

1. On the installer computer, put the new password in the file `state/secrets/<name>`.
2. Run `./install.sh`.
3. Update the credentials file, and every app of yours that uses this password.

### App and file together {#credentials-both}

For: PostgreSQL, Image registry, Backup (restic), Grafana.
ansibro logs in with these passwords, or they are needed to restore. If only one place changes, the next install fails.

1. Change the password in the app.
2. At the same time, put the same password in `state/secrets/<name>` on the installer computer.
3. Run `./install.sh`, then the acceptance test (`tests/check.py`).
4. Update the credentials file.

- **Backup (restic):** run `sudo restic -r <repository> key passwd` on one server, then put the new password in `state/secrets/restic`, then run `./install.sh` (it rewrites `/opt/ansibro/backup/password` on every server). Keep the old password until the new one works: without it, old backups cannot be read.
- Grafana, PostgreSQL: how the app takes a new password was not tested, so treat them as "app and file together".

### App first {#credentials-app-first}

For: Authelia, Portainer, Uptime Kuma.
The app reads these passwords only the first time it starts. After that the app owns them.

1. Change the password in the app.
2. Put the same password in `state/secrets/<name>`, so the records and the acceptance test stay right.
3. Update the credentials file.

- **Authelia:** the file `users.yml` on manager1 is the true list of Authelia accounts.

### Do not change {#credentials-internal}

The passwords in the group "06 Internal (re-run ansibro)" are used only between programs. No person types them. Change them only if they leaked, and let the ansibro operator do it.

- **Garage:** editing the Garage key file adds a second key; the old key stays valid until it is deleted with the garage command.

> **Important:** ansibro's own summary file says "change them in the app, then update the file too". That is wrong for the classes "file first" and "app and file together". Follow this chapter instead.

## Your phone code (2FA) {#credentials-2fa}

The admin login asks for a password and a code from an *authenticator app* on a phone (*2FA*, two-factor login).
The vendor set this up during the work. Register your own phone:

1. Log in at <https://authelia.northwind.example.org/> with the Authelia account.
2. Choose to register a new device. Authelia has no mail server, so it writes the confirmation link to `/opt/ansibro/authelia/config/notification.txt` on manager1.
3. An operator reads that file over SSH and gives you the link.
4. Scan the code with your authenticator app.

## Who keeps state/ {#credentials-state}

**Northwind Logistics Ltd keeps `state/`.** The credentials file holds the attachment "ansibro installer files" (`config.yml` and every password file), so your own operator can run ansibro 1.2.0 again.

## Ending the vendor's access {#credentials-revoke}

Planned date: Friday, 4 December 2026. On that date:

1. Remove the vendor's SSH key from `~/.ssh/authorized_keys` of the user `ubuntu` on every server. ansibro does not manage SSH keys.
2. Remove the vendor's addresses from `ssh.allow_from` and `admin_allow_from` in `config.yml`, then run `./install.sh`.
3. Change the passwords as above.
4. Know that old values stay in `/opt/ansibro/backup/installer/state/secrets/` on manager1 and in older backups.
5. The vendor deletes its copy of `state/` when you agree it may.

## Changing the passphrase of the credentials file {#credentials-passphrase}

In KeePassXC: menu **Database → Database Security**, then set a new password. (In KeePass 2: **File → Change Master Key**.) Keep a backup copy of the file in a safe place.

## Adding a staff member {#credentials-staff}

- Add the person to Authelia's `users.yml` on manager1.
- Add their internet address to `admin_allow_from` (web pages) and `ssh.allow_from` (SSH, operators only) in `config.yml`, then run `./install.sh`.
- For operators: add their SSH public key to `~/.ssh/authorized_keys` of `ubuntu` on every server.

# Backup and restore {#backup}

A *backup* is a copy of the data kept somewhere else, so it can be put back (*restored*) after a loss.

## Settings {#backup-settings}

| Setting | Value |
|:--------------------|:---------------------------------------------------|
| Backup | On, with *restic* (a backup program) on every server |
| Where | s3: `https://s3.example.com/my-bucket` |
| When | Every night at 02:00 (UTC). A missed run starts at the next boot |
| Kept | 7 daily, 4 weekly and 6 monthly *snapshots* per server |
| Password | `05 Recovery (break-glass)/Backup (restic)` in the credentials file |

A *snapshot* is one complete backup at one moment.

## What is saved {#backup-what}

| App | How | Meaning |
|:-----------|:---------------------|:------------------------------------------------|
| Authelia | Copied while paused | the app is paused for a moment and its folder copied |
| Garage | Partly saved | only some folders are saved (see the app's notes) |
| Portainer | Copied while paused | the app is paused for a moment and its folder copied |
| PostgreSQL | Database dump | a full export of the databases |
| Redis | Copied while paused | the app is paused for a moment and its folder copied |
| Traefik | Copied while paused | the app is paused for a moment and its folder copied |
| Uptime Kuma | Copied while paused | the app is paused for a moment and its folder copied |
| Victoria monitoring | Partly saved | only some folders are saved (see the app's notes) |
| Image registry | Not saved | images are pulled again |
| etcd | Not saved | it is rebuilt |
| manager1 | Extra | the Swarm state, `config.yml` and the password files |

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

1. Make new, empty servers (Ubuntu 24.04 or 26.04) with **the same names and the same cluster IPs**; with WireGuard only the SSH address may change.
2. Keep the same `backup:` settings in `config.yml`, and the same `state/`.
3. Run:

   ```sh
   ./install.sh -e restore=true
   ```

4. Each server gets its newest snapshot back, then the apps start. Run `tests/check.py` to check.

**If `state/` is lost too,** get it back from the backup of manager1 first. You need the restic password and the storage credentials from the credentials file:

```sh
restic -r <repository> restore latest --host manager1 \
  --include /opt/ansibro/backup/stage/installer --target .
```

Not supported: restoring one app, one database, or an earlier point in time, and restoring onto a running cluster.

Last restore drill (a test restore): Monday, 2 November 2026.

# Monitoring and alerts {#monitoring}

*Monitoring* watches the servers and apps. An *alert* is a message sent when something is wrong.

## The monitoring system {#monitoring-tool}

The Victoria monitoring runs on data1. It keeps metrics and logs for 30 days.

| Page | Address |
|:----------------------|:-------------------------------------------------|
| Grafana (dashboards) | <https://grafana.northwind.example.org/> |
| Alertmanager (alerts, silences) | <https://alertmanager.northwind.example.org/> |
| Metrics | <https://metrics.northwind.example.org/vmui> |
| Logs | <https://logs.northwind.example.org/select/vmui> |

Alerts go to:
**slack** via `hooks.slack.com`.
Warnings and critical alerts go to the same place. An alert repeats every 4 hours while it lasts.

**Who watches the monitoring server?**
Uptime Kuma, on another server, checks that the monitoring server is alive.

**Silencing:** to stop an alert for a while (for example during planned work), open Alertmanager and create a *silence*.

## Alert rules {#monitoring-rules}

35 rules apply to this system. *Critical* means act now; *warning* means look soon. The alert texts arrive in English.

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

| Wireguard alerts | Level | What it means |
|:-------------------------|:---------|:------------------------------------------------|
| WireGuardPeerDown | critical | Two servers cannot talk over their encrypted link. |

## Uptime Kuma {#monitoring-uptimekuma}

Uptime Kuma at <https://uptimekuma.northwind.example.org/> checks every minute that the web pages answer. Its checks were made at the first install.

> **Important:** Uptime Kuma sends no notification until you add one in its Settings (email, Telegram and so on). Do this during the handover, and test it.

# Operations runbook {#runbook}

## Golden rules {#runbook-rules}

1. **Every change goes through `config.yml`,** then `./install.sh`. It changes only what differs, and it is safe to run again after a failure.
2. **Always run it from the computer that has `state/`.** Elsewhere it makes new passwords that do not match the running system.
3. `--check` (a dry run) is not supported.

**Who can run the installer:** a macOS or Linux computer with Python 3.12 or newer, ansibro 1.2.0, `config.yml` and `state/`. Today that is Northwind Logistics Ltd.

## Procedures {#runbook-procedures}

All commands on a server run after SSH (see [chapter 5](#access)). `/opt/ansibro` belongs to root, so they use `sudo`.

### Add or remove an app {#runbook-app}

- **Add:** add it under `apps:` in `config.yml`, then run `./install.sh`.
- **Remove:** remove it from `config.yml`, then run `./install.sh`. The app stops; its data stays in `/opt/ansibro/<app>` until you delete it with `sudo rm -rf`.
- **Check:** `tests/check.py`.

### Add or remove a server {#runbook-server}

- **Add:** add it to `nodes:` **after** manager1, then run `./install.sh`.
- **Remove:** move its apps away first, remove it from `config.yml`, then run:

  ```sh
  ./install.sh -e remove_nodes=true
  ```

- **Never remove manager1.**

### Promote or demote a server {#runbook-promote}

On manager1: `sudo docker node promote <name>` (worker to manager) or `sudo docker node demote <name>`.

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

- A cluster app: `sudo docker service update --force <stack>_<service>` on manager1. See the services with `sudo docker service ls`.
- An app on a fixed server: `cd /opt/ansibro/<app> && sudo docker compose restart` on that server.

### After a server restarts {#runbook-reboot}

- The apps start by themselves. A missed backup runs at boot.

### Locked out of SSH {#runbook-locked}

Open the server's console in the provider's web page, log in, and run `sudo ufw disable`. Then fix `ssh.allow_from` and run `./install.sh` (it turns the firewall back on).

### Docker Hub limit (toomanyrequests) {#runbook-dockerhub}

Wait, or log in to Docker Hub with `sudo docker login` on manager1.

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
- **Check:** `sudo docker service ps <service>` and `sudo docker service logs <stack>_<service>` on manager1.
- **Fix:** `sudo docker service update --force <stack>_<service>`.
- **Escalate:** when the copies do not come back.

### PostgresNoPrimary {#incident-postgres}

- **Means:** no PostgreSQL server accepts writes. Apps cannot save data.
- **Check:** `sudo docker exec postgres patronictl list` on a database server.
- **Fix:** make sure etcd runs on the managers and the database servers are up.
- **Escalate:** right away.

### CacheNoPrimary {#incident-cache}

- **Means:** no cache server accepts writes.
- **Check:** `sudo docker exec valkey-sentinel valkey-cli -p 26379 SENTINEL masters` (with Redis the names are `redis-sentinel` and `redis-cli`).
- **Fix:** start the stopped cache servers; Sentinel picks a new primary.
- **Escalate:** right away.

### BackupTooOld {#incident-backup}

- **Means:** a server has had no good backup for 26 hours.
- **Check:** `journalctl -u ansibro-backup` and `systemctl is-active ansibro-backup.timer` on that server.
- **Fix:** solve the error in the log, then run `sudo ansibro-backup`.
- **Escalate:** when the backup storage is unreachable or full.

### CertificateEndsSoon {#incident-cert}

- **Means:** a web certificate ends within 14 days.
- **Check:** the date in the browser's lock icon.
- **Fix:** replace the certificate and key files, then run `./install.sh`.
- **Escalate:** a week before it ends.

### WireGuardPeerDown {#incident-wireguard}

- **Means:** two servers cannot talk over WireGuard.
- **Check:** `sudo wg show` on both servers.
- **Fix:** check that UDP port 51820 is open between them and both are up.
- **Escalate:** when the link stays down.

## What ansibro does not do {#runbook-not}

| Task | Recommended owner |
|:------------------------------------|:------------------------------------------|
| Security updates of the operating system | Northwind Logistics Ltd's operator, or support |
| Upgrading ansibro itself | whoever keeps `state/` (Northwind Logistics Ltd) |
| Renewing the registry certificate (valid 10 years from the first install) | whoever keeps `state/` |
| Adding and removing SSH keys | Northwind Logistics Ltd's operator |

# Security {#security}

## What is open to the internet {#security-exposure}

These pages are open to anyone. Each has its own login, or is meant to be public:

- <https://authelia.northwind.example.org/>

Who can reach the rest:

- SSH: anyone (the list is empty).
- Admin pages: 198.51.100.0/24, 192.0.2.10.

## Traffic inside the cluster {#security-plaintext}

These services talk without encryption, so they are open only to the cluster servers: Garage, PostgreSQL, Redis.
WireGuard encrypts this traffic between the servers.
Inside the cluster, the monitoring ports (8428, 9428, 8880, 9093 and 3000) have no login.

## Copies of the passwords on the servers {#security-copies}

The servers hold copies of the passwords, readable by root only:

- `/opt/ansibro/backup/installer/state/secrets/` on manager1: **every password**, refreshed on each install, and inside every backup of manager1.
- `/opt/ansibro/backup/password` on every server: the backup password.
- `.env` files in `/opt/ansibro/<app>/` of the apps that use them.
- `/opt/ansibro/portainer/admin_password`.
- `/opt/ansibro/authelia/config/` (configuration, users and notifications).
- `/root/.docker/config.json` (the registry login).

So anyone with root on manager1, or with the backup password and storage, has every password.
On the installer computer, `state/` is **not encrypted**. Recommended: turn on ansibro's encryption (age).

## SSH keys {#security-ssh}

An *SSH key* is a pair of files that lets a person log in without a password. ansibro does not add or remove SSH keys. Who may log in is the list in `~/.ssh/authorized_keys` of `ubuntu` on each server; keep it short and remove keys of people who leave.

## Licenses to note {#security-agpl}

Garage, Redis, Victoria monitoring use the AGPL license (for Victoria: Grafana). Using them is free. If you change their code and offer it over a network, you must publish your changes. See [Appendix B](#appendix-licenses).

## Certificate dates {#security-certs}

| Certificate | Ends |
|:------------------------------|:------------------------------------------|
| Web pages (self-signed) | made again at each start |
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

| Item | Detail |
|:--------------------------|:---------------------------------------------|
| Date | 2026-11-04 |
| Passed | 9 |
| Failed | 0 |
| Skipped | 1 |

| Result | Check |
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

Each web page was also opened from outside on the same day:

| Address | DNS answer | Certificate ends | Status |
|:------------------------------------|:-------------------|:-------------|:-----------------|
| <https://traefik.northwind.example.org/dashboard/> | 203.0.113.11 | 2027-11-04 | 302 |
| <https://portainer.northwind.example.org/> | 203.0.113.11 | 2027-11-04 | 200 |
| <https://authelia.northwind.example.org/> | 203.0.113.11 | 2027-11-04 | 200 |
| <https://grafana.northwind.example.org/> | 203.0.113.11 | 2027-11-04 | 302 |
| <https://uptimekuma.northwind.example.org/> | 203.0.113.11 | 2027-11-04 | 302 |

HTTP status 200 means the page opened; 302, 401 or 403 means it asks for a login or the address is not on the allow-list. These are normal for admin pages.
The certificate is Traefik's own (self-signed), as described in [chapter 3](#servers-tls).

The handover certificate has a checklist for the handover session (its first attachment): every web page opens, every login works, 2FA is enrolled, the credentials file opens, laptop access works, a recent backup exists, a test alert arrives.

# Appendix A. Software versions {#appendix-versions .unnumbered}

| App | Image | Tag | Digest |
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

| Component | Version |
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
| dejavu | 1.1.0 |

The digest is the first 12 characters of the image's fingerprint (sha256). It pins the exact image.

# Appendix B. Licenses {#appendix-licenses .unnumbered}

All parts are open source.

| Part | License |
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

# Appendix C. Configuration {#appendix-config .unnumbered}

This is `config.yml` as ansibro read it, rebuilt by dejavu. The comments of the original are lost, some values are defaults, and each secret is replaced by its place in the credentials file.

```yaml
domain: northwind.example.org
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
  webhook: <kdbx: 05 Recovery (break-glass)/config.yml monitoring.webhook>
  keep_days: 30
backup:
  repository: s3:https://s3.example.com/my-bucket
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
# SSH settings for Northwind Logistics Ltd (northwind.example.org), made by dejavu 1.1.0.
# Add these lines to ~/.ssh/config (Windows: %USERPROFILE%\.ssh\config).
# The key file is your own key (or the one from the credentials file), never the vendor's.

Host northwind-data1
  HostName 203.0.113.21
  User ubuntu
  Port 22
  IdentityFile ~/.ssh/northwind_ed25519
  IdentitiesOnly yes

Host northwind-data2
  HostName 203.0.113.22
  User ubuntu
  Port 22
  IdentityFile ~/.ssh/northwind_ed25519
  IdentitiesOnly yes

Host northwind-data3
  HostName 203.0.113.23
  User ubuntu
  Port 22
  IdentityFile ~/.ssh/northwind_ed25519
  IdentitiesOnly yes

Host northwind-manager1
  HostName 203.0.113.11
  User ubuntu
  Port 22
  IdentityFile ~/.ssh/northwind_ed25519
  IdentitiesOnly yes

Host northwind-manager2
  HostName 203.0.113.12
  User ubuntu
  Port 22
  IdentityFile ~/.ssh/northwind_ed25519
  IdentitiesOnly yes

Host northwind-manager3
  HostName 203.0.113.13
  User ubuntu
  Port 22
  IdentityFile ~/.ssh/northwind_ed25519
  IdentitiesOnly yes

Host northwind-worker1
  HostName 203.0.113.31
  User ubuntu
  Port 22
  IdentityFile ~/.ssh/northwind_ed25519
  IdentitiesOnly yes

Host northwind-worker2
  HostName 203.0.113.32
  User ubuntu
  Port 22
  IdentityFile ~/.ssh/northwind_ed25519
  IdentitiesOnly yes

Host northwind-worker3
  HostName 203.0.113.33
  User ubuntu
  Port 22
  IdentityFile ~/.ssh/northwind_ed25519
  IdentitiesOnly yes

# A private pipe to the databases and other services: run "ssh -N northwind-tunnel" and keep it open.
# Then connect to 127.0.0.1 and the local port below.
Host northwind-tunnel
  HostName 203.0.113.21
  User ubuntu
  Port 22
  IdentityFile ~/.ssh/northwind_ed25519
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

# Appendix E. Password-change checklist {#appendix-passwords .unnumbered}

Tick each password when it is changed, within 7 days of the handover. [Chapter 6](#credentials) says how.

| Done | Account | Entry in the credentials file | Changed on | By |
|:----|:-------------------|:------------------------------|:-------------|:-------------|
| `☐` | Authelia | `01 Web logins/Authelia` | | |
| `☐` | Garage S3 | `03 S3 storage/Garage S3` | | |
| `☐` | Grafana | `01 Web logins/Grafana` | | |
| `☐` | Portainer | `01 Web logins/Portainer` | | |
| `☐` | PostgreSQL | `02 Databases and cache/PostgreSQL` | | |
| `☐` | Redis | `02 Databases and cache/Redis` | | |
| `☐` | Image registry | `04 Infrastructure/Image registry` | | |
| `☐` | Backup (restic) | `05 Recovery (break-glass)/Backup (restic)` | | |
| `☐` | Traefik | `01 Web logins/Traefik` | | |
| `☐` | Uptime Kuma | `01 Web logins/Uptime Kuma` | | |
| `☐` | Passphrase of the credentials file | | | |

# Appendix F. Known issues and recommendations {#appendix-issues .unnumbered}

- **A password of a removed app (`swarmpit_admin`).** It is kept in the group "07 Old (removed apps)" of the credentials file, so nothing is lost. It can be deleted when you agree.
- **The allow-list `ssh.allow_from` is empty.** SSH can be reached from any internet address. Recommended: list your office and staff addresses.
- **Self-signed certificate.** Browsers warn on every page. Recommended: a certificate from your company's certificate authority (`tls: custom`).
- **Uptime Kuma notifications.** They must be added by hand in Uptime Kuma's Settings, then tested.
- The client sets up the Uptime Kuma notifications after the handover.

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
| acceptance test | `tests/check.py`, run on 2026-11-04 |

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
| WireGuard | The encrypted network between the servers. |
