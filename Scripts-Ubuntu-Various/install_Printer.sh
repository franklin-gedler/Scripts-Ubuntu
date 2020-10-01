#!/bin/bash

Install-Printer(){
	local TEMPDIR=`mktemp -d`
	cd $TEMPDIR
	wget https://soportedespe.000webhostapp.com/job-linux/libopts25-amd64.deb 2>&1
	wget https://soportedespe.000webhostapp.com/job-linux/sntp-amd64.deb 2>&1
	dpkg -i libopts25-amd64.deb
	dpkg -i sntp-amd64.deb
	sntp -sS ar.infra.d
	hwclock --systohc

	#cd /etc/apt/
	#mv sources.list sources.list.bak
	#mv sources.list.d sources.list.d.bak
	#wget https://gist.githubusercontent.com/h0bbel/4b28ede18d65c3527b11b12fa36aa8d1/raw/314419c944ce401039c7def964a3e06324db1128/sources.list 2>&1

	#Actualizo repositorios
	apt-get update
	# instala dependencias
	apt-get install dialog cups -y

	#mv sources.list.bak sources.list
	#mv sources.list.d.bak sources.list.d

	# me muevo a la carpeta temporal
	cd $TEMPDIR

	# Stopea servicio de impresion
	/etc/init.d/cups stop

	# Descargar los archivos de config.
	wget https://soportedespe.000webhostapp.com/Scripts-Install-Ubuntu/Install-Printer/Impresora.ppd 2>&1
	wget https://soportedespe.000webhostapp.com/Scripts-Install-Ubuntu/Install-Printer/classes.conf 2>&1
	wget https://soportedespe.000webhostapp.com/Scripts-Install-Ubuntu/Install-Printer/printers.conf 2>&1

	# Copia & pega los archivos de config.
	cp Impresora.ppd /etc/cups/ppd/
	cp classes.conf /etc/cups/
	cp printers.conf /etc/cups/

	# Genera un codigo
	newuuid=$(uuidgen)

	# Escribe el codigo en el archivo de config.
	sed -i "s/varuuid/$newuuid/g" /etc/cups/printers.conf

	# funcion de dialog para capturar la entrada de datos user
	fundialog=${fundialog=dialog}
	var1=`$fundialog --stdout --no-cancel --title "Usuario de RED" --inputbox "Ingresar Username de Red: \n Example: Nombre.Apellido " 0 0`
	clear

	# Escribe el nombre de usuario en el archivo printers.conf
	sed -i "s/usrwin/$var1/g" /etc/cups/printers.conf

	# Cambia dueño:grupo a los archivos de config.
	chown root:lp /etc/cups/printers.conf
	chown root:lp /etc/cups/classes.conf
	chown root:lp /etc/cups/ppd/Impresora.ppd 

	# Inicia Servicio de impresion
	/etc/init.d/cups start
}

ping -c1 google.com &>/dev/null
if [[ $? -ne 0 ]] || [[ "$EUID" != 0 ]]; then
	echo "Este Script requiere root o no tienes conexion a internet"
	exit 1
else

	TEMPDIR=`mktemp -d`

	Install-Printer 2> $TEMPDIR/errinstall

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
		# Mje para el Usuario
		dialog --title "README" --msgbox "Listo! . . \n Envia una impresion de prueba. \n Recordar que para liberar la impresion debes \n ingresar tu legajo en la printer. \n Created by Franklin Gedler Support Team . . ." 0 0
		clear

		# Mje al usuario
		echo ""
		echo ""
		echo "            ================================================="
		echo "            = Created by Franklin Gedler Support Team . . . ="
		echo "            ================================================="
		echo "            =            Printer Instalada . . .            ="
		echo "            =                   Ejoy =)                     ="
		echo "            ================================================="
		echo ""
		echo ""
	fi    
fi

