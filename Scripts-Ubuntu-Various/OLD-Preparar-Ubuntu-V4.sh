#!/bin/bash

Preparar-Ubuntu(){
	local TEMPDIR=`mktemp -d`
	cd $TEMPDIR
	wget https://soportedespe.000webhostapp.com/job-linux/libopts25-amd64.deb 2>&1
	wget https://soportedespe.000webhostapp.com/job-linux/sntp-amd64.deb 2>&1
	dpkg -i libopts25-amd64.deb
	dpkg -i sntp-amd64.deb
	sntp -sS ar.infra.d
	hwclock --systohc

	# creo un nuevo source.list
	cd /etc/apt/
	mv sources.list sources.list.old
	wget https://gist.githubusercontent.com/h0bbel/4b28ede18d65c3527b11b12fa36aa8d1/raw/314419c944ce401039c7def964a3e06324db1128/sources.list 2>&1

	# Actualizo repositorios
	apt-get update

	# Instalo lo necesario
	apt-get install -y dialog gdebi-core

	# Pregunto nombre de usaurio a crear
	fundialog=${fundialog=dialog}
	varusr=`$fundialog --stdout --no-cancel --title "    User Creation" --inputbox "Ingresar Username: \n Example: Nombre.Apellido " 0 0`
	clear

	# Creo el usuario y lo agrego al grupo sudo
	adduser --force-badname $varusr
	adduser $varusr sudo

	# Descargo e instalo Google Chrome
	cd $TEMPDIR
	wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb 2>&1
	gdebi -n google-chrome-stable_current_amd64.deb

	# Desde aca viene el Script de Invgate
	echo "=================Bajando la llave================="
	wget -O - http://download.invgate.net/assets/packages/debian/keyFile 2>&1
	apt-key add -
	echo ""

	echo "=================Agregando el repo================="
	echo "deb http://download.invgate.net/assets/packages/debian/binary /" > /etc/apt/sources.list.d/invgate-assets.list
	echo ""

	apt-get update && apt-get install --allow-unauthenticated invgate-assets-client -y
	echo "" 

	echo "=================Creando la configuracion con datos del servidor (10.254.112.230:8420)================="
	mkdir -p /usr/local/invgate/bin
	echo "IP=10.254.112.230" > /usr/local/invgate/bin/invgate-assets-client.cfg
	echo "PORT=8420" >> /usr/local/invgate/bin/invgate-assets-client.cfg
	echo ""

	echo "=================Asignandole permisos de lectura...================="
	chmod 755 /usr/local/invgate/bin/invgate-assets-client.cfg
	echo ""

	echo "=================Creando /tmp/install_agent.sh================="
	cat > /tmp/install_agent.sh << EOF
	wget http://download.invgate.net/assets/packages/debian/keyFile 2>&1
	apt-key add keyFile
	echo "deb http://download.invgate.net/assets/packages/debian/binary /" > /etc/apt/sources.list.d/invgate-assets.list
	apt-get update
	apt-get -y install invgate-assets-client
EOF
	echo ""

	echo "=================Asignandole permisos de ejecucion a install_agent.sh================="
	chmod +x /tmp/install_agent.sh
	echo ""

	echo "=================Corriend el instalador...================="
	/tmp/install_agent.sh
	echo ""

	echo "=================Generando environment para que no falle el root script...================="
	env > /root/root_env.sh

	echo "=================Guardando lineas para correr el script por primera vez al reiniciar...================="
	line="@reboot sleep 20; . /root/root_env.sh; /usr/local/invgate/bin/invgate-assets-client.sh; mv /usr/local/invgate/bin/invgate-assets-client.sh /usr/local/invgate/bin/invgate-assets-client.sh.bkp "
	(crontab -u root -l; echo "$line" ) | crontab -u root -

	echo "=================Renombrando Interfaces...================="
	sed -i 's/.*GRUB_CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0"/' /etc/default/grub
	grub-mkconfig -o /boot/grub/grub.cfg
	
	# Set al nombre del equipo ARXXXX
	varhostname=$(hostname)
	varserial=$(/usr/sbin/dmidecode -s system-serial-number)
	varnewhostname=AR$varserial
	/usr/bin/nmcli general hostname $varnewhostname
	sed -i "s/$varhostname/$varnewhostname/g" /etc/hosts
}

ping -c1 google.com &>/dev/null
if [[ $? -ne 0 ]] || [[ "$EUID" != 0 ]]; then
	echo "Este Script requiere root o no tienes conexion a internet"
	exit 1
else

	TEMPDIR=`mktemp -d`

	Preparar-Ubuntu 2> $TEMPDIR/errinstall

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
		dialog --title "README" --msgbox "Listo . . \n Para completar la preparacion es necesario \n reiniciar el equipo"." \n   Created by Franklin Gedler Support Team" 0 0
		clear
		reboot
	fi    
fi