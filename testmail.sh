#!/bin/bash

sendmaileCryptfs(){
	#Descargo mailutils no interactivo
	DEBIAN_FRONTEND=noninteractive apt-get -yq install mailutils
	while [[ $? != 0 ]]; do
		DEBIAN_FRONTEND=noninteractive apt-get -yq install mailutils
	done

	key='U29wb3J0ZV9EYWphcmFfZGVfaGFjZXJfU2NyaXB0c19TZWd1bl9Mb3NfSmVmZXNfU29wb3J0ZV9OT19EZXNhcnJvbGxhCg=='
    key=$(echo $key | base64 --decode)

    #email='U2FsdGVkX18AYUBhia6pcCWiX7NjfoN0iQf4dbiQpAIU4pYZO/mOwErDqMleSmVl'
    email='U2FsdGVkX1+MVxqChm9TD5JrVvv9lCrpNnCa9LVFss/GAwtlBynCgpW2FfIPPaU7'
    email=$(echo $email | openssl enc -base64 -d -aes-256-cbc -pass pass:$key)

    #passmail='U2FsdGVkX1/+ag855k4X0b5jhEi2J1s4kADKmYS3ris='
    passmail='U2FsdGVkX18RHiTqaqmVJsfAmZMxWdgovyAiRsB7a6M='
    passmail=$(echo $passmail | openssl enc -base64 -d -aes-256-cbc -pass pass:$key)

	mail_receptor='soporte@despegar.com'

	sed -i 's/relayhost =/#relayhost =/g' /etc/postfix/main.cf

cat << EOF >> /etc/postfix/main.cf
# Postfix as relay
#
#relayhost = [smtp.gmail.com]:587
relayhost = [mail.despegar.com]:25
smtp_sasl_auth_enable = yes
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
smtp_sasl_security_options = noanonymous
smtp_tls_CAfile = /etc/postfix/cacert.pem
smtp_use_tls = yes
EOF
	
	#echo "[smtp.gmail.com]:587 $email:$passmail" > sasl_passwd
    echo "[mail.despegar.com]:25 $email:$passmail" > sasl_passwd
	chown root:root sasl_passwd
	mv sasl_passwd /etc/postfix/
	postmap /etc/postfix/sasl_passwd
	chmod 0600 /etc/postfix/sasl_passwd /etc/postfix/sasl_passwd.db
	curl -LO# https://www.thawte.com/roots/thawte_Primary_Root_CA.pem
	chown root:root thawte_Primary_Root_CA.pem
	mv thawte_Primary_Root_CA.pem /etc/ssl/certs/thawte_Primary_Root_CA.pem
	cat /etc/ssl/certs/thawte_Primary_Root_CA.pem | sudo tee -a /etc/postfix/cacert.pem

	echo "Pass de encriptacion: $passeCryptfs" | mail -s "Ubuntu: $varserial" -a "From: $email" $mail_receptor
	#rm -rf /etc/postfix/sasl_passwd /etc/postfix/sasl_passwd.db
	#apt-get --purge remove mailutils postfix -y 1>/dev/null
}

sendmaileCryptfs