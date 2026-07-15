```bash
#!/bin/bash
set -e
clear

echo "=========================================================="
echo "    YOURLS & CLOUDFLARE TUNNEL MULTI-TENANT DEPLOY       "
echo "=========================================================="

# 1. Prompt the user for variables
read -p "Enter your Domain (e.g., ur.YourDomain.com): " DOMAIN

if [ -z "$DOMAIN" ]; then
    echo "❌ Error: Domain cannot be left blank."
    exit 1
fi

# Clean up domain format to strip protocol or trailing slashes
DOMAIN=$(echo "$DOMAIN" | sed -e 's|^[^/]*//||' -e 's|/.*||')

# Sanitize domain for safe Docker container and folder naming (replace dots with dashes)
SAFE_DOMAIN=$(echo "$DOMAIN" | tr '.' '-')
PROJECT_NAME="yourls-$SAFE_DOMAIN"

read -p "Enter Database Name [yourlsadmin]: " DB_NAME
DB_NAME=${DB_NAME:-yourlsadmin}
read -p "Enter Database User [yourlsadmin]: " DB_USER
DB_USER=${DB_USER:-yourlsadmin}
read -sp "Enter Database Password: " DB_PASS
echo ""
read -p "Enter YOURLS Admin Username [admin]: " ADMIN_USER
ADMIN_USER=${ADMIN_USER:-admin}
read -sp "Enter YOURLS Admin Password: " ADMIN_PASS
echo ""
read -p "Enter your Cloudflare Tunnel Token: " TUNNEL_TOKEN
echo -e "\n==========================================================\n"

# Validate remaining required variables
if [ -z "$DB_PASS" ] || [ -z "$ADMIN_USER" ] || [ -z "$ADMIN_PASS" ] || [ -z "$TUNNEL_TOKEN" ]; then
    echo "❌ Error: Required fields cannot be left blank."
    exit 1
fi

# 2. Define dynamic, domain-isolated directory structures (Synology clean paths)
BASE_DIR="/volume1/docker/$PROJECT_NAME"
YOURLS_DATA_DIR="$BASE_DIR/html-user"
DB_DATA_DIR="$BASE_DIR/mariadb"
PLUGINS_DIR="$YOURLS_DATA_DIR/plugins"

echo "📂 Creating clean isolated project directories at: $BASE_DIR"
mkdir -p "$YOURLS_DATA_DIR"
mkdir -p "$DB_DATA_DIR"
mkdir -p "$PLUGINS_DIR"

# 3. Clone the plugin stack using a secure shell fallback inside standard alpine
echo "📥 Downloading YOURLS plugins using temporary Docker helper..."
sudo docker run --rm \
  -v "$PLUGINS_DIR":/plugins \
  alpine:latest sh -c "
    apk add --no-cache git && cd /plugins
    git clone --depth 1 https://github.com/ozh/yourls-sample-qrcode.git qrcode || true
    git clone --depth 1 https://github.com/williambargentball/YOURLS-Forward-Slash-In-Urls.git slashes || true
    git clone --depth 1 https://github.com/ozh/yourls-fallback-url.git fallback || true
    git clone --depth 1 https://github.com/gioxx/YOURLS-LogoSuite.git logosuite || true
    git clone --depth 1 https://github.com/GautamGupta/YOURLS-Import-Export.git import-export || true
    git clone --depth 1 https://github.com/josheby/yourls-additional-charsets.git additional-charsets || true
    git clone --depth 1 https://github.com/master3395/YOURLS-Upload-and-Shorten-Advanced.git Upload-and-Shorten-Advanced || true
"

# 4. Create the Native Root Redirect to /admin inside the mounted volume
echo "🔀 Configuring automatic root redirect..."
cat << 'EOF' > "$YOURLS_DATA_DIR/theme.php"
<?php
// Automatic hook to redirect root domain traffic straight to the admin panel
if ( $_SERVER['REQUEST_URI'] == '/' ) {
    yourls_redirect( yourls_admin_url(), 301 );
    exit;
}
?>
EOF

# Standardize web server permissions for the directory
sudo chown -R 33:33 "$YOURLS_DATA_DIR"
sudo chmod -R 755 "$YOURLS_DATA_DIR"

# 5. Generate the domain-isolated docker-compose.yaml (Using standard filename for Synology)
echo "📝 Generating isolated Docker Compose configuration..."
cd "$BASE_DIR"

cat << EOF > docker-compose.yml
version: '3.8'

services:
  db:
    image: mariadb:11.4-noble
    container_name: db-$SAFE_DOMAIN
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: Asfec2024
      MYSQL_DATABASE: $DB_NAME
      MYSQL_USER: $DB_USER
      MYSQL_PASSWORD: $DB_PASS
    volumes:
      - $DB_DATA_DIR:/var/lib/mysql
    networks:
      - network-$SAFE_DOMAIN

  yourls:
    image: yourls:latest
    container_name: web-$SAFE_DOMAIN
    restart: always
    depends_on:
      - db
    expose:
      - "8080"
    environment:
      - YOURLS_SITE=https://$DOMAIN
      - YOURLS_USER=$ADMIN_USER
      - YOURLS_PASS=$ADMIN_PASS
      - YOURLS_DB_HOST=db-$SAFE_DOMAIN
      - YOURLS_DB_USER=$DB_USER
      - YOURLS_DB_PASS=$DB_PASS
      - YOURLS_DB_NAME=$DB_NAME
    volumes:
      - $YOURLS_DATA_DIR:/var/www/html/user
    networks:
      - network-$SAFE_DOMAIN

  tunnel:
    image: cloudflare/cloudflared:latest
    container_name: tunnel-$SAFE_DOMAIN
    restart: always
    command: tunnel --no-autoupdate run
    environment:
      - TUNNEL_TOKEN=$TUNNEL_TOKEN
    networks:
      - network-$SAFE_DOMAIN
    depends_on:
      - yourls

networks:
  network-$SAFE_DOMAIN:
    driver: bridge
EOF


echo "=========================================================="
echo "🎉 CONFIGURATION PREPARED FOR: $DOMAIN"
echo "📂 Project Directory Created: $BASE_DIR"
echo "=========================================================="
echo ""
echo "👉 FINAL STEP: CREATE THE PROJECT IN SYNOLOGY DSM 👈"
echo "1. Open 'Container Manager' inside your Synology NAS."
echo "2. Navigate to 'Project' (left sidebar) -> click 'Create'."
echo "3. Fill in the following details exactly:"
echo "   - Project Name:  $PROJECT_NAME"
echo "   - Path:          Choose 'Set path to an existing folder'"
echo "                    and select: $BASE_DIR"
echo "   - Source:        Select 'Use existing docker-compose.yml'"
echo "4. Click 'Next' -> 'Next' -> 'Done' to build and run the containers."
echo ""
echo "=========================================================="
echo "⚙️  Cloudflare Target Config: HTTP://web-$SAFE_DOMAIN:8080"
echo "🔗 Access URL (After setup): https://$DOMAIN/admin/"
echo "=========================================================="
