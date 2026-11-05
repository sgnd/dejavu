---
title: "Laptop Access Guide"
subtitle: "Windows · Production"
short-title: "Laptop Access Guide (Windows)"
lang: en
docnumber: "001/DOK/NUSA/XI/2026"
version: "1.0"
date: "Wednesday, 4 November 2026"
classification: "CONFIDENTIAL"
numbered: true
labels: {page: "Page", of: "of", toc: "Contents"}
cover:
  kicker: "LAPTOP ACCESS GUIDE"
  rows:
    - {label: "Client", value: "PT Maju Bersama"}
    - {label: "Vendor", value: "PT Nusantara Teknologi"}
    - {label: "System", value: "Production (platform.example.com)"}
    - {label: "Laptop", value: "Windows"}
    - {label: "Document number", value: "001/DOK/NUSA/XI/2026"}
    - {label: "Version", value: "1.0"}
    - {label: "Date", value: "Wednesday, 4 November 2026"}
    - {label: "Classification", value: "CONFIDENTIAL"}
  footer: "Made with dejavu 1.0.0 from ansibro 1.2.0. This guide contains no passwords; they are only in the encrypted credentials file."
---

# Access from your laptop (Windows) {#guide}

This guide shows how to reach Production (platform.example.com) of PT Maju Bersama from a Windows laptop: the web pages, the passwords and, for operators, the servers. It is part of the handover by PT Nusantara Teknologi. The technical documentation has the full details.

It is meant for: Budi Santoso.

You need these files from the handover pack: the credentials file, ssh_config.txt, hosts.txt, and the passphrase, which is given to you separately.

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
