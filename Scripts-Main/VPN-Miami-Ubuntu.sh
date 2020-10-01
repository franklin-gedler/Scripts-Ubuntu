#!/bin/bash
#VPNMiamiUbuntuNoBorrar

created_by(){

	# Mje al usuario
		echo "            = Nota: Para Ubuntu 19 y 20 el pulseUi tarda un ="
		echo "            =       par de minutos en abrir                 ="
		echo "            ================================================="
		echo "            = Created by Franklin Gedler Support Team . . . ="
		echo "            ================================================="
		echo "            =            Pulse Secure Instalado . . .       ="
		echo "            =                   Enjoy =)                    ="
		echo "            ================================================="
		echo ""
		echo ""
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
	varusr=$(who | awk 'FNR == 1 {print $1}' | tr -d '[[:space:]]')
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
	##############################################################################################
	verific
	if [[ $UBUNTU_VER > 18 ]]; then
		install_19-20
		created_by
	else
		install_18-previous
		created_by
	fi
	#############################################################################################
	cat > $TEMPDIR/aux.sh << 'EOF'
	DirHost=$(cat DirHost)
	PathFile=$(egrep -r 'VPNMiamiUbuntuNoBorrar' $DirHost | awk -F: 'FNR == 1 {print $1}')
	rm -rf $PathFile
EOF
	chmod +x aux.sh
	./aux.sh
	exit
fi