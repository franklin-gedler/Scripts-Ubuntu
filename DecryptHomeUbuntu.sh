#!/bin/bash

info() {
	echo "INFO: $@"
}

error() {
	echo "ERROR: $@" 1>&2
	#exit 1
}
echo
echo "                Script Creado por Franklin Gedler"
echo "                        Soporte Argentina        "
echo

ping -c1 google.com &>/dev/null
if [[ $? -ne 0 ]] || [[ "$EUID" != 0 ]]; then
	echo " ###############################################################"
	error " Este Script requiere sudo o no tienes conexion a internet"
	echo " ###############################################################"
	exit 1
else
    
    apt-get update
    apt-get install ecryptfs-utils cryptsetup -y

    if [[ $? != 0 ]]; then
        echo
        error " No se puede descargar ni instalar lo necesario "
        echo
        exit
    fi
    
    varusr=$(who | awk 'FNR == 1 {print $1}' | tr -d '[[:space:]]')

    pathmedia=$(ls /media/$varusr)

    pathusr=$(ls /media/$varusr/$pathmedia/home/.ecryptfs/)

    pathfull="/media/$varusr/$pathmedia/home/.ecryptfs/$pathusr/.Private"

    #sudo ecryptfs-recover-private /media/$varusr/$pathmedia/home/.ecryptfs/$pathusr/.Private

    echo " ______________________________________________________________________________________ "
    echo
    echo -n "  Ingrese la Password Backup de Soporte:  "   #### Escribe el ingreso de teclado despues de los (:) dos puntos
    stty_orig=$(stty -g)
    passphrase=$(head -n1 | tr -d '[[:space:]]')
    stty $stty_orig
    echo

    # ro permisos de solo lectura 
    # rw permisos de escritura
    opts="ro"

    ls "$pathfull/ECRYPTFS_FNEK_ENCRYPTED"* >/dev/null 2>&1 && fnek="--fnek" || fnek=

    sigs=$(printf "%s\0" "$passphrase" | ecryptfs-add-passphrase $fnek | awk 'FNR > 1 {print $6}' | tr -d '[]')

    mount_sig=$(echo "$sigs" | head -n1)
    fnek_sig=$(echo "$sigs" | tail -n1)

    mount_opts="$opts,ecryptfs_sig=$mount_sig,ecryptfs_fnek_sig=$fnek_sig,ecryptfs_cipher=aes,ecryptfs_key_bytes=16"

    tmpdir=$(mktemp -d /tmp/ecryptfs.XXXXXXXX)

    mount -i -t ecryptfs -o "$mount_opts" "$pathfull" "$tmpdir"

    if [[ -r $tmpdir/.profile ]]; then
        echo
        info " Success!  Datos privados montados en [$tmpdir]. "
        echo
        nohup nautilus -w $tmpdir > /dev/null 2>&1 &
    else
        echo
        error " No se pudo montar los datos Encriptados, verificar el Password Backup de Soporte "
        echo
    fi


fi









