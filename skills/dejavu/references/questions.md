# The interview

Ask a few questions at a time, in plain words. Each question fills one field of `handover.yml`. Write `null` for "I don't know yet": the documents then say "not provided". Never ask for a password.

The documents are always in English. Write the answers in English too: they appear in the documents as they are.

Ask in this order. Skip a question when `handover.yml` already has the answer.

## 1. The documents

| Field | Ask | Default / example |
| --- | --- | --- |
| `environment` | What should the documents call this system? For example Production or Staging. | `Production` |
| `document.number` | The number of the technical document? | `DOC-2026-001` |
| `document.prepared_by`, `reviewed_by`, `approved_by` | Who prepared, reviewed and approved these documents? | names |

## 2. The handover certificate

| Field | Ask | Default / example |
| --- | --- | --- |
| `certificate.number` | The number of the handover certificate? | `HC-2026-001` |
| `certificate.date`, `certificate.place` | Date and place of the handover? | `2026-11-04`, `London` |
| `certificate.contract` | What is the basis of the work: the name, number and date of the contract, work order or purchase order? | |
| `certificate.stage` | Is this a single handover, a provisional one (work done, warranty starts), or the final one? | `single`; with `pho` also `fho_date` |
| `certificate.first_party` | Who is named and signs first: the vendor (handing over) or the client? | `vendor` |
| `certificate.copies` | How many printed copies? | `2` |
| `certificate.acknowledged_by`, `certificate.witnesses` | Does anyone acknowledge or witness it? Name, title, company. | `[]` |

## 3. The two parties

| Field | Ask |
| --- | --- |
| `client.name`, `client.short`, `client.address` | The client company's full name, a short name, and its address? |
| `client.signer` | Who signs for the client? Name and title. |
| `vendor.*` | The same for your company (the vendor): name, address, phone, email, website, signer. |
| `client.logo`, `vendor.logo` | Is there a logo file (PNG or SVG)? Where? |

## 4. The system

| Field | Ask | Notes |
| --- | --- | --- |
| `provider`, `servers.<name>.provider`, `.region` | Where do the servers run? For example DigitalOcean London, or on-premises. | |
| `servers.<name>.public_ip` | Does this server have a public IP? | Ask only for servers whose `host` is a private IP |
| `dns.mode` | How do people reach *.<domain>: normal DNS, company DNS, or no DNS yet? | `public`, `internal`, `hosts` |
| `dns.provider`, `dns.owner`, `dns.proxied` | Where is the domain managed, who owns it, and is there a CDN in front (like Cloudflare)? | |

## 5. People and access

| Field | Ask | Notes |
| --- | --- | --- |
| `people` | Which client staff need access? For each: name, role (web pages only / also SSH / will run ansibro), Windows, Mac or Linux laptop, and their internet IP. | persona `viewer`, `operator`, `successor`. Their IP: they open https://ifconfig.me |
| `ssh_handover` | Can the client make their own SSH key, or should we make one? | `client_key` (safest) or `generated` |
| `state_owner` | After the handover, who keeps the ansibro folder to change the system: the vendor or the client? | `vendor`. The client always gets a copy in the credentials file |

When a person's IP is outside an allow-list, the draft (`build --draft`) says so in the laptop section. Tell the user now. With their consent, add it with `allow ssh IP` (operators) or `allow admin IP` (everyone who opens the admin pages), then `./install.sh` (ask first). Never open `config.yml` yourself.

## 6. Delivery and after

| Field | Ask | Default |
| --- | --- | --- |
| `delivery.kdbx_channel` | How will the credentials file travel? For example a USB stick in person. | |
| `delivery.passphrase_channel`, `recipient` | Its passphrase travels another way, for example a phone call. To whom? | must differ from the file's channel |
| `password_change_days` | Within how many days does the client change every password? | `7` |
| `vendor_access_end` | When is the vendor's access (SSH key and IPs) removed? | a date |
| `restore_drill` | Was a restore from backup ever tested? When? | `null` = never |

## 7. Support and free text

| Field | Ask |
| --- | --- |
| `support.contacts`, `hours`, `sla` | Who does the client call when something is wrong, at what hours, and how fast is the response? |
| `support.warranty` | Is there a warranty? How many months, until when, covering what? |
| `out_of_scope` | Is anything not part of this work? |
| `extra_apps` | Does the client run their own apps on this cluster? |
| `summary_note`, `notes` | Anything else for the summary or the handover certificate? |
