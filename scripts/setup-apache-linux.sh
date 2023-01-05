
#!/bin/bash

# This code processes letsencrypt for ubuntu running on ubuntu
# Operations:
#   * it will install required library
#   * install ssl and also set cron job to renew it
# --------------------------------------------------------------------------------
# last edit:
#     Thurs 5 jan 2023
# -------------------------------------------------------------------------------
# notes:
#
# --------------------------------------------------------------------------------
# contributors:
#     Sanjeev:
#         name:       Sanjeev Maharjan
#         email:      me@sanjeev.au
# --------------------------------------------------------------------------------



function checkRoot() {
  if [ "$EUID" -ne 0 ]; then
    return 1
  fi
}

function checkOS() {
  if [[ -e /etc/debian_version ]]; then
    OS="debian"
    source /etc/os-release
    if [[ $ID == "ubuntu" ]]; then
      OS="ubuntu"
      MAJOR_UBUNTU_VERSION=$(echo "$VERSION_ID" | cut -d '.' -f1)
      if [[ $MAJOR_UBUNTU_VERSION -lt 16 ]]; then
        echo "⚠️ Your version of Ubuntu is not supported."
        echo ""
        echo "However, you can try it "
        echo ""
        until [[ $CONTINUE =~ (y|n) ]]; do
          read -rp "Continue? [y/n]: " -e CONTINUE
        done
        if [[ $CONTINUE == "n" ]]; then
          exit 1
        fi
      fi
    else
      echo "we only support ubuntu at the moment"
      exit 1
    fi
  else
    echo "Looks like you aren't running this installer on a Ubuntu"
    exit 1
  fi
}
function initialCheck() {
  if ! checkRoot; then
    echo "Sorry, you need to run this as root"
    exit 1
  fi
  checkOS
}

function setAutoRenewApache(){
  echo "Setting up Apache auto renewal"
  echo "#!/bin/sh
if certbot renew > /var/log/letsencrypt/renew.log 2>&1 ; then
  /etc/init.d/apache2 reload >> /var/log/letsencrypt/renew.log
fi
exit" >/etc/cron.daily/certbot-renewal-script

  sudo chmod +x /etc/cron.daily/certbot-renewal-script
  #write out current crontab
  crontab -l > tmpcron
  #echo new cron into cron file
  echo "01 02,14 * * * /etc/cron.daily/certbot-renewal-script" >> tmpcron
  #install new cron file
  crontab tmpcron
  rm tmpcron

}



function setApache(){
  echo "Setting up the thing for apache "
  if systemctl is-active -q nginx; then
    echo ""
    echo "Nginx s running and active"
  else
    echo "restarting the Nginx "
    systemctl reload nginx
  fi

  echo "Disabling default conf if present"
  apt-get -y install certbot python3-certbot-nginx

  echo "Welcome to the lets-encrypt installer!"
	echo ""

  sudo certbot --nginx

  ## Setting up auto renewal
  setAutoRenewApache
}

function setAutoRenewNginx(){
  echo "Setting up Apache auto renewal"
  echo "#!/bin/sh
if certbot renew > /var/log/letsencrypt/renew.log 2>&1 ; then
  /etc/init.d/naginx reload >> /var/log/letsencrypt/renew.log
fi
exit" >/etc/cron.daily/certbot-renewal-script
  sudo chmod +x /etc/cron.daily/certbot-renewal-script
  crontab -l > tmpcron
  echo "01 02,14 * * * /etc/cron.daily/certbot-renewal-script" >> tmpcron
  crontab tmpcron
  rm tmpcron

}

function setNginx(){
  echo "Setting up the thing for nginx "
  setAutoRenewNginx
}
function setupUbuntu(){
  apt update -y
  { pgrep nginx && SERVER_VERSION="nginx"; } || { pgrep apache  && SERVER_VERSION="apache"; } || SERVER_VERSION="unknown"
  if [[ $SERVER_VERSION == "apache" ]]; then
    setApache
  elif [[ $ID == "nginx" ]]; then
    setNginx
  else
    echo "This isntaller only supports nginx and apache2"
    exit 1
  fi

}

function intiialSetup(){
  if [[ $ID == "ubuntu" ]]; then
    setupUbuntu
  else
    echo "This isntaller only works on Ubuntu"
    exit 1
  fi
}
# check user and OS
initialCheck
intiialSetup

