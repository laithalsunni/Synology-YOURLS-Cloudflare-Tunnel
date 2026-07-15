
# YOURLS & Cloudflare Tunnel Multi-Tenant Deployer for Synology NAS 🚀

An automated, zero-config script to deploy isolated, multi-tenant instances of **YOURLS (Your Own URL Shortener)** backed by **MariaDB** and securely exposed via **Cloudflare Tunnels** directly on your Synology NAS.

No open ports. No reverse proxy head-scratching. Pure, automated convenience.

---

## ✨ Features

* 🛡️ **Zero Open Ports:** Leverages Cloudflare Tunnels to securely expose YOURLS without dynamic DNS or port forwarding.
* 📦 **Multi-Tenant Isolation:** Automatically partitions data, containers, and configurations per domain inside `/volume1/docker/yourls-[domain]`[cite: 1].
* 🔌 **Pre-Loaded Plugins:** Automatically bootstraps highly useful YOURLS plugins:
  * Sample QR Code (`qrcode`)[cite: 1]
  * Forward Slashes in URLs (`slashes`)[cite: 1]
  * Fallback URL (`fallback`)[cite: 1]
  * LogoSuite (`logosuite`)[cite: 1]
  * Import/Export (`import-export`)[cite: 1]
  * Additional Charsets (`additional-charsets`)[cite: 1]
  * Upload & Shorten Advanced (`Upload-and-Shorten-Advanced`)[cite: 1]
* 🔀 **Root Domain Redirect:** Instantly redirects root domain requests (e.g., `https://yourdomain.com/`) to the admin panel (`/admin`)[cite: 1].

---

## ⚡ One-Line Installation

Before running the installation, you will need a **Cloudflare Tunnel Token**. Follow these steps to generate one first:

### Step A: Create Your Cloudflare Tunnel & Retrieve the Token
1. Go to the [Cloudflare Zero Trust Dashboard](https://one.dash.cloudflare.com/) and log in.
2. On the left sidebar, navigate to **Networks** -> **Tunnels**.
3. Click **Add a tunnel**, select **Cloudflared**, and click **Next**.
4. Enter a **Tunnel name** (e.g., `synology-yourls`) and click **Save tunnel**.
5. Under **Install and run a connector**, select **Docker**.
6. Look at the command provided. Copy **only the long token string** shown at the end of the command after `--token`.
   * *Example command:* `docker run cloudflare/cloudflared:latest tunnel --no-autoupdate run --token <YOUR_TOKEN_HERE>`
7. **Save this token securely.** You will paste it into the script when prompted.

---

### Step B: Run the Installer
SSH into your Synology NAS as an administrator and execute the following single command:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/AlsunniNet/Synology-YOURLS-Cloudflare-Tunnel/main/setup_synology_yourls.sh)"

```

---

## 🛠️ Synology Container Manager Setup

Once the script completes, follow these simple steps to import and run your project inside the Synology NAS native **Container Manager** UI:

1. Open **Container Manager** on your Synology DSM.


2. Navigate to **Project** on the left menu and click **Create**.


3. Configure the Project settings:
* **Project Name:** `yourls-[your-domain-with-dashes]` (The script outputs this exact name at the end).


* **Path:** Choose **"Set path to an existing folder"** and select:
`/volume1/docker/yourls-[your-domain-with-dashes]` (or your chosen custom volume path).


* **Source:** Select **"Use existing docker-compose.yml"** (The script has already generated this for you in the folder).




4. Click **Next** -> **Next** -> **Done**.


5. Container Manager will read the configuration, pull the images, and boot up your isolated stack instantly!

---

## 🔒 Post-Installation & Cloudflare Config

1. Go back to your **Cloudflare Zero Trust Dashboard** -> **Networks** -> **Tunnels**.
2. Find the tunnel associated with the token you provided during setup and click **Edit**.
3. Under the **Public Hostname** tab, click **Add a public hostname**:
* **Subdomain/Domain:** Enter your YOURLS domain (e.g., `yourls.YourDomain.com`).
* **Service Type:** `HTTP`
* **URL:** `web-[your-domain-with-dashes]:8080` (The script outputs this exact target address).




4. Access your new YOURLS instance at: `https://[your-domain]/admin/`

```



```
