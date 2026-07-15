
# YOURLS & Cloudflare Tunnel Multi-Tenant Deployer for Synology NAS 🚀

An automated, zero-config script to deploy isolated, multi-tenant instances of **YOURLS (Your Own URL Shortener)** backed by **MariaDB** and securely exposed via **Cloudflare Tunnels** directly on your Synology NAS.

No open ports. No reverse proxy head-scratching. Pure, automated convenience.

---

## ✨ Features

* 🛡️ **Zero Open Ports:** Leverages Cloudflare Tunnels to securely expose YOURLS without dynamic DNS or port forwarding.
* 📦 **Multi-Tenant Isolation:** Automatically partitions data, containers, and configurations per domain inside `/volume1/docker/yourls-[domain]`.
* 🔌 **Pre-Loaded Plugins:** Automatically bootstraps highly useful YOURLS plugins:
  * Sample QR Code (`qrcode`)
  * Forward Slashes in URLs (`slashes`)
  * Fallback URL (`fallback`)
  * LogoSuite (`logosuite`)
  * Import/Export (`import-export`)
  * Additional Charsets (`additional-charsets`)
  * Upload & Shorten Advanced (`Upload-and-Shorten-Advanced`)
* 🔀 **Root Domain Redirect:** Instantly redirects root domain requests (e.g., `https://yourdomain.com/`) to the admin panel (`/admin`).

---

## ⚡ One-Line Installation

SSH into your Synology NAS as an administrator and execute the following single command:

```bash
bash -c "$(curl -fsSL [https://raw.githubusercontent.com/AlsunniNet/Synology-YOURLS-Cloudflare-Tunnel/main/setup_synology_yourls.sh](https://raw.githubusercontent.com/AlsunniNet/Synology-YOURLS-Cloudflare-Tunnel/main/setup_synology_yourls.sh))"

```

---

## 🛠️ Synology Container Manager Setup

Once the script completes, follow these simple steps to import and run your project inside the Synology NAS native **Container Manager** UI:

1. Open **Container Manager** on your Synology DSM.
2. Navigate to **Project** on the left menu and click **Create**.
3. Configure the Project settings:
* **Project Name:** `yourls-[your-domain-with-dashes]` (The script outputs this exact name at the end).
* **Path:** Choose **"Set path to an existing folder"** and select:
`/volume1/docker/yourls-[your-domain-with-dashes]`
* **Source:** Select **"Use existing docker-compose.yml"** (The script has already generated this for you in the folder).


4. Click **Next** -> **Next** -> **Done**.
5. Container Manager will read the configuration, pull the images, and boot up your isolated stack instantly!

---

## 🔒 Post-Installation & Cloudflare Config

1. Log into your **Cloudflare Dashboard** -> **Zero Trust** -> **Networks** -> **Tunnels**.
2. Find the tunnel associated with the token you provided during setup.
3. Add a **Public Hostname** route:
* **Subdomain/Domain:** Enter your YOURLS domain (e.g., `qr.alsunninet.com`).
* **Type:** `HTTP`
* **URL:** `web-[your-domain-with-dashes]:8080` (The script outputs this exact target address).


4. Access your new YOURLS instance at: `https://your-domain.com/admin/

---
