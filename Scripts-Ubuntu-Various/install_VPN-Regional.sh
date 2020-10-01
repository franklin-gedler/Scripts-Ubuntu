#!/bin/bash

Install-VPN-Regional(){

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
	sudo apt-get install dialog libpam0g:i386 libstdc++5 libx11-6:i386 libstdc++6:i386 libstdc++5:i386 -y

	#Resstablesco los repos del usuario
	mv sources.list.bak sources.list
	mv sources.list.d.bak sources.list.d

	# me muevo a la carpeta temporal
	cd $TEMPDIR

	# Descarga instalador (Script)
	wget https://starkers.keybase.pub/snx_install_linux30.sh?dl=1 -O snx_install.sh 2>&1

	# Asigna permisos de ejecucion
	chmod +x snx_install.sh

	# Ejecuta el instalador (Script)
	./snx_install.sh

	# realiza configuraciones
	echo "server accesoremoto-ar.despegar.net" >> /home/$varusr/.snxrc
	fundialog=${fundialog=dialog}
	var1=`$fundialog --stdout --no-cancel --title "    VPN Regional" --inputbox "Ingresar Username VPN: \n Example: Nombre.Apellido " 0 0`
	clear
	echo -e "username $var1\nreauth yes" >> /home/$varusr/.snxrc
	#echo "reauth yes" >> /home/$varusr/.snxrc
}

ping -c1 google.com &>/dev/null
if [[ $? -ne 0 ]] || [[ "$EUID" != 0 ]]; then
	echo "Este Script requiere root o no tienes conexion a internet"
	exit 1
else

	TEMPDIR=`mktemp -d`

	Install-VPN-Regional 2> $TEMPDIR/errinstall

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
		dialog --title "README" --msgbox "Listo . . \n Con solo ejecutar snx desde el terminal \n te pedira que ingreses el passcode generado \n con la app RSA"." \n   Created by Franklin Gedler Support Team" 0 0
		clear

		# Mje al usuario
		echo ""
		echo ""
		echo "            ================================================="
		echo "            = Created by Franklin Gedler Support Team . . . ="
		echo "            ================================================="
		echo "            =            VPN Regional Instalado . . .       ="
		echo "            =                   Ejoy =)                     ="
		echo "            ================================================="
		echo ""
		echo ""
	fi
fi

