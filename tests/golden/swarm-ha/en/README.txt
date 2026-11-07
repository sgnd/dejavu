HANDOVER PACK: Produksi (nusa.example.co.id)
============================================

Client: PT Maju Bersama
Vendor: PT Nusantara Teknologi
Date:   Wednesday, 4 November 2026
Made with dejavu 1.1.0 from ansibro 1.2.0.

None of these files contains a password, except the credentials file, which
is encrypted. Its passphrase is never in this pack.

WHAT EACH FILE IS
-----------------

en/maju-handover-certificate.pdf
    The Handover and Acceptance Certificate, with Annex 1 (acceptance
    checklist), Annex 2 (accounts, names only) and Annex 3 (the files and
    their SHA-256 codes). Print and sign it.
en/maju-technical-documentation.pdf
    The full technical documentation of the system.
en/maju-laptop-guide-windows.pdf
    How to reach the system from a Windows laptop. For the client's staff.
en/maju-laptop-guide-macos.pdf
    How to reach the system from a macOS laptop. For the client's staff.
en/maju-laptop-guide-linux.pdf
    How to reach the system from a Linux laptop. For the client's staff.
en/*.md
    The same documents as text (Markdown), a record that any editor can open.
id/
    The same set in Indonesian. The Indonesian version prevails.
maju-kredensial.kdbx
    The credentials file: every password, encrypted. Open it with KeePassXC.
ssh_config.txt
    Ready-made SSH settings for the client's operators.
SHA256SUMS
    The SHA-256 code of every file, to check that nothing changed.
README.txt
    This file.

WHAT TO PRINT AND SIGN
----------------------

Print the Handover Certificate 2 (two) times. During the
handover session, go through Annex 1 together and initial each row. Then both
parties sign every copy, with a Rp10,000 stamp duty (meterai) on the
client's side. Each party keeps a signed copy.
For an electronic signature or e-meterai, upload the PDF itself.

DELIVERY ORDER
--------------

1. Before the session: send the laptop guides and ssh_config.txt to the
   client's staff. They contain no passwords.
2. Hand over the credentials file (maju-kredensial.kdbx)
   via: USB diserahkan langsung.
3. Give the passphrase on a DIFFERENT channel
   via: telepon
   to:  Siti Rahma.
   Never in the same email, chat or USB stick as the credentials file.
   The vendor reads it in their own terminal with: handover.py passphrase
4. The client checks the SHA-256 of the credentials file against Annex 3,
   opens it, and tests the access (Annex 1).
5. Both parties sign the Handover Certificate.
6. Afterwards the client changes every password within 7 days,
   and the passphrase of the credentials file.

CHECKING THE FILES
------------------

Linux:    sha256sum -c SHA256SUMS
macOS:    shasum -a 256 -c SHA256SUMS
Windows:  Get-FileHash <file> -Algorithm SHA256, then compare with SHA256SUMS
