#!/bin/bash

#preguntar datos


echo 'Ingresa tu usario de dominio:'
read varuserdom
echo 'Ingresa tu contraseña de red: '
read -s clave


search(){
	state=$(ldapsearch -E pr=1000/noprompt -LLL -o ldif-wrap=no -x -z 0 -b "dc=ar,dc=infra,dc=d" -D "$varuserdom@ar.infra.d" -h ar.infra.d -w "$clave" "sAMAccountName=$varuser" | egrep 'mail:*|physicalDeliveryOfficeName:*|userAccountControl:*|distinguishedName:*|userPrincipalName:*|memberOf:*')
	
	if [[ $? -ne 0 ]]; then
		
		state=$(ldapsearch -E pr=1000/noprompt -LLL -o ldif-wrap=no -x -z 0 -b "dc=br,dc=infra,dc=d" -D "$varuserdom@ar.infra.d" -h br-brdc7.br.infra.d -w "$clave" "sAMAccountName=$varuser" | egrep 'mail:*|physicalDeliveryOfficeName:*|userAccountControl:*|distinguishedName:*|userPrincipalName:*|memberOf:*')

		if [[ $? -ne 0 ]]; then
			state=$(ldapsearch -E pr=1000/noprompt -LLL -o ldif-wrap=no -x -z 0 -b "dc=co,dc=infra,dc=d" -D "$varuserdom@ar.infra.d" -h co.infra.d -w "$clave" "sAMAccountName=$varuser" | egrep 'mail:*|physicalDeliveryOfficeName:*|userAccountControl:*|distinguishedName:*|userPrincipalName:*|memberOf:*')
		fi

		if [[ $? -ne 0 ]]; then
			state=$(ldapsearch -E pr=1000/noprompt -LLL -o ldif-wrap=no -x -z 0 -b "dc=uy,dc=infra,dc=d" -D "$varuserdom@ar.infra.d" -h UYDC5.uy.infra.d -w "$clave" "sAMAccountName=$varuser" | egrep 'mail:*|physicalDeliveryOfficeName:*|userAccountControl:*|distinguishedName:*|userPrincipalName:*|memberOf:*')
		fi

		if [[ $? -ne 0 ]]; then
			state=$(ldapsearch -E pr=1000/noprompt -LLL -o ldif-wrap=no -x -z 0 -b "dc=cl,dc=infra,dc=d" -D "$varuserdom@ar.infra.d" -h CLDC5.cl.infra.d -w "$clave" "sAMAccountName=$varuser" | egrep 'mail:*|physicalDeliveryOfficeName:*|userAccountControl:*|distinguishedName:*|userPrincipalName:*|memberOf:*')
		fi
	fi

	echo "$state"
	var1=$(echo "$state" | grep -o "512")
	var2=$(echo "$state" | grep -o "514")
	if [[ "$var1" = 512 ]]; then
		echo '###############'
		echo 'Usuario Activo' 
		echo '###############'
	else
		if [[ "$var2" = 514 ]]; then
			echo '####################'
			echo 'Usuario Desactivado'
			echo '####################'
		fi

		if [[ "$var2" -ne 514 ]]; then
			echo '####################'
			echo 'Estado no definido'
			echo '####################'
		fi
	fi

}

