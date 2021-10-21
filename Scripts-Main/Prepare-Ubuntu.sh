#!/bin/bash

#PrepareUbuntu

CheckInstall(){
	varadm=$(who | awk 'FNR == 1 {print $1}' | tr -d '[[:space:]]')
	idioma=$(/usr/bin/locale | grep -o ":es")
	if [[ "$idioma" = ":es" ]]; then
		escri="Escritorio"
	else
		escri="Desktop"
	fi
}

NewNameCompu(){
	varhostname=$(hostname)
	varserial=$(/usr/sbin/dmidecode -s system-serial-number)
	varnewhostname=AR$varserial
	/usr/bin/nmcli general hostname $varnewhostname
	sed -i "s/$varhostname/$varnewhostname/g" /etc/hosts
	#finalname=$(hostname)
	echo "Nombre del equipo Seteado: $(hostname)" > /home/$varadm/$escri/CheckInstall.txt
}

CreateNewUserWitheCryptfs(){

	varusr=$(yad --entry \
            	--center \
            	--width=350 \
            	--skip-taskbar \
            	--on-top \
            	--title="Añadir Usuario" --image=add --button=Añadir:0)
	
	while [[ -z $varusr ]]; do
		varusr=$(yad --entry \
					--center \
					--width=350 \
					--skip-taskbar \
					--on-top \
					--title="Añadir Usuario" --image=add --button=Añadir:0)
	done

	varusr=$(echo "$varusr" | tr -d '[[:space:]]')

	apt-get install ecryptfs-utils cryptsetup -y
	while [[ $? != 0 ]]; do
		apt-get install ecryptfs-utils cryptsetup -y
	done

	#fundialog=${fundialog=dialog}
	#varusr=`$fundialog --stdout --no-cancel \
	#--backtitle " Asignar el equipo a un usuario " \
	#--title "    User Creation" \
	#--inputbox "Ingresar Username: \n Example: Nombre.Apellido " 0 0`
	#clear
	
	#adduser --force-badname $varusr
	passvarusr='RGVzcGVnYXIuY29tCg=='
	passvarusr=$(echo $passvarusr | base64 --decode)
	#adduser --force-badname --disabled-password --gecos "" $varusr
	adduser --encrypt-home --force-badname --disabled-password --gecos "" $varusr
	echo $varusr:$passvarusr | sudo chpasswd
	adduser $varusr sudo
	#varusr=$(who > /tmp/varusr && awk -F: '{ print $1 }' /tmp/varusr | tr -d '[[:space:]]')
	#varusr=$(who | awk 'FNR == 1 {print $1}' | tr -d '[[:space:]]')
	idusr=$(id -u $varusr)
	passeCryptfs=$(ecryptfs-unwrap-passphrase /home/.ecryptfs/$varusr/.ecryptfs/wrapped-passphrase $passvarusr | tr -d '[[:space:]]')
	sendmaileCryptfs
	echo "Usuario creado y agregado al grupo sudo: $varusr" >> /home/$varadm/$escri/CheckInstall.txt
}

