#!/bin/bash


# autodestruccion del Script
# cambiar contraseña de usuario: echo "user:pass" | sudo chpasswd
# verificar si al crear el usaurio local cra tambien el home del usuario /home/usuariocreado para asi tirarle la conf. de la VPN

#PrepareUbuntu

NewNameCompu(){
	varhostname=$(hostname)
	varserial=$(/usr/sbin/dmidecode -s system-serial-number)
	varnewhostname=AR$varserial
	/usr/bin/nmcli general hostname $varnewhostname
	sed -i "s/$varhostname/$varnewhostname/g" /etc/hosts
}

CreateNewUser(){
	fundialog=${fundialog=dialog}
	varusr=`$fundialog --stdout --no-cancel --title "    User Creation" --inputbox "Ingresar Username: \n Example: Nombre.Apellido " 0 0`
	adduser --force-badname $varusr
	adduser $varusr sudo
}

InstallChrome(){
	wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
	gdebi -n google-chrome-stable_current_amd64.deb
}

ChangePass(){
	echo "admindesp:*+54#$varserial*" | sudo chpasswd
}

Glpi(){
	ping -c1 glpi.despegar.it &>/dev/null
	while [[ $? -ne 0 ]]; do
	echo ""
	echo "-----------------------------------------------------------------------------------------------"
	echo "|* Problemas para conectar al Server Glpi, verificar si estas conectado a la RED de Despegar *|"
	echo "-----------------------------------------------------------------------------------------------"
	read -n 1 -s -r -p "*** Persione cualquier tecla para continuar ***"
	ping -c1 glpi.despegar.it &>/dev/null
	echo ""
	done

	apt-get install -y dmidecode hwdata ucf hdparm perl libuniversal-require-perl libwww-perl libparse-edid-perl \
	libproc-daemon-perl libfile-which-perl libhttp-daemon-perl libxml-treepp-perl libyaml-perl libnet-cups-perl libnet-ip-perl \
	libdigest-sha-perl libsocket-getaddrinfo-perl libtext-template-perl libxml-xpath-perl libyaml-tiny-perl \
	libnet-snmp-perl libcrypt-des-perl libnet-nbname-perl libdigest-hmac-perl libfile-copy-recursive-perl libparallel-forkmanager-perl

	if [[ $? != 0 ]]; then

		echo "-------------------------------------------------------"
		echo "|Problemas para instalar Dependencias, verificar repos|"
		echo "-------------------------------------------------------"
		exit

	else
		
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
		echo "==========================================================="
		echo "  Ejecutando por primera vez . . . (Espere . . . )         "
		echo "==========================================================="
		pkill -USR1 -f -P 1 fusioninventory-agent
		sleep 20

		echo ""
		echo "                      ============"
		echo "                          LISTO"
		echo "                      ============"
		echo "-------------------------------------------------------"
		echo "           fusioninventory-agent instalado"
		echo "-------------------------------------------------------"
	fi
}

install_19-20(){
	apt-get install -y gdebi-core libgtk2.0-0
	wget http://archive.ubuntu.com/ubuntu/pool/main/i/icu/libicu60_60.2-3ubuntu3_amd64.deb
	wget http://archive.ubuntu.com/ubuntu/pool/universe/w/webkitgtk/libjavascriptcoregtk-1.0-0_2.4.11-3ubuntu3_amd64.deb
	wget http://archive.ubuntu.com/ubuntu/pool/universe/w/webkitgtk/libwebkitgtk-1.0-0_2.4.11-3ubuntu3_amd64.deb
	gdebi -n libicu60_60.2-3ubuntu3_amd64.deb
	gdebi -n libjavascriptcoregtk-1.0-0_2.4.11-3ubuntu3_amd64.deb
	gdebi -n libwebkitgtk-1.0-0_2.4.11-3ubuntu3_amd64.deb
	install_pulse
}

install_18-previous(){
	apt-get install -y gdebi-core libwebkitgtk-1.0-0 libproxy1-plugin-webkit libgnome-keyring0
	install_pulse
}

verific(){
	#varusr=$(who > /tmp/varusr && awk -F: '{ print $1 }' /tmp/varusr | tr -d '[[:space:]]')
	#varusr=$(who | awk 'FNR == 1 {print $1}' | tr -d '[[:space:]]')
	idusr=$(id -u $varusr)
	UBUNTU_VER=$(lsb_release -d | grep -o '.[0-9]*\.'| head -1|sed -e 's/\s*//'|sed -e 's/\.//')	
}

install_pulse(){	
	wget --no-check-certificate "https://onedrive.live.com/download?cid=3D090B7E2735BB01&resid=3D090B7E2735BB01%21108&authkey=AKG_w7donFTjcTQ" -O pulse-9.0R4.x86_64.deb 2>&1
	gdebi -n pulse-9.0R4.x86_64.deb
	mkdir -p /home/$varusr/.pulse_secure/pulse/
	echo '{"connName": "VPN Miami", "preferredCert": "", "baseUrl": "https://newton.despegar.net/IT"}' > /home/$varusr/.pulse_secure/pulse/.pulse_Connections.txt
	chown -R $idusr:$idusr /home/$varusr/.pulse_secure/
	#clear
}

ping -c1 google.com &>/dev/null
if [[ $? -ne 0 ]] || [[ "$EUID" != 0 ]]; then
	echo "Este Script requiere root o no tienes conexion a internet"
	exit 1
else
	DirHost=$(pwd)
	TEMPDIR=`mktemp -d`
	cd $TEMPDIR
	echo "$DirHost" > DirHost
	NewNameCompu
	timedatectl set-timezone "America/Argentina/Buenos_Aires"
	hwclock --systohc
	apt-get update
	apt-get install -y dialog gdebi-core
	CreateNewUser
	InstallChrome
	verific
	if [[ $UBUNTU_VER > 18 ]]; then
		install_19-20
	else
		install_18-previous
	fi
	Glpi
	ChangePass
	cat > $TEMPDIR/aux.sh << 'EOF'
	DirHost=$(cat DirHost)
	PathFile=$(egrep -r 'PrepareUbuntu' $DirHost | awk -F: 'FNR == 1 {print $1}')
	rm -rf $PathFile
EOF
	chmod +x aux.sh
	./aux.sh
	exit
	# Mje al usuario
	#dialog --title "README" --msgbox "Listo . . \n Para completar la preparacion es necesario \n reiniciar el equipo"." \n   Created by Franklin Gedler Support Team" 0 0
	#clear
	#echo " ################################# "
	#echo "      Es Necesario Reiniciar       "
	#echo " ################################# "
	#read -n 1 -s -r -p "*** Persione cualquier tecla para continuar ***"
	#reboot	
fi