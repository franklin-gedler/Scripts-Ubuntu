#!/bin/bash
#VPNRegionalUbuntu

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
	#varusr=$(who > /tmp/varusr && awk -F: '{ print $1 }' /tmp/varusr | tr -d '[[:space:]]')
	varusr=$(who | awk 'FNR == 1 {print $1}' | tr -d '[[:space:]]')
	idusr=$(id -u $varusr)
	UBUNTU_VER=$(lsb_release -d | grep -o '.[0-9]*\.'| head -1|sed -e 's/\s*//'|sed -e 's/\.//')
}

install_dependencies(){
	dpkg --add-architecture i386
	apt-get update
	#apt-get install -y dialog libpam0g:i386 libstdc++5 libx11-6:i386 libstdc++6:i386 libstdc++5:i386
	apt install libpam0g:i386 libx11-6:i386 libstdc++6:i386 libstdc++5:i386 libnss3-tools dialog -y
}

install_snx(){

	#wget https://starkers.keybase.pub/snx_install_linux30.sh?dl=1 -O snx_install.sh
	#chmod +x snx_install.sh
	#./snx_install.sh
	
	GITHUB_API_TOKEN="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"
	GH_ASSET="https://api.github.com/repos/franklin-gedler/Scripts-Ubuntu/releases/assets/43369399"
	curl -LJO# -H "Authorization: token $GITHUB_API_TOKEN" -H "Accept: application/octet-stream" "$GH_ASSET"

	chmod +x snx_install_linux30.sh
	./snx_install_linux30.sh
	
	echo "server accesoremoto-ar.despegar.net" >> /home/$varusr/.snxrc
	fundialog=${fundialog=dialog}
	var1=`$fundialog --stdout --no-cancel --title "    VPN Regional" --inputbox "Ingresar Username VPN: \n Example: Nombre.Apellido " 0 0`
	clear
	echo -e "username $var1\nreauth yes" >> /home/$varusr/.snxrc
	chown $idusr:$idusr /home/$varusr/.snxrc
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
	##############################################################################################
	verific
	install_dependencies
	install_snx
	#############################################################################################
	cat > $TEMPDIR/aux.sh << 'EOF'
	DirHost=$(cat DirHost)
	PathFile=$(egrep -r 'VPNRegionalUbuntu' $DirHost | awk -F: 'FNR == 1 {print $1}')
	rm -rf $PathFile
EOF
	chmod +x aux.sh
	./aux.sh
	exit
fi

