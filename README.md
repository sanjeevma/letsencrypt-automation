# SSL Auto-Installer

Automated SSL certificate installation and renewal for Ubuntu servers running Apache or Nginx.

## Features

- Automatic SSL certificate installation from Let's Encrypt
- Supports both Apache and Nginx web servers
- Auto-renewal via cron job (checks twice daily at 2:00 AM and 2:00 PM)
- Ubuntu version compatibility check
- Root privilege validation
- Comprehensive logging and error handling

## Requirements

- Ubuntu 18+ (tested on Ubuntu 18.04, 20.04, 22.04, 24.04)
- Apache2 or Nginx web server
- Root access
- Domain pointing to server

## Installation

```bash
curl -O https://raw.githubusercontent.com/yourusername/ssl-auto-installer/main/ssl-auto-installer.sh
chmod +x ssl-auto-installer.sh
sudo ./ssl-auto-installer.sh
```

## What It Does

1. Validates system requirements (root access, Ubuntu OS)
2. Detects running web server (Apache/Nginx)
3. Installs certbot and required dependencies
4. Configures SSL certificates for your domains
5. Sets up automatic renewal cron job
6. Tests renewal configuration
7. Reloads web server configuration

## Auto-Renewal

Certificates automatically renew via:
- **Cron schedule**: Twice daily at 2:00 AM and 2:00 PM
- **Script location**: `/etc/cron.daily/certbot-renewal`
- **Logs**: `/var/log/letsencrypt/renewal.log`
- **Auto-reload**: Web server reloads on successful renewal

## Manual Commands

```bash
# Test renewal (dry run)
certbot renew --dry-run

# List all certificates
certbot certificates

# Force renewal
certbot renew --force-renewal

# Check renewal logs
tail -f /var/log/letsencrypt/renewal.log
```

## Troubleshooting

**Permission denied**
```bash
sudo ./ssl-auto-installer.sh
```

**Unsupported OS**
- Script only supports Ubuntu
- For other distros, modify package manager commands

**No web server detected**
```bash
# Install Apache
sudo apt install apache2
sudo systemctl start apache2

# Or install Nginx
sudo apt install nginx
sudo systemctl start nginx
```

**Certificate generation fails**
- Verify domain DNS points to your server
- Ensure ports 80 and 443 are open
- Check domain accessibility: `curl -I http://yourdomain.com`

**Renewal fails**
- Check logs: `cat /var/log/letsencrypt/renewal.log`
- Test manually: `certbot renew --dry-run`
- Verify web server is running

## File Structure

```
/etc/cron.daily/certbot-renewal    # Auto-renewal script
/var/log/letsencrypt/renewal.log   # Renewal logs
/etc/letsencrypt/                  # Certificate storage
```

## Security Notes

- Certificates auto-renew 30 days before expiration
- Script validates root access for security
- Logs all renewal attempts for monitoring
- Uses official certbot packages only

## Contributing

1. Fork the repository
2. Create feature branch
3. Test on clean Ubuntu instance
4. Submit pull request

## Changelog

**v2.0** (September 2025)
- Fixed server detection logic
- Added comprehensive logging
- Improved error handling
- Added dry-run testing
- Enhanced cron setup

**v1.0** (January 2023)
- Initial release
- Basic Apache/Nginx support

## License

MIT License

## Author

**Sanjeev Maharjan**
Email: me@sanjeev.au
