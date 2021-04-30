#!/bin/bash

CreateNewUserWitheCryptfs(){

	#install eCryptfs and mailutils
	apt-get install ecryptfs-utils cryptsetup dialog curl -y
	DEBIAN_FRONTEND=noninteractive apt-get -yq install mailutils

	fundialog=${fundialog=dialog}
	varusr=`$fundialog --stdout --no-cancel \
	--backtitle " Asignar el equipo a un usuario " \
	--title "    User Creation" \
	--inputbox "Ingresar Username: \n Example: Nombre.Apellido " 0 0`
	clear

	key='U29wb3J0ZV9EYWphcmFfZGVfaGFjZXJfU2NyaXB0c19TZWd1bl9Mb3NfSmVmZXNfU29wb3J0ZV9OT19EZXNhcnJvbGxhCg=='
    key=$(echo $key | base64 --decode)

    email='U2FsdGVkX1/lgH3Zdtkq0mPvDCV5IzlDjiU1+Q+sD2OQ72DYS0I/0BbVfyLhEfyP'
    email=$(echo $email | openssl enc -base64 -d -aes-256-cbc -pass pass:$key)

    passmail='U2FsdGVkX1/sxc2QwVel+MUlKCRAJXjNpC287KK3lqc='
    passmail=$(echo $passmail | openssl enc -base64 -d -aes-256-cbc -pass pass:$key)

	sed -i 's/relayhost =/#relayhost =/g' /etc/postfix/main.cf

cat << EOF >> /etc/postfix/main.cf
# Postfix as relay
#
relayhost = [smtp.gmail.com]:587
smtp_sasl_auth_enable = yes
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
smtp_sasl_security_options = noanonymous
smtp_tls_CAfile = /etc/postfix/cacert.pem
smtp_use_tls = yes
EOF
	
	echo "[smtp.gmail.com]:587 $email:$passmail" > sasl_passwd
	chown root:root sasl_passwd
	mv sasl_passwd /etc/postfix/
	postmap /etc/postfix/sasl_passwd
	chmod 0600 /etc/postfix/sasl_passwd /etc/postfix/sasl_passwd.db
	curl -LO# https://www.thawte.com/roots/thawte_Primary_Root_CA.pem
	chown root:root thawte_Primary_Root_CA.pem
	mv thawte_Primary_Root_CA.pem /etc/ssl/certs/thawte_Primary_Root_CA.pem
	cat /etc/ssl/certs/thawte_Primary_Root_CA.pem | sudo tee -a /etc/postfix/cacert.pem

	#adduser --force-badname $varusr
	passvarusr='RGVzcGVnYXIuY29tCg=='
	passvarusr=$(echo $passvarusr | base64 --decode)
	#adduser --force-badname --disabled-password --gecos "" $varusr
	adduser --encrypt-home --force-badname --disabled-password --gecos "" $varusr
	echo $varusr:passvarusr | sudo chpasswd
	adduser $varusr sudo
	idusr=$(id -u $varusr)
	#$passeCryptfs=$(su - $varusr -c "printf "%s" "$key" | ecryptfs-unwrap-passphrase /home/.ecryptfs/$varusr/.ecryptfs/wrapped-passphrase")
	#$passeCryptfs=$(sudo runuser -l $varusr -c "printf "%s" "$key" | ecryptfs-unwrap-passphrase /home/.ecryptfs/$varusr/.ecryptfs/wrapped-passphrase")
	#ecryptfs-unwrap-passphrase /home/.ecryptfs/$varusr/.ecryptfs/wrapped-passphrase $key > $TEMPDIR/passeCryptfs.txt
	#$passfile=$(sudo cat $TEMPDIR/passeCryptfs.txt)
	#rm -rf $TEMPDIR/passeCryptfs.txt

	passeCryptfs=$(ecryptfs-unwrap-passphrase /home/.ecryptfs/$varusr/.ecryptfs/wrapped-passphrase $key | tr -d '[[:space:]]')

	echo "Pass de encriptacion: $passeCryptfs" | mail -s "Ubuntu: Serial" soporte@despegar.com
	rm -rf /etc/postfix/sasl_passwd /etc/postfix/sasl_passwd.db
	apt-get --purge remove mailutils postfix -y 1>/dev/null
}

CreateNewUserWitheCryptfs
echo "Pass de encriptacion: " $passeCryptfs