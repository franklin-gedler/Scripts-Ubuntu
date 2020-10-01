#!/bin/bash

Install-VPN-MIAMI(){

	varusr=$(who > /tmp/varusr && awk -F: '{ print $1 }' /tmp/varusr | tr -d '[[:space:]]')
	idusr=$(id -u $varusr)

	local TEMPDIR=`mktemp -d`
	cd $TEMPDIR
	wget https://soportedespe.000webhostapp.com/job-linux/libopts25-amd64.deb 2>&1
	wget https://soportedespe.000webhostapp.com/job-linux/sntp-amd64.deb 2>&1
	dpkg -i libopts25-amd64.deb
	dpkg -i sntp-amd64.deb
	sntp -sS ar.infra.d
	hwclock --systohc

	cd /etc/apt/
	mv sources.list sources.list.bak
	mv sources.list.d sources.list.d.bak
	wget https://gist.githubusercontent.com/h0bbel/4b28ede18d65c3527b11b12fa36aa8d1/raw/314419c944ce401039c7def964a3e06324db1128/sources.list 2>&1

	#Actualizo repositorios
	apt-get update

	# instala dependencias
	apt-get install gdebi-core libwebkitgtk-1.0-0 libproxy1-plugin-webkit libgnome-keyring0 -y

	mv sources.list.bak sources.list
	mv sources.list.d.bak sources.list.d

	# me muevo a la carpeta temporal
	cd $TEMPDIR

	wget --no-check-certificate "https://onedrive.live.com/download?cid=3D090B7E2735BB01&resid=3D090B7E2735BB01%21108&authkey=AKG_w7donFTjcTQ" -O pulse-9.0R4.x86_64.deb 2>&1
	#wget https://soportedespe.000webhostapp.com/pulse-9.0R4.x86_64.deb 2>&1

	# instalando pulse_secure
	gdebi -n pulse-9.0R4.x86_64.deb

	# creo el directorio
	mkdir -p /home/$varusr/.pulse_secure/pulse/

	echo '{"connName": "VPN Miami", "preferredCert": "", "baseUrl": "https://newton.despegar.net/IT"}' > /home/$varusr/.pulse_secure/pulse/.pulse_Connections.txt

	# Cambia de dueño:grupo al archivo de conf.
	chown -R $idusr:$idusr /home/$varusr/.pulse_secure/

	# lanza el pulse a pantalla.
#	PULSEUI_PATH="/usr/local/pulse/pulseUi"
#	PULSEUI_LOGS="$TEMPDIR/Logs"
#	mkdir -p $PULSEUI_LOGS
#	nohup "$PULSEUI_PATH" "$@" >> "$PULSEUI_LOGS/pulseui-terminal.log" 2>&1 &
	clear
}


ping -c1 google.com &>/dev/null
if [[ $? -ne 0 ]] || [[ "$EUID" != 0 ]]; then
	echo "Este Script requiere root o no tienes conexion a internet"
	exit 1
else

	TEMPDIR=`mktemp -d`

	Install-VPN-MIAMI 2> $TEMPDIR/errinstall

	if [[ -s $TEMPDIR/errinstall ]]; then
		echo ""
		echo ""
		echo "Hubieron errores verificar:"
		error=$(cat $TEMPDIR/errinstall)
		echo "---------------------------------------------"
		echo "$error"
		echo "---------------------------------------------"
		exit
	else
		# Mje al usuario
		echo ""
		echo ""
		echo "            ================================================="
		echo "            = Created by Franklin Gedler Support Team . . . ="
		echo "            ================================================="
		echo "            =            Pulse Secure Instalado . . .       ="
		echo "            =                   Ejoy =)                     ="
		echo "            ================================================="
		echo ""
		echo ""
	fi    
fi