sendmaileCryptfs(){
	#Descargo mailutils no interactivo
	DEBIAN_FRONTEND=noninteractive apt-get -yq install mailutils
	while [[ $? != 0 ]]; do
		DEBIAN_FRONTEND=noninteractive apt-get -yq install mailutils
	done

	key='U29wb3J0ZV9EYWphcmFfZGVfaGFjZXJfU2NyaXB0c19TZWd1bl9Mb3NfSmVmZXNfU29wb3J0ZV9OT19EZXNhcnJvbGxhCg=='
    key=$(echo $key | base64 --decode)

    #email='U2FsdGVkX18AYUBhia6pcCWiX7NjfoN0iQf4dbiQpAIU4pYZO/mOwErDqMleSmVl'   # Para gmail
    email='U2FsdGVkX1+MVxqChm9TD5JrVvv9lCrpNnCa9LVFss/GAwtlBynCgpW2FfIPPaU7'
	email=$(echo $email | openssl enc -base64 -d -aes-256-cbc -pass pass:$key)

    #passmail='U2FsdGVkX1/+ag855k4X0b5jhEi2J1s4kADKmYS3ris='    # Para gmail
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
	
	#echo "[smtp.gmail.com]:587 $email:$passmail" > sasl_passwd   # Para gmail
	echo "[mail.despegar.com]:25 $email:$passmail" > sasl_passwd
	chown root:root sasl_passwd
	mv sasl_passwd /etc/postfix/
	postmap /etc/postfix/sasl_passwd
	chmod 0600 /etc/postfix/sasl_passwd /etc/postfix/sasl_passwd.db
	curl -LO# https://www.thawte.com/roots/thawte_Primary_Root_CA.pem
	chown root:root thawte_Primary_Root_CA.pem
	mv thawte_Primary_Root_CA.pem /etc/ssl/certs/thawte_Primary_Root_CA.pem
	cat /etc/ssl/certs/thawte_Primary_Root_CA.pem | sudo tee -a /etc/postfix/cacert.pem

	#echo "Pass de encriptacion: $passeCryptfs" | mail -s "Ubuntu: $varserial" soporte@despegar.com  # Para gmail
	echo "Pass de encriptacion: $passeCryptfs" | mail -s "Ubuntu: $varserial" -a "From: $email" $mail_receptor

	#rm -rf /etc/postfix/sasl_passwd /etc/postfix/sasl_passwd.db
	#apt-get --purge remove mailutils postfix -y 1>/dev/null
}

wantcreateuser(){

	yad --center \
		--width=300 \
		--skip-taskbar \
		--on-top \
		--title="Question, Please Answer" \
		--text-align=center \
		--text="¿Desea Crear un Usuario?" \
		--image=dialog-question \
		--button=Si:0 \
		--button=No:1
	response=$?

	while [[ $response -gt 1 ]]; do
		yad --center \
			--width=300 \
			--skip-taskbar \
			--on-top \
			--title="Question, Please Answer" \
			--text-align=center \
			--text="¿Desea Crear un Usuario?" \
			--image=dialog-question \
			--button=Si:0 \
			--button=No:1
		response=$?
	done

	case $response in
		0)
		CreateNewUserWitheCryptfs
		;;
		1)
		echo " No creamos el usuario, Seguimos . . . "
		;;
	esac

   #dialog --backtitle " Question, Please Answer " \
   #--title " Seleccione Si o No " \
   #--yesno " ¿Quieres crear un usuario? " 0 0

   # Get exit status
   # 0 means user hit [yes] button.
   # 1 means user hit [no] button.
   # 255 means user hit [Esc] key.

   #response=$?
   #case $response in
   #   0) 
   #   clear
	#  CreateNewUserWitheCryptfs
    #  ;;
    #  1) 
    #  clear
    #  echo " No creamos el usuario, Seguimos . . . "
    #  ;;
    #  255) 
    #  clear
    #  echo " [ESC] key pressed. "
    #  ;;
   #esac

}

InstallChrome(){
	wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
	gdebi -n google-chrome-stable_current_amd64.deb
	checkchrome=$(dpkg -L google-chrome-stable)
	if [[ $? -ne 0 ]]; then
		echo "Google Chrome NO instalado" >> /home/$varadm/$escri/CheckInstall.txt
	else
		echo "Google Chrome Instalado" >> /home/$varadm/$escri/CheckInstall.txt
	fi
}

ChangePass(){
	echo "$varadm:*+54#$varserial*" | sudo chpasswd
	if [[ $? -ne 0 ]]; then
		echo "Password de $varadm no seteada" >> /home/$varadm/$escri/CheckInstall.txt
	else
		echo "New Password de $varadm: *+54#$varserial*" >> /home/$varadm/$escri/CheckInstall.txt
	fi
}

