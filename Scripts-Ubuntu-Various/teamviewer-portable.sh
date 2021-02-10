#!/bin/bash


install_depends_19(){
	wget https://soportedespe.000webhostapp.com/Scripts-Install-Ubuntu/dependencias-teamviewer-ubuntu/19.10/depends-19.zip
	mkdir depends/
	unzip depends-19.zip -d depends/
	echo "=============================================================================="
	echo "=============================================================================="
	dpkg -i depends/0/*.deb
	dpkg -i depends/0/1/*.deb
	dpkg -i depends/0/2/1/*.deb
	dpkg -i depends/0/2/*.deb
	echo "=============================================================================="
	echo "=============================================================================="
	dpkg -i depends/1/*.deb
	echo "=============================================================================="
	echo "=============================================================================="
	dpkg -i depends/2/1/1/*.deb
	dpkg -i depends/2/1/2/*.deb
	dpkg -i depends/2/1/*.deb
	dpkg -i depends/2/*.deb
	echo "=============================================================================="
	echo "=============================================================================="
	dpkg -i depends/3/1/*.deb
	dpkg -i depends/3/2/*.deb
	dpkg -i depends/3/3/*.deb
	dpkg -i depends/3/*.deb
	echo "=============================================================================="
	echo "=============================================================================="
	dpkg -i depends/4/*.deb
	echo "=============================================================================="
	echo "=============================================================================="
	dpkg -i depends/5/*.deb
	echo "=============================================================================="
	echo "=============================================================================="
	dpkg -i depends/6/1/*.deb
	dpkg -i depends/6/2/1/*.deb
	dpkg -i depends/6/2/*.deb
	dpkg -i depends/6/3/*.deb
	dpkg -i depends/6/4/*.deb
	dpkg -i depends/6/*.deb
	echo "=============================================================================="
	echo "=============================================================================="
	dpkg -i depends/7/*.deb
	echo "=============================================================================="
	echo "=============================================================================="
	dpkg -i depends/8/1/1/*.deb
	dpkg -i depends/8/1/2/*.deb
	dpkg -i depends/8/1/*.deb
	dpkg -i depends/8/2/*.deb
	dpkg -i depends/8/*.deb
	echo "=============================================================================="
	echo "=============================================================================="
	dpkg -i depends/9/1/*.deb
	dpkg -i depends/9/*.deb	
}

verific(){
	varusr=$(who > /tmp/varusr && awk -F: '{ print $1 }' /tmp/varusr | tr -d '[[:space:]]')
	idusr=$(id -u $varusr)
	UBUNTU_VER=$(lsb_release -d | grep -o '.[0-9]*\.'| head -1|sed -e 's/\s*//'|sed -e 's/\.//')
}

install_all(){
	if [[ $UBUNTU_VER < 18 ]]; then
			echo "=========================================================="
			echo "Script no compatible con tu version de Ubuntu: $UBUNTU_VER"
			echo "=========================================================="
		fi
		
		if [[ $UBUNTU_VER = 18 ]]; then
			#falta completar
			
		fi
		
		if [[ $UBUNTU_VER = 19 ]]; then
			install_depends_19
			install_tv

		fi
		
		if [[ $UBUNTU_VER = 20 ]]; then
			#falta completar
			
		fi
	fi
}

install_tv(){
	#wget https://dl.teamviewer.com/download/linux/version_15x/teamviewer_15.5.3_amd64.tar.xz
	#tar -Jxvf teamviewer_15.5.3_amd64.tar.xz
	#./teamviewer/teamviewer

	#wget https://dl.teamviewer.com/download/linux/version_15x/teamviewer_15.5.3_amd64.deb
	wget wget https://soportedespe.000webhostapp.com/Scripts-Install-Ubuntu/dependencias-teamviewer-ubuntu/teamviewer_15.5.3_amd64.deb
	dpkg -i teamviewer_15.5.3_amd64.deb	
}

ping -c1 google.com &>/dev/null
if [[ $? -ne 0 ]] || [[ "$EUID" != 0 ]]; then
	echo "Este Script requiere sudo o no tienes conexion a internet"
	exit 1
else
	TEMPDIR=$(mktemp -d)
	cd $TEMPDIR
	install_all
fi