searchmail(){
	state=$(ldapsearch -E pr=1000/noprompt -LLL -o ldif-wrap=no -x -z 0 -b "dc=ar,dc=infra,dc=d" -D "$varuserdom@ar.infra.d" -h ARDC1.ar.infra.d -w "$clave" "mail=$varuser" | egrep 'sAMAccountName:*|physicalDeliveryOfficeName:*|userAccountControl:*|distinguishedName:*|userPrincipalName:*|memberOf:*')
	
	if [[ $? -ne 0 ]]; then
		
		state=$(ldapsearch -E pr=1000/noprompt -LLL -o ldif-wrap=no -x -z 0 -b "dc=br,dc=infra,dc=d" -D "$varuserdom@ar.infra.d" -h br-brdc7.br.infra.d -w "$clave" "mail=$varuser" | egrep 'sAMAccountName:*|physicalDeliveryOfficeName:*|userAccountControl:*|distinguishedName:*|userPrincipalName:*|memberOf:*')

		if [[ $? -ne 0 ]]; then
			state=$(ldapsearch -E pr=1000/noprompt -LLL -o ldif-wrap=no -x -z 0 -b "dc=co,dc=infra,dc=d" -D "$varuserdom@ar.infra.d" -h CODC3.co.infra.d -w "$clave" "mail=$varuser" | egrep 'sAMAccountName:*|physicalDeliveryOfficeName:*|userAccountControl:*|distinguishedName:*|userPrincipalName:*|memberOf:*')
		fi

		if [[ $? -ne 0 ]]; then
			state=$(ldapsearch -E pr=1000/noprompt -LLL -o ldif-wrap=no -x -z 0 -b "dc=uy,dc=infra,dc=d" -D "$varuserdom@ar.infra.d" -h UYDC5.uy.infra.d -w "$clave" "mail=$varuser" | egrep 'sAMAccountName:*|physicalDeliveryOfficeName:*|userAccountControl:*|distinguishedName:*|userPrincipalName:*|memberOf:*')
		fi

		if [[ $? -ne 0 ]]; then
			state=$(ldapsearch -E pr=1000/noprompt -LLL -o ldif-wrap=no -x -z 0 -b "dc=cl,dc=infra,dc=d" -D "$varuserdom@ar.infra.d" -h CLDC5.cl.infra.d -w "$clave" "mail=$varuser" | egrep 'sAMAccountName:*|physicalDeliveryOfficeName:*|userAccountControl:*|distinguishedName:*|userPrincipalName:*|memberOf:*')
		fi
	fi

	echo "$state"
	var1=$(echo "$state" | grep -o "512")
	var2=$(echo "$state" | grep -o "514")
	if [[ "$var1" = 512 ]]; then
		echo '###############'
		echo 'Usuario Activo' 
		echo '###############'
	else
		if [[ "$var2" = 514 ]]; then
			echo '####################'
			echo 'Usuario Desactivado'
			echo '####################'
		fi

		if [[ "$var2" -ne 514 ]]; then
			echo '####################'
			echo 'Estado no definido'
			echo '####################'
		fi
	fi

}

pregunta(){

	echo '¿Que deseas hacer?'
	echo '=================='
	echo '---------------------------------Opciones---------------------------------'
	echo '1 - Consulta por usuario'
	echo '2 - Consulta por lista'
	echo '=============================='
	read opcion
}

cond='y'
while [[ $cond = 'y' || $cond = 'yes' ]]; do
	clear
	pregunta

	case $opcion in
		1)
			clear
			echo '¿Cómo deseas consultar?'
			echo '=================='
			echo '---------------------------------Opciones---------------------------------'
			echo '1 - Nombre de usuario de red'
			echo '2 - Consulta por mail'
			echo '=============================='
			read op

			case $op in
				1)
					echo 'Coloque el usuario de red que desea consultar:'
					read varuser

					search
				;;
				2)
					echo 'Coloque el mail que desea consultar:'
					read varuser

					searchmail
			esac
		;;
		2)
			file="bajas_usuarios.txt"
			IFS=$'\n'
			#unset varuser	
			for varuser in $(cat $file | awk 'NF' | awk '{$1=$1;print}'); do
				echo "_____________________________________________________"
				echo ' '
				search
				echo "====================================================="
			done
		;;
		*)
			echo 'Opcion incorrecta'
			echo '================='
		;;			
	esac

	echo '¿Desea realizar otra consulta?:(y/n)'
	read cond

done
clear
echo '============================='
echo ' --------------------------'
echo '| Gracias por tu consulta! |'
echo ' --------------------------'
echo '============================='