Glpi(){
	ping -c1 glpi.despegar.it &>/dev/null
	while [[ $? -ne 0 ]]; do
	echo ""
	echo "-----------------------------------------------------------------------------------------------"
	echo "|* Problemas para conectar al Server Glpi, verificar si estas conectado a la RED de Despegar *|"
	echo "      Si estas desde casa abre otra terminal SIN CERRAR ESTA y conectate a la VPN Regional     "
	echo "-----------------------------------------------------------------------------------------------"
	read -n 1 -s -r -p "*** Persione cualquier tecla para continuar ***"
	ping -c1 glpi.despegar.it &>/dev/null
	echo ""
	done

	apt-get install -y dmidecode hwdata ucf hdparm perl libuniversal-require-perl libwww-perl libparse-edid-perl \
	libproc-daemon-perl libfile-which-perl libhttp-daemon-perl libxml-treepp-perl libyaml-perl libnet-cups-perl libnet-ip-perl \
	libdigest-sha-perl libsocket-getaddrinfo-perl libtext-template-perl libxml-xpath-perl libyaml-tiny-perl \
	libnet-snmp-perl libcrypt-des-perl libnet-nbname-perl libdigest-hmac-perl libfile-copy-recursive-perl libparallel-forkmanager-perl

	
		
	# Download .deb
	wget https://github.com/fusioninventory/fusioninventory-agent/releases/download/2.5.2/fusioninventory-agent_2.5.2-1_all.deb
	wget https://github.com/fusioninventory/fusioninventory-agent/releases/download/2.5.2/fusioninventory-agent-task-collect_2.5.2-1_all.deb
	wget https://github.com/fusioninventory/fusioninventory-agent/releases/download/2.5.2/fusioninventory-agent-task-network_2.5.2-1_all.deb
	wget https://github.com/fusioninventory/fusioninventory-agent/releases/download/2.5.2/fusioninventory-agent-task-deploy_2.5.2-1_all.deb
	wget https://github.com/fusioninventory/fusioninventory-agent/releases/download/2.5.2/fusioninventory-agent-task-esx_2.5.2-1_all.deb


	#Install Packets
	gdebi -n fusioninventory-agent_2.5.2-1_all.deb
	gdebi -n fusioninventory-agent-task-collect_2.5.2-1_all.deb
	gdebi -n fusioninventory-agent-task-network_2.5.2-1_all.deb
	gdebi -n fusioninventory-agent-task-deploy_2.5.2-1_all.deb
	gdebi -n fusioninventory-agent-task-esx_2.5.2-1_all.deb

	# Config.
	echo ""
	echo "========================================"
	echo "            Configurando . . .          "
	echo "========================================"
	sed -i "14i server = https://glpi.despegar.it/plugins/fusioninventory/" /etc/fusioninventory/agent.cfg
	systemctl restart fusioninventory-agent
	#systemctl reload fusioninventory-agent
	#service fusioninventory-agent start
	sleep 15
	#systemctl status fusioninventory-agent.service
	echo ""
	echo " ================================================================================"
	echo "  Ejecutando fusioninventory-agent por primera vez . . . (Espere . . . )         "
	echo " ================================================================================"
	pkill -USR1 -f -P 1 fusioninventory-agent
	if [[ $? -ne 0 ]]; then
		echo "fusioninventory-agent NO instalado" >> /home/$varadm/$escri/CheckInstall.txt
	else
		echo "fusioninventory-agent INSTALADO" >> /home/$varadm/$escri/CheckInstall.txt
	fi
	sleep 20
}

#____________________________     Para Borrar Posiblemente ______________________________________
	install_19-20(){
		apt-get install -y libgtk2.0-0
		wget http://archive.ubuntu.com/ubuntu/pool/main/i/icu/libicu60_60.2-3ubuntu3_amd64.deb
		wget http://archive.ubuntu.com/ubuntu/pool/universe/w/webkitgtk/libjavascriptcoregtk-1.0-0_2.4.11-3ubuntu3_amd64.deb
		wget http://archive.ubuntu.com/ubuntu/pool/universe/w/webkitgtk/libwebkitgtk-1.0-0_2.4.11-3ubuntu3_amd64.deb
		gdebi -n libicu60_60.2-3ubuntu3_amd64.deb
		gdebi -n libjavascriptcoregtk-1.0-0_2.4.11-3ubuntu3_amd64.deb
		gdebi -n libwebkitgtk-1.0-0_2.4.11-3ubuntu3_amd64.deb
		install_pulse
	}

	install_18-previous(){
		apt-get install -y libwebkitgtk-1.0-0 libproxy1-plugin-webkit libgnome-keyring0
		install_pulse
	}
#_________________________________________________________________________________________________

