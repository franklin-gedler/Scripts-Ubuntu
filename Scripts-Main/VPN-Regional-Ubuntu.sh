#!/bin/bash
<< 'comentario'
#backup_apt(){
#	fuser -vki  /var/lib/dpkg/lock
#	rm -f /var/lib/dpkg/lock
#	mkdir -p backup-apt
#	cp -r /etc/apt/* backup-apt/
#}

#restore_apt(){

#}

#fix_apt_get_18(){

#}

fix_apt_get_19(){

	mv /etc/apt/source.list /etc/apt/source.list.old
	wget https://gist.githubusercontent.com/malikalichsan/860b8134a74c65a394efe09711d0b95f/raw/326345f39d2e0e09604f6f5e8f776bf7608e444b/source.list
	cp source.list /etc/apt/
	rm -rf /var/lib/apt/list/*
	apt-get update


	#wget https://soportedespe.000webhostapp.com/Scripts-Install-Ubuntu/apt-ubuntu-versions/apt-original-v19.zip
	#mkdir -p new-apt/
	#unzip apt-original-v19.zip -d new-apt/
	#cp -r new-apt/* /etc/apt/
	#dpkg --configure –a
	install_dependencies
	if [[ $? != 0 ]]; then
		echo "==================================================="
		echo "se intento reparar repos sin exito, ¡¡¡verificar!!!"
		echo "==================================================="
	else
		install_snx
	fi
}

#fix_apt_get_20(){

#}

pre_install(){
	install_dependencies
	if [[ $? != 0 ]]; then

		if [[ $UBUNTU_VER < 18 ]]; then
			echo "========================================================================================="
			echo "Problemas con los repos | Version de este Ubuntu: $UBUNTU_VER | VPN Regional NO Instalado"
			echo "========================================================================================="
		fi
		if [[ $UBUNTU_VER = 18 ]]; then
			backup_apt
			fix_apt_get_18
		fi
		if [[ $UBUNTU_VER = 19 ]]; then
			backup_apt
			fix_apt_get_19
		fi
		if [[ $UBUNTU_VER = 20 ]]; then
			backup_apt
			fix_apt_get_20
		fi
	else
		install_snx
	fi
}
comentario

created_by(){
	# Mje para el Usuario
	dialog --title "README" --msgbox "Listo . . \n Con solo ejecutar snx desde el terminal \n te pedira que ingreses el passcode generado \n con la app RSA"." \n   Created by Franklin Gedler Support Team" 0 0
	#clear

	# Mje al usuario
		echo ""
		echo ""
		echo "            ================================================="
		echo "            = Created by Franklin Gedler Support Team . . . ="
		echo "            ================================================="
		echo "            =            VPN Regional Instalado . . .       ="
		echo "            =                   Enjoy =)                     ="
		echo "            ================================================="
		echo ""
		echo ""
}

verific(){
	varusr=$(who > /tmp/varusr && awk -F: '{ print $1 }' /tmp/varusr | tr -d '[[:space:]]')
	idusr=$(id -u $varusr)
	UBUNTU_VER=$(lsb_release -d | grep -o '.[0-9]*\.'| head -1|sed -e 's/\s*//'|sed -e 's/\.//')
}

install_dependencies(){
	dpkg --add-architecture i386
	apt-get update
	apt-get install -y dialog libpam0g:i386 libstdc++5 libx11-6:i386 libstdc++6:i386 libstdc++5:i386
}

install_snx(){

	wget https://starkers.keybase.pub/snx_install_linux30.sh?dl=1 -O snx_install.sh
	chmod +x snx_install.sh
	./snx_install.sh
	echo "server accesoremoto-ar.despegar.net" >> /home/$varusr/.snxrc
	fundialog=${fundialog=dialog}
	var1=`$fundialog --stdout --no-cancel --title "    VPN Regional" --inputbox "Ingresar Username VPN: \n Example: Nombre.Apellido " 0 0`
	#clear
	echo -e "username $var1\nreauth yes" >> /home/$varusr/.snxrc
	chown $idusr:$idusr /home/$varusr/.snxrc
}

ping -c1 google.com &>/dev/null
if [[ $? -ne 0 ]] || [[ "$EUID" != 0 ]]; then
	echo "Este Script requiere root o no tienes conexion a internet"
	exit 1
else
	verific
	TEMPDIR=$(mktemp -d)
	cd $TEMPDIR
	install_dependencies
	install_snx
	created_by
fi

