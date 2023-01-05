# letsencrypt-automation
_This is a bash script to setup letsencrypt ssl to ubuntu server in either nginx or apache2_

## OpenVPN installer for Ubuntu

# Usage
```
curl -O https://raw.githubusercontent.com/sanjeevma/letsencrypt-automation/master/scripts/letsencrypt-ssl-setup-apache-linux
chmod +x letsencrypt-ssl-setup-apache-linux
```

then execute the script
```
./letsencrypt-ssl-setup-apache-linux
```

## Features
- installs ssl from let'sencrypt for domains and do required configs
- setup cronjob to auto renew ssl for desired domain