install_pulse(){	
	#wget --no-check-certificate "https://onedrive.live.com/download?cid=3D090B7E2735BB01&resid=3D090B7E2735BB01%21108&authkey=AKG_w7donFTjcTQ" -O pulse-9.0R4.x86_64.deb 2>&1
	#gdebi -n pulse-9.0R4.x86_64.deb

	GITHUB_API_TOKEN="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"
	GH_ASSET="https://api.github.com/repos/franklin-gedler/Scripts-Ubuntu/releases/assets/43371663"
	curl -LJO# -H "Authorization: token $GITHUB_API_TOKEN" -H "Accept: application/octet-stream" "$GH_ASSET"

	gdebi -n Pulse-9.1r11.0-64bit.deb

	#if [[ $varusr ]]; then
	#	mkdir -p /home/$varusr/.pulse_secure/pulse/
	#	echo '{"connName": "VPN Miami", "preferredCert": "", "baseUrl": "https://newton.despegar.net/IT"}' > /home/$varusr/.pulse_secure/pulse/.pulse_Connections.txt
	#	chown -R $idusr:$idusr /home/$varusr/.pulse_secure/
    #fi

	checkpulse=$(dpkg -L pulse)
	if [[ $? -ne 0 ]]; then
		echo "Pulse Connect NO instalado" >> /home/$varadm/$escri/CheckInstall.txt
	else
		echo "Pulse Connect INSTALADO" >> /home/$varadm/$escri/CheckInstall.txt
	fi
}

install_snx(){
	dpkg --add-architecture i386
	#apt-get install -y libpam0g:i386 libstdc++5 libx11-6:i386 libstdc++6:i386 libstdc++5:i386
	apt install libpam0g:i386 libx11-6:i386 libstdc++6:i386 libstdc++5:i386 libnss3-tools -y
	#wget https://starkers.keybase.pub/snx_install_linux30.sh?dl=1 -O snx_install.sh

	GITHUB_API_TOKEN="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"
	GH_ASSET="https://api.github.com/repos/franklin-gedler/Scripts-Ubuntu/releases/assets/43369399"
	curl -LJO# -H "Authorization: token $GITHUB_API_TOKEN" -H "Accept: application/octet-stream" "$GH_ASSET"

	chmod +x snx_install_linux30.sh
	./snx_install_linux30.sh

	if [[ $? -ne 0 ]]; then
		echo "CheckPoint NO instalado" >> /home/$varadm/$escri/CheckInstall.txt
	else
		echo "CheckPoint INSTALADO" >> /home/$varadm/$escri/CheckInstall.txt
	fi
	# Este bloque lo comento ya que para la preparacion es necesario consultar el nombre de usuario de VPN
	#echo "server accesoremoto-ar.despegar.net" >> /home/$varusr/.snxrc
	#fundialog=${fundialog=dialog}
	#var1=`$fundialog --stdout --no-cancel --title "    VPN Regional" --inputbox "Ingresar Username VPN: \n Example: Nombre.Apellido " 0 0`
	#clear
	#echo -e "username $var1\nreauth yes" >> /home/$varusr/.snxrc
	#chown $idusr:$idusr /home/$varusr/.snxrc
}

ConnectionAD(){

	ping -c1 10.40.54.1 &>/dev/null
	while [[ $? -ne 0 ]]; do
		echo " =========================================================================="
		echo "       Error al conectarse al Active Directory, por favor verificar!       "
		echo ""
		echo "    - Si estas desde casa, conectate a la VPN Regional"
		echo "    - Si estas en la oficina, abre otra terminal y tira un ping a ar.infra.d  "
		echo " =========================================================================="
		echo ""
        read -n 1 -s -r -p "*** Persione cualquier tecla para continuar ***"
        echo ""
        echo ""
        ping -c1 ar.infra.d &>/dev/null
	done
	echo ""
	echo " ***************************************** "
	echo "   Conexion con el AD OK, seguimos . . .   "
	echo " ***************************************** "
	echo ""
}

