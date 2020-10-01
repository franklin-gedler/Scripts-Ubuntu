#!/bin/bash

Install-Zoiper(){

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

	# Instala dependencias
	apt-get install dialog gdebi-core -y

	mv sources.list.bak sources.list
	mv sources.list.d.bak sources.list.d

	# me muevo a la carpeta temporal
	cd $TEMPDIR

	# Descarga el Zoiper
	wget https://soportedespe.000webhostapp.com/zoiper5_5.2.28_x86_64.deb 2>&1

	# Instala el Zoiper
	gdebi -n zoiper5_5.2.28_x86_64.deb

	# Descarga el archivo de Config
	wget https://soportedespe.000webhostapp.com/Config.xml 2>&1

	# Pide al usuario numero de interno
	fundialog=${fundialog=dialog}
	var1=`$fundialog --stdout --no-cancel --title "Numero de Interno" --inputbox "Ingresar numero de interno: \n " 0 0`
	clear

	# Escribe el numero interno al archivo config
	sed -i "s/interno/$var1/g" Config.xml

	# Pide al usuario ip de la PBX
	fundialog=${fundialog=dialog}
	var2=`$fundialog --stdout --no-cancel --title "PBX - Server" --inputbox "Ingresar IP : \n " 0 0`
	clear

	# Escribe ip en file Config
	sed -i "s/pbxip/$var2/g" Config.xml

	# Crea el Directorio Zoiper
	mkdir -p /home/$varusr/.Zoiper5

	# Copia el archivo de config a la ruta indicada
	cp $TEMPDIR/Config.xml /home/$varusr/.Zoiper5/

	# Cambia de dueño:grupo al archivo de conf.
	chown -R $idusr:$idusr /home/$varusr/.Zoiper5/

	# Abre el Zoiper 
	#ZOIPER_PATH="/usr/local/applications/Zoiper5/zoiper"
	#ZOIPER_LOGS="$TEMPDIR/Logs"
	#mkdir -p $ZOIPER_LOGS
	#nohup "$ZOIPER_PATH" "$@" >> "$ZOIPER_LOGS/zoiper-terminal.log" 2>&1 &
	clear
}

ping -c1 google.com &>/dev/null
if [[ $? -ne 0 ]] || [[ "$EUID" != 0 ]]; then
	echo "Este Script requiere root o no tienes conexion a internet"
	exit 1
else

	TEMPDIR=`mktemp -d`

	Install-Zoiper 2> $TEMPDIR/errinstall

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
		echo "            =              Zoiper Instalado . . .           ="
		echo "            =                   Ejoy =)                     ="
		echo "            ================================================="
		echo ""
		echo ""
	fi
fi

