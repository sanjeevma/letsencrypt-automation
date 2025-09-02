#!/bin/bash
# Let's Encrypt SSL installer with auto-renewal for Ubuntu
# Supports Apache2 and Nginx with automatic cron job setup
# --------------------------------------------------------------------------------
# Last updated: September 2025
# --------------------------------------------------------------------------------

function checkRoot() {
  if [ "$EUID" -ne 0 ]; then
    return 1
  fi
}

function checkOS() {
  if [[ -e /etc/debian_version ]]; then
    source /etc/os-release
    if [[ $ID == "ubuntu" ]]; then
      MAJOR_UBUNTU_VERSION=$(echo "$VERSION_ID" | cut -d '.' -f1)
      if [[ $MAJOR_UBUNTU_VERSION -lt 18 ]]; then
        echo "⚠️  Ubuntu version $VERSION_ID may not be fully supported."
        echo "Recommended: Ubuntu 18.04 or newer"
        until [[ $CONTINUE =~ (y|n) ]]; do
          read -rp "Continue anyway? [y/n]: " -e CONTINUE
        done
        if [[ $CONTINUE == "n" ]]; then
          exit 1
        fi
      fi
    else
      echo "❌ This installer only supports Ubuntu"
      exit 1
    fi
  else
    echo "❌ This installer requires Ubuntu"
    exit 1
  fi
}

function initialCheck() {
  if ! checkRoot; then
    echo "❌ This script must be run as root"
    echo "Try: sudo $0"
    exit 1
  fi
  checkOS
}

function detectWebServer() {
  if systemctl is-active --quiet apache2; then
    SERVER="apache2"
  elif systemctl is-active --quiet nginx; then
    SERVER="nginx"
  elif which apache2 >/dev/null 2>&1; then
    SERVER="apache2"
  elif which nginx >/dev/null 2>&1; then
    SERVER="nginx"
  else
    echo "❌ No supported web server found (Apache2 or Nginx required)"
    exit 1
  fi
  echo "✅ Detected web server: $SERVER"
}

function installCertbot() {
  echo "📦 Installing Certbot..."
  apt update -y

  if [[ $SERVER == "apache2" ]]; then
    apt install -y certbot python3-certbot-apache
  else
    apt install -y certbot python3-certbot-nginx
  fi
}

function setupSSL() {
  echo "🔐 Setting up SSL certificate..."
  echo "This will automatically configure SSL for your domains"

  if [[ $SERVER == "apache2" ]]; then
    certbot --apache
  else
    certbot --nginx
  fi
}

function setupAutoRenewal() {
  echo "⏰ Setting up automatic renewal..."

  # Create renewal script
  cat > /etc/cron.daily/certbot-renewal << 'EOF'
#!/bin/bash
# Auto-renewal script for Let's Encrypt certificates

LOG_FILE="/var/log/letsencrypt/renewal.log"
DATE=$(date)

echo "[$DATE] Starting certificate renewal check..." >> $LOG_FILE

if certbot renew --quiet --no-self-upgrade >> $LOG_FILE 2>&1; then
    echo "[$DATE] Certificate renewal successful" >> $LOG_FILE

    # Reload web server
    if systemctl is-active --quiet apache2; then
        systemctl reload apache2 >> $LOG_FILE 2>&1
        echo "[$DATE] Apache2 reloaded" >> $LOG_FILE
    elif systemctl is-active --quiet nginx; then
        systemctl reload nginx >> $LOG_FILE 2>&1
        echo "[$DATE] Nginx reloaded" >> $LOG_FILE
    fi
else
    echo "[$DATE] Certificate renewal failed" >> $LOG_FILE
fi
EOF

  chmod +x /etc/cron.daily/certbot-renewal

  # Add crontab entry for twice-daily checks
  (crontab -l 2>/dev/null; echo "0 2,14 * * * /etc/cron.daily/certbot-renewal") | crontab -

  echo "✅ Auto-renewal configured:"
  echo "   • Daily script: /etc/cron.daily/certbot-renewal"
  echo "   • Cron schedule: 2:00 AM and 2:00 PM daily"
  echo "   • Logs: /var/log/letsencrypt/renewal.log"
}

function testRenewal() {
  echo "🧪 Testing auto-renewal setup..."

  # Create log directory if it doesn't exist
  mkdir -p /var/log/letsencrypt

  # Test renewal (dry run)
  if certbot renew --dry-run; then
    echo "✅ Auto-renewal test passed"
  else
    echo "⚠️  Auto-renewal test failed - check configuration"
  fi
}

function showStatus() {
  echo ""
  echo "🎉 Installation complete!"
  echo ""
  echo "📋 Summary:"
  echo "   • Web server: $SERVER"
  echo "   • SSL certificates installed and configured"
  echo "   • Auto-renewal: Enabled (runs twice daily)"
  echo "   • Renewal logs: /var/log/letsencrypt/renewal.log"
  echo ""
  echo "🔧 Manual commands:"
  echo "   • Test renewal: certbot renew --dry-run"
  echo "   • List certificates: certbot certificates"
  echo "   • Check renewal status: systemctl status certbot.timer"
  echo ""
}

# Main execution
echo "🚀 Let's Encrypt SSL Auto-Installer"
echo "=================================="

initialCheck
detectWebServer
installCertbot
setupSSL
setupAutoRenewal
testRenewal
showStatus

echo "✨ Your SSL certificates are now installed and will auto-renew!"
