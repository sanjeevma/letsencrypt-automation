# Let's Encrypt SSL Automation

Automated SSL certificate installation and renewal for Ubuntu servers running Apache or Nginx.

## Features

- Automatic SSL certificate installation from Let's Encrypt
- Supports both Apache and Nginx web servers
- Auto-renewal via cron job (checks twice daily at 2:01 AM and 2:01 PM)
- Ubuntu version compatibility check
- Root privilege validation

## Requirements

- Ubuntu 16+ (tested on Ubuntu 18.04, 20.04, 22.04)
- Apache2 or Nginx web server
- Root access
- Domain pointing to server

## Installation

```bash
curl -O https://raw.githubusercontent.com/sanjeevma/letsencrypt-automation/master/scripts/letsencrypt-ssl-setup-apache-linux.sh
chmod +x letsencrypt-ssl-setup-apache-linux.sh
sudo ./letsencrypt-ssl-setup-apache-linux.sh
```

## What It Does

1. Validates system requirements (root access, Ubuntu OS)
2. Detects running web server (Apache/Nginx)
3. Installs certbot and required dependencies
4. Configures SSL certificates for your domains
5. Sets up automatic renewal cron job
6. Reloads web server configuration

## Auto-Renewal

Certificates automatically renew via cron job that:
- Runs twice daily (2:01 AM and 2:01 PM)
- Logs to `/var/log/letsencrypt/renew.log`
- Reloads web server on successful renewal

## Troubleshooting

**Permission denied**: Ensure you're running as root with `sudo`

**Unsupported OS**: Script only supports Ubuntu (Debian-based systems)

**No web server detected**: Install Apache2 or Nginx before running

**Certificate generation fails**: Verify domain DNS points to your server

## Known Issues

- Script has typos: `naginx` (line 82) and incorrect variable `$ID` (line 90) should be `$SERVER_VERSION`
- Apache renewal function used for both Apache and Nginx setup

## Contributing

Pull requests welcome. Please test on clean Ubuntu instances.

## License

MIT License

## Author

**Sanjeev Maharjan**
Email: me@sanjeev.au