inputcredsoporte(){

	echo ""
    echo " ======================================= "
    echo "   Ingresa tus credenciales de soporte   "
	echo "     para buscar el equipo en el AD      "
    echo " ======================================= "
    echo ""

	usrSoporte=$(yad --entry \
            	--center \
            	--width=350 \
            	--skip-taskbar \
            	--on-top \
                --text-align=center \
                --text="Ej:   Nombre.Apellido" \
            	--title="Usuario de Soporte" --image=dialog-information --button=Aceptar:0)
	
	while [[ -z $usrSoporte ]]; do
		usrSoporte=$(yad --entry \
						--center \
						--width=350 \
						--skip-taskbar \
						--on-top \
						--text-align=center \
						--text="Ej:   Nombre.Apellido" \
						--title="Usuario de Soporte" --image=dialog-information --button=Aceptar:0)
	done

	usrSoporte=$(echo "$usrSoporte" | tr -d '[[:space:]]')

	passSoporte=$(yad --entry \
					--center \
					--width=350 \
					--skip-taskbar \
					--on-top \
					--hide-text \
					--text=" Password: " \
					--title="Usuario de Soporte" --image=dialog-password --button=Aceptar:0)

	while [[ -z $passSoporte ]]; do
		passSoporte=$(yad --entry \
						--center \
						--width=350 \
						--skip-taskbar \
						--on-top \
						--hide-text \
						--text=" Password: " \
						--title="Usuario de Soporte" --image=dialog-password --button=Aceptar:0)
	done

	passSoporte=$(echo "$passSoporte" | tr -d '[[:space:]]')

	#fundialog=${fundialog=dialog}
	#usrSoporte=`$fundialog --stdout --no-cancel \
	#	--backtitle " Credenciales de soporte " \
	#	--title "    Usuario de Soporte " \
	#	--inputbox "Ingresar Username: \n Example: Nombre.Apellido " 0 0`
	#clear

	#fundialog=${fundialog=dialog}
	#passSoporte=`$fundialog --stdout --no-cancel --insecure \
	#	--backtitle " Ingrese el Contraseña para $usrSoporte " \
	#	--title "    Password" \
	#   --passwordbox " Ingresar contraseña de $usrSoporte " 0 0`
	#clear
}

validatecredsoporte(){

	ConnectionAD
	inputcredsoporte

	echo ""
    echo " ====================================== "
    echo "   Verificando credenciales ingresadas  "
    echo " ====================================== "
    echo ""

	VerifyCheck=$(ldapsearch -z 0 -x -b "dc=ar,dc=infra,dc=d" \
        -D "$usrSoporte@ar.infra.d" \
        -h 10.40.54.1 \
        -w "$passSoporte" "userPrincipalName=$usrSoporte@ar.infra.d" | egrep "sAMAccountName=*" | cut -d' ' -f'2-')

	while [[ -z "$VerifyCheck" ]]; do
        #echo "El valor de la validacion es $VerifyCheck"
        echo ""
		echo " ============================================================================= "
		echo "         Credenciales de $usrSoporte Incorrectas, por favor verificar!"
		echo ""
		echo "  - Verifica el idioma del teclado (Recordar que el teclado varia de US y ES) "
		echo "  - Reingresa tus Credenciales de RED"
		echo "  - Verifica si estas conectado a la RED Despegar"
		echo " ============================================================================= "
        read -n 1 -s -r -p "*** Persione cualquier tecla para continuar ***"
		inputcredsoporte
		VerifyCheck=$(ldapsearch -z 0 -x -b "dc=ar,dc=infra,dc=d" \
        	-D "$usrSoporte@ar.infra.d" \
        	-h 10.40.54.1 \
        	-w "$passSoporte" "userPrincipalName=$usrSoporte@ar.infra.d" | egrep "sAMAccountName=*" | cut -d' ' -f'2-')
    done
    echo ""
    echo " ***************************************** "
    echo "   Credenciales de $usrSoporte Correctas   "
    echo " ***************************************** "
    echo ""
}

