---
title: "Laptop Access Guide"
subtitle: "Windows · Production"
short-title: "Laptop Access Guide (Windows)"
lang: en
docnumber: "DOC-2026-001"
version: "1.0"
date: "Wednesday, 4 November 2026"
classification: "CONFIDENTIAL"
numbered: true
labels: {page: "Page", of: "of", toc: "Contents"}
cover:
  kicker: "LAPTOP ACCESS GUIDE"
  rows:
    - {label: "Client", value: "Northwind Logistics Ltd"}
    - {label: "Vendor", value: "Bluewave Systems Ltd"}
    - {label: "System", value: "Production (northwind.example.org)"}
    - {label: "Laptop", value: "Windows"}
    - {label: "Document number", value: "DOC-2026-001"}
    - {label: "Version", value: "1.0"}
    - {label: "Date", value: "Wednesday, 4 November 2026"}
    - {label: "Classification", value: "CONFIDENTIAL"}
  footer: "Made with dejavu 1.1.0 from ansibro 1.2.0. This guide contains no passwords; they are only in the encrypted credentials file."
---

# Access from your laptop (Windows) {#guide}

This guide shows how to reach Production (northwind.example.org) of Northwind Logistics Ltd from a Windows laptop: the web pages, the passwords and, for operators, the servers. It is part of the handover by Bluewave Systems Ltd. The technical documentation has the full details.

It is meant for: Tom Hughes.

You need these files from the handover pack: the credentials file, ssh_config.txt, and the passphrase, which is given to you separately.

## Who needs what {#access-who}

This part explains how to reach the system from your own computer, step by step. It is written for Windows. On Windows you type the commands in **PowerShell** (Start menu, type "PowerShell"). Each step says what you want to do, what to type, what you should see, and what to do if it fails.

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

On Windows you can also download the installer (MSI) from <https://keepassxc.org/download>. The winget package name is *(not tested)*.

On a phone, KeePassDX (Android), KeePassium or Strongbox (iPhone) can open the file to look things up.

**What you should see:** KeePassXC in your list of apps.

**If it fails:** on a company laptop you may not be allowed to install apps. Ask your IT team, or ask the vendor to install it during the handover session.

### Check the file {#access-kdbx-hash}

Goal: make sure the file you received is exactly the one listed in the Handover Certificate. Open PowerShell in the folder that holds the file, then type:

Windows (PowerShell):

```powershell
Get-FileHash .\northwind-credentials.kdbx -Algorithm SHA<size>
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

Keep a backup copy of the file on a USB stick in a safe place. After the handover, change the passphrase (Database, then Database Security) and change the passwords within 7 days, as the technical documentation explains.

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
| `ssh.allow_from`     | SSH, the login to the servers (port 22) | Empty: open to anyone |
| `admin_allow_from`   | The admin web pages                    | 198.51.100.0/24, 192.0.2.10 |

An empty list means the system is **open to anyone** on the internet for that list: the passwords are the only protection.
When a list is set, an address that is not on it gets "403 Forbidden" on the admin pages, or no answer (a timeout) on SSH. This also happens when your home address changes, behind a company proxy, or on a connection with only an IPv6 address.

**If it fails:** only the operator can add an address: they add it to the list in the installer's settings (config.yml) and run the installer again. Send your address to the vendor or your operator.

## Web pages {#access-web}

### Check the name {#access-web-dns}

Goal: make sure your computer finds the system's web pages under northwind.example.org.

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

The warning is safe to pass only for the addresses in the table below. Recommended: a real certificate (the "custom" setting, or a private ACME server); see the known issues in the technical documentation.

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

**What you should see:** a version, for example "OpenSSH_9.6".

**If it fails:** on Windows, install it from PowerShell opened as administrator: `Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0`. Use OpenSSH, not PuTTY: PuTTY needs its own key format.

### Save your key {#access-ssh-key}

Goal: put the key that the vendor made for you in the right place. It is the attachment northwind_ed25519 of the entry "04 Infrastructure/SSH key (client)" in the credentials file. Save it under this name:

Windows (PowerShell):

```powershell
New-Item -ItemType Directory -Force "$env:USERPROFILE\.ssh"
# save the attachment as $env:USERPROFILE\.ssh\northwind_ed25519
```

**What you should see:** the file northwind_ed25519 in your .ssh folder.

**If it fails:** if the attachment is missing, ask the vendor.

### Add the SSH settings {#access-ssh-config}

Goal: give each server a short name, so `ssh northwind-manager1` is all you type. The file **ssh_config.txt** from the handover pack has the settings; add it to the end of your SSH settings file:

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

**What you should see:** the `Host` lines at the end of the file.

**If it fails:** if you already had a `Host` with the same name, remove the old one.

### First connection {#access-ssh-first}

Goal: log in to the first server once and check that it is the real one.

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

On Windows, the first two lines need PowerShell opened as administrator.

**What you should see:** "Identity added".

**If it fails:** "Could not open a connection to your authentication agent" means the agent is not running: run the Windows lines as administrator.

## Databases and other services: an SSH tunnel {#access-tunnel}

The databases and similar services listen only inside the cluster, and their traffic is not encrypted. To reach them, you open an SSH tunnel: a private pipe through SSH from your laptop to the server. The tunnel also encrypts the traffic.

### Start the tunnel {#access-tunnel-start}

Goal: open all the pipes at once with the name `northwind-tunnel` from ssh_config.txt.

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

Windows (PowerShell):

```powershell
psql "host=127.0.0.1,127.0.0.1,127.0.0.1
      port=15432,15433,15434 user=postgres
      target_session_attrs=read-write"
```

The main server (primary) can move between data1, data2, data3; this line tries each port and keeps the one that accepts changes.

Redis *(not tested)*:

Windows (PowerShell):

```powershell
redis-cli -h 127.0.0.1 -p 16379 --askpass
```

With 3 servers, only the primary accepts changes, and it can move. Find it first; the answer is a server address from the table above, so use the laptop port of that line:

Windows (PowerShell):

```powershell
ssh northwind-data1 ("sudo docker exec redis-sentinel redis-cli -p 26379 " +
  "sentinel get-master-addr-by-name ansibro")
```

Garage (S3 file storage). The access key starts with GK; the region is garage. Give the keys from "03 S3 storage/Garage S3" to `aws configure` first:

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

Windows (PowerShell):

```powershell
ssh -t northwind-manager1 sudo docker service ls
```

**What you should see:** a list of services, each with "REPLICAS" like 1/1.

**If it fails:** see [SSH](#access-ssh). A remote Docker connection (`docker context create northwind --docker host=ssh://northwind-manager1`) only works if the SSH user may use Docker without sudo. ansibro does not set this up, and it gives full control of the server, so the vendor decides.

### Your own images {#access-cluster-images}

Goal: run your own app images. The image registry (registry.ansibro:5000) is reachable only from the servers, so you send the image over SSH and push it on the first server:

Windows (PowerShell):

```powershell
docker save app:1 | ssh northwind-manager1 "sudo docker load"
ssh northwind-manager1 ("sudo docker tag app:1 registry.ansibro:5000/app:1 && " +
  "sudo docker push registry.ansibro:5000/app:1")
```

`app:1` is your image name and version. The registry is not in the backup: after a restore, push your images again.

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

**If it fails:** the passwords in the attachment are the ones of the handover day. After a password change, put the new value into the matching file in state/secrets/ first, as the technical documentation explains.

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
