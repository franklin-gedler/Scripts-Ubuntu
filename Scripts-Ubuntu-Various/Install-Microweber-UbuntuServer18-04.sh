#!/bin/bash

# Install microweber in Ubuntu server 18.04

add-apt-repository ppa:ondrej/php -y

apt-get update

apt-get install -y php7.4 php7.4-mysql php7.4-curl php7.4-json php7.4-cgi libapache2-mod-php7.4 php7.4-xmlrpc \
php7.4-gd php7.4-mbstring php7.4-common php7.4-soap php7.4-xml php7.4-intl php7.4-cli php7.4-ldap php7.4-zip \
php7.4-readline php7.4-imap php7.4-tidy unzip wget

# php7.0-mcrypt ---------- verificar por que no hay version para php7.4 ------------
# php7.0-recode ---------- verificar por que no hay version para php7.4 ------------
# php7.0-sq ---------- verificar por que no hay version para php7.4 ------------ 

cd /var/www/
wget http://deploy.microweberapi.com/deploy_files/release-zip/github.com/microweber/microweber.git/latest.zip
unzip latest.zip -d microweber
chown -R www-data:www-data microweber/
chmod -R 775 microweber/

cat > /etc/apache2/sites-available/microweber.conf << 'EOF'
<VirtualHost *:80> 
ServerName www.example.com
DocumentRoot /var/www/microweber/

<Directory /var/www/microweber/> 
AllowOverride All
Allow from all
</Directory> 

</VirtualHost> 
EOF

a2ensite microweber.conf
a2dissite 000-default.conf

# la salida del comando apache2ctl configtest debe ser Syntax OK
apache2ctl configtest

a2enmod rewrite
systemctl restart apache2