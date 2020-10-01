#!/bin/bash

Install-Zoom(){

	varusr=$(who > /tmp/varusr && awk -F: '{ print $1 }' /tmp/varusr | tr -d '[[:space:]]')
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
	apt-get install gdebi-core -y

	mv sources.list.bak sources.list
	mv sources.list.d.bak sources.list.d

	# me muevo a la carpeta temporal
	cd $TEMPDIR

	# Descarga Zoom
	wget https://d11yldzmag5yn.cloudfront.net/prod/2.8.252201.0616/zoom_amd64.deb 2>&1

	# Instalar programa
	gdebi -n *.deb

	# Ejecuta el Zoom
	su $varusr -c /opt/zoom/zoomlinux
	clear
}

ping -c1 google.com &>/dev/null
if [[ $? -ne 0 ]] || [[ "$EUID" != 0 ]]; then
	echo "Este Script requiere root o no tienes conexion a internet"
	exit 1
else

	TEMPDIR=`mktemp -d`

	Install-Zoom 2> $TEMPDIR/errinstall

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
		echo "            =           Zoom Meeting Instalado . . .        ="
		echo "            =                   Ejoy =)                     ="
		echo "            ================================================="
		echo ""
		echo ""
	fi    
fi

