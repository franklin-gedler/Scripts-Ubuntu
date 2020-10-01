#!/bin/bash

# ejecutarlo como ROOT
if [[ "$EUID" != 0 ]]; then
	echo "Este Script requiere root"
	exit
else

	TEMPDIR=`mktemp -d`
	cd $TEMPDIR
	wget https://soportedespe.000webhostapp.com/job-linux/libopts25-amd64.deb
	wget https://soportedespe.000webhostapp.com/job-linux/sntp-amd64.deb
	dpkg -i libopts25-amd64.deb
	dpkg -i sntp-amd64.deb
    sntp -sS ar.infra.d
	hwclock --systohc

	echo "####################################################################"
	echo "                    Preparando instalacion . . ."
	echo "####################################################################"

	varusr=$(who > /tmp/varusr && awk -F: '{ print $1}' /tmp/varusr | tr -d '[[:space:]]')
	idusr=$(id -u $varusr)

	cd /etc/apt/
	mv sources.list sources.list.old
	wget https://gist.githubusercontent.com/h0bbel/4b28ede18d65c3527b11b12fa36aa8d1/raw/314419c944ce401039c7def964a3e06324db1128/sources.list

	# Actualiza repo!!
	apt-get update

	# instalo paquetes
	apt-get install -y samba smbclient nfs-common cifs-utils

	echo "____________________________________________________________________"

	echo "#####################################################################"
	echo "                       Configurando Job"
	echo "#####################################################################"

	mkdir /var/job-all
	chmod -R 777 /var/job-all

	cat > /var/job-all/job-root.sh << 'EOF'
	#!/bin/bash
    varusr=$(who > /tmp/varusr && awk -F: '{ print $1}' /tmp/varusr | tr -d '[[:space:]]')
    dirchrome="/home/$varusr/.config/google-chrome"
    cd $dirchrome
    cp 'Local State' /tmp/
    cd /tmp/
    mv 'Local State' Local-State
    varmail=$(egrep -oi "[A-Za-z0-9._%+-]+@[despegar]+\.com" Local-State)
    varserial=$(/usr/sbin/dmidecode -s system-serial-number)
    mount -t cifs //10.254.112.31/software/MacOS/testeando-no-Usar/E-mail-Serial /mnt -o user=soporte,pass=Fantasma23*
    echo "$varmail ; $varserial" >> /mnt/serial-mail.txt
    umount /mnt/
    version: 0
EOF

	chmod 777 /var/job-all/job-root.sh

	cat > /var/job-all/update-job.sh << 'EOF'
	#!/bin/bash

	TEMPDIR=`mktemp -d`
	cd $TEMPDIR

	#new version
	wget https://soportedespe.000webhostapp.com/job-linux/job-root.sh

	# Compruebo la version del job Descargado
	var1=$(grep -i "version:.*" job-root.sh)
	newversion=$(echo "$var1" | sed "s/version://" | tr -d '[[:space:]]')

	echo "_____________________________________________________________________________"

	# Compruebo la version del job en el equipo
	var2=$(grep -i "version:.*" /var/job-all/job-root.sh)
	currentversion=$(echo "$var2" | sed "s/version://" | tr -d '[[:space:]]')

	if [[ "$newversion" > "$currentversion" ]]; then
		cd $TEMPDIR
		cp job-root.sh /var/job-all/
		chmod 777 /var/job-all/job-root.sh
		echo "Actualizacion Realizada"
	else
		echo "No existe actualizaciones pendientes"
	fi

	###################################################################################

	#Actualizacion del crontab
	cd $TEMPDIR

	# compruebo el archivo descargado
	wget https://soportedespe.000webhostapp.com/job-linux/jobnew
	jobnew=$(cat jobnew)

	# Compruebo el archivo de crontab
	#jobused=$(crontab -l | grep -io '.*/var/job-all/job-root.sh')

	if [[ "$jobnew" != "$jobused" ]];then

		crontab -l | sed '/job-root/d' | crontab -
		(crontab -u root -l; echo "$jobnew") | crontab -u root -
		echo "Nueva tarea programada"
	else
		echo "No hay programacion nueva"
	fi

EOF
	
	chmod 777 /var/job-all/update-job.sh

	jobroot="* * * * * /var/job-all/job-root.sh"
	(crontab -u root -l; echo "$jobroot") | crontab -u root -

	updatejob="*/2 * * * * bash /var/job-all/update-job.sh"
	(crontab -u root -l; echo "$updatejob") | crontab -u root -

	echo "____________________________________________________________________"
fi