deletead(){

	validatecredsoporte

	echo ""
    echo " ======================================================== "
    echo "   Verificando si el equipo $(hostname) Existe en el AD   "
    echo " ======================================================== "
    echo ""
	
	ComputerInAD=$(ldapsearch -z 0 -x -b "dc=ar,dc=infra,dc=d" \
    	-D "$usrSoporte@ar.infra.d" \
        -h 10.40.54.1 \
        -w "$passSoporte" "cn=$(hostname)" | egrep "distinguishedName=*" | cut -d' ' -f'2-')
    
    if [[ -z "$ComputerInAD" ]];then
        echo ""
        echo " ************************************ "
        echo "   Equipo $(hostname) NO Encontrado   "
        echo " ************************************ "
        echo ""
		sleep 10
    else
        echo ""
        echo " ================================================================ "
        echo "   Equipo Encontrado en el AD se procede a Borrar, Espere . . .   "
        echo "     $ComputerInAD "
        echo " ================================================================ "
        echo ""
        ldapdelete -D "$usrSoporte@ar.infra.d" \
            -w "$passSoporte" \
            -h 10.40.54.1 "$ComputerInAD"
        sleep 5
		echo ""
		echo " *********** "
		echo "   Borrado   "
		echo " *********** "
		echo ""
		sleep 5
    fi
}

VerifyAC(){

	sudo apt-get install acpi

	ACPower=$(acpi -a | awk '{print $3}' | tr -d '[[:space:]]')

	while [[ $ACPower = "off-line" ]];do
			echo ""
			echo " ********************************** "
			echo "   Por favor Conectar el Cargador   "
			echo " ********************************** "
			echo ""
			read -n 1 -s -r -p "*** Persione cualquier tecla para continuar ***"
			ACPower=$(acpi -a | awk '{print $3}' | tr -d '[[:space:]]')
	done
}

Updatebios(){

	VerifyAC
	service fwupd start
	fwupdmgr refresh
	echo -e "\nN" | fwupdmgr --assume-yes --force update
}

Teamviewer(){
	curl -LO# https://download.teamviewer.com/download/linux/signature/TeamViewer2017.asc

	apt-key add TeamViewer2017.asc
	
	add-apt-repository 'deb https://linux.teamviewer.com/deb stable main'

	apt-get install teamviewer -y

	teamviewer license accept

	# Lo elimino ya que el instalador del team crea en source.list.d 
	# otro repo de teamviewer lo cual duplica el repo y tira error
		add-apt-repository --remove 'deb https://linux.teamviewer.com/deb stable main'  
}

ping -c1 google.com &>/dev/null
if [[ $? -ne 0 ]] || [[ "$EUID" != 0 ]]; then
	echo " #########################################################"
	echo " Este Script requiere sudo o no tienes conexion a internet"
	echo " #########################################################"
	exit 1
else
	DirHost=$(pwd)
	TEMPDIR=`mktemp -d`
	cd $TEMPDIR
	echo "$DirHost" > DirHost
	############################################################################################

	sysctl -w net.ipv6.conf.all.disable_ipv6=1
	sysctl -w net.ipv6.conf.default.disable_ipv6=1
	#UBUNTU_VER=$(lsb_release -d | grep -o '.[0-9]*\.'| head -1|sed -e 's/\s*//'|sed -e 's/\.//')
	apt-get update
	apt-get install -y dialog gdebi-core ldap-utils yad
	if [[ $? != 0 ]]; then

		echo "-------------------------------------------------------"
		echo "|Problemas para instalar Dependencias, verificar repos|"
		echo "-------------------------------------------------------"
		exit

	else
		VerifyAC
		CheckInstall
		NewNameCompu
		deletead
		wantcreateuser
		timedatectl set-timezone "America/Argentina/Buenos_Aires"
		hwclock --systohc
		InstallChrome
		# __________________Para Borrar Posiblemente _________________________
			#if [[ $UBUNTU_VER -gt 18 ]]; then
			#	install_19-20
			#else
			#	install_18-previous
			#fi
		#_____________________________________________________________________
		install_pulse
		install_snx
		Teamviewer
		Glpi
		ChangePass
		Updatebios
		rm -rf /etc/postfix/sasl_passwd /etc/postfix/sasl_passwd.db
		apt-get --purge remove mailutils postfix -y 1>/dev/null
	
	fi
	#############################################################################################
	cat > $TEMPDIR/aux.sh << 'EOF'
	DirHost=$(cat DirHost)
	PathFile=$(egrep -r 'PrepareUbuntu' $DirHost | awk -F: 'FNR == 1 {print $1}')
	rm -rf $PathFile
EOF
	chmod +x aux.sh
	./aux.sh
	#RebootNow # este rebooot lo tiene el Preprare NAS
	exit
	
fi