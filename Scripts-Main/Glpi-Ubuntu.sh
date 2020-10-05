#!/bin/bash
#GlpiUbuntu

ping -c1 glpi.despegar.it &>/dev/null
if [[ $? -ne 0 ]] || [[ "$EUID" != 0 ]]; then
	echo " ###################################################################"
	echo " Este Script requiere sudo o no estas conectado a la RED de Despegar"
	echo " ###################################################################"
	exit 1
else
	DirHost=$(pwd)
	TEMPDIR=`mktemp -d`
	cd $TEMPDIR
	pwd
	echo "$DirHost" > DirHost
    ##########################################################################################################
	#----------------------------------------------------------------------------------
	# Esta dependencia libwrite-net-perl no es encontrada en los repos de ubuntu 18,
	# esa dependencia, segun el portal de instalacion, sirve para enviar un encendido al equipo por LAN (WakeOnLan)
	#----------------------------------------------------------------------------------

	# Install Dependencias
	apt-get update
	apt-get install -y dmidecode hwdata ucf hdparm perl libuniversal-require-perl libwww-perl libparse-edid-perl \
	libproc-daemon-perl libfile-which-perl libhttp-daemon-perl libxml-treepp-perl libyaml-perl libnet-cups-perl libnet-ip-perl \
	libdigest-sha-perl libsocket-getaddrinfo-perl libtext-template-perl libxml-xpath-perl libyaml-tiny-perl \
	libnet-snmp-perl libcrypt-des-perl libnet-nbname-perl libdigest-hmac-perl libfile-copy-recursive-perl libparallel-forkmanager-perl gdebi-core
	
	if [[ $? != 0 ]]; then

		echo "-------------------------------------------------------"
		echo "|Problemas para instalar Dependencias, verificar repos|"
		echo "-------------------------------------------------------"
		exit
	else
		
		# Download .deb
		wget https://github.com/fusioninventory/fusioninventory-agent/releases/download/2.5.2/fusioninventory-agent_2.5.2-1_all.deb
		wget https://github.com/fusioninventory/fusioninventory-agent/releases/download/2.5.2/fusioninventory-agent-task-collect_2.5.2-1_all.deb
		wget https://github.com/fusioninventory/fusioninventory-agent/releases/download/2.5.2/fusioninventory-agent-task-network_2.5.2-1_all.deb
		wget https://github.com/fusioninventory/fusioninventory-agent/releases/download/2.5.2/fusioninventory-agent-task-deploy_2.5.2-1_all.deb
		wget https://github.com/fusioninventory/fusioninventory-agent/releases/download/2.5.2/fusioninventory-agent-task-esx_2.5.2-1_all.deb


		#Install Packets
		gdebi -n fusioninventory-agent_2.5.2-1_all.deb
		gdebi -n fusioninventory-agent-task-collect_2.5.2-1_all.deb
		gdebi -n fusioninventory-agent-task-network_2.5.2-1_all.deb
		gdebi -n fusioninventory-agent-task-deploy_2.5.2-1_all.deb
		gdebi -n fusioninventory-agent-task-esx_2.5.2-1_all.deb

		# Config.
		echo ""
		echo "========================================"
		echo "            Configurando . . .          "
		echo "========================================"
		sed -i "14i server = https://glpi.despegar.it/plugins/fusioninventory/" /etc/fusioninventory/agent.cfg
		systemctl restart fusioninventory-agent
		#systemctl reload fusioninventory-agent
		#service fusioninventory-agent start
		sleep 15
		systemctl status fusioninventory-agent.service
		echo ""
		echo "==========================================================="
		echo "  Ejecutando por primera vez . . . (Espere . . . )         "
		echo "==========================================================="
		pkill -USR1 -f -P 1 fusioninventory-agent
		sleep 20

		echo ""
		echo "                      ============"
		echo "                          LISTO"
		echo "                      ============"
		echo "-------------------------------------------------------"
		echo "           fusioninventory-agent instalado"
		echo "-------------------------------------------------------"
	fi
	##########################################################################################################
    cat > $TEMPDIR/aux.sh << 'EOF'
	DirHost=$(cat DirHost)
	PathFile=$(egrep -r 'GlpiUbuntu' $DirHost | awk -F: 'FNR == 1 {print $1}')
	rm -rf $PathFile
EOF
	chmod +x aux.sh
	./aux.sh
	exit
fi