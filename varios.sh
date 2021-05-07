varadm=$(who | awk 'FNR == 1 {print $1}' | tr -d '[[:space:]]')
echo '*+54#B6RVN73*' | su - admindesp -c "echo '*+54#B6RVN73*' | sudo -S adduser $varadm sudo"


_____________________________________________________________________________________________________
sudo apt-get install ecryptfs-utils cryptsetup -y

sudo adduser --encrypt-home --force-badname nombredeusuario

sudo adduser franklin.gedler sudo

printf "%s" "Laclave12345" | ecryptfs-add-passphrase --fnek     ###### esto tengo que averiguar para que sirve 

sudo su - franklin.gedler -c "ecryptfs-unwrap-passphrase /home/.ecryptfs/franklin.gedler/.ecryptfs/wrapped-passphrase"   #### ejecuta el comando como franklin.gedler

echo username:new_password | sudo chpasswd   ###cambia la passwrd


adduser --disabled-password --gecos "" nombredeusuario


echo -e "$password\n$password\n" | sudo passwd $user    #### No se si funciona

useradd -m -p $(openssl passwd -1 ${PASSWORD}) -s /bin/bash -G sudo ${USERNAME}    #### no se si funciona


__________________________________________________________________________________________________--

sudo adduser --encrypt-home --force-badname --disabled-password --gecos "" nombredeusuario

echo username:new_password | sudo chpasswd   ###cambia la passwrd

sudo su - franklin.gedler -c "printf "%s" "Despegar.com" | ecryptfs-unwrap-passphrase /home/.ecryptfs/franklin.gedler/.ecryptfs/wrapped-passphrase"
_______________________________________________________________________________________________________

Opcion 1    ##### recomandado #######

###Para montar la carpeta home privada en otro linux:
sudo ecryptfs-recover-private /media/franklin/Debemos_buscar_que_numero_es/home/.ecryptfs/$varusr/.Private
Try to recover this directory? [Y/n]: Y
Do you know your LOGIN passphrase? [Y/n]
    - Si ingresamos Y debemos despues ingresar la password de usuario (la Password que usa para loguearse en su usuario la password de inicio de session)
    - Si ingresamos n debemos despues ingresar el password de backup que se genero al momento de crear el home del usuario encriptado, example 7f4717cc2a69ec7a4363285e8875c41f


si falla ejecutar sudo ecryptfs-manager luego sales presionando 4

###############################################################################################

Opcion 2

- Teniendo la password de la salida del comando esta password la debemos tener respaldada en glpi o por mail:
sudo su - franklin.gedler -c "ecryptfs-unwrap-passphrase /home/.ecryptfs/franklin.gedler/.ecryptfs/wrapped-passphrase"
    Salida: abd2b005fb83f1d3ba57e442a3988b53

- ahora la agregarmos al repositorio de password del kernel
    sudo printf "%s" "abd2b005fb83f1d3ba57e442a3988b53" | ecryptfs-add-passphrase --fnek

    Salida: Inserted auth tok with sig [7cb1a0953442bdcc] into the user session keyring
            Inserted auth tok with sig [e4ef5ac79b10f506] into the user session keyring
    De la salida ponemos siempore atencion al segundo codigo en este caso e4ef5ac79b10f506


# monto el disco con la password
    example: sudo mount -t ecryptfs PATH_Disco_Encriptado Path_carpeta_Desencriptado
- sudo mount -t ecryptfs /media/franklin/e4aa3bf4-23bf-46c5-b838-f42c35b12238/home/.ecryptfs/franklin.gedler/.Private /home/franklin/Documentos/discodesisfrado/

    Te va a solicitar el passphrase; el cual es la clave de inicio de sesion del usuario encriptado
    en el menu interactivo seleccionamos:
    1) aes
    1) 16
    enable plaintext: n
    Enable filename encryption y
    Filename Encryption Key (FNEK) Signature (Aqui pegamos el segundo codigo, ejemplo e4ef5ac79b10f506)

Con esto deberia de montarse, puede ejecutar sudo nautilus para abrir el visor de archivos grafico asi respaldar
lo que se necesite.

__________________________________________________________________________________________________


varusr='toto.tota'
key='Despegar.com'

#ecryptfs-unwrap-passphrase /home/.ecryptfs/$varusr/.ecryptfs/wrapped-passphrase $key | tr -d '[[:space:]]' 2>&1> passeCryptfs.txt
#cat -s $TEMPDIR/passeCryptfs.txt 1> file.txt
#passfile=$(cat file.txt)

passfile=$(ecryptfs-unwrap-passphrase /home/.ecryptfs/$varusr/.ecryptfs/wrapped-passphrase $key | tr -d '[[:space:]]')

#chown admindesp:admindesp passeCryptfs.txt



#ecryptfs-unwrap-passphrase /home/.ecryptfs/$varusr/.ecryptfs/wrapped-passphrase $key | tr -d '[[:space:]]' > passeCryptfs.txt
#passfile=$(cat -s $TEMPDIR/passeCryptfs.txt)


echo $passfile

________________________________________________-

<<!
	cat > file << EOF
	#!/bin/bash
	echo "$key" | su - "$varusr" -c "printf "%s" "$key" | ecryptfs-unwrap-passphrase /home/.ecryptfs/$varusr/.ecryptfs/wrapped-passphrase" > $TEMPDIR/file
EOF
	chmod +x file
	chown $idusr:$idusr file
	./file
	$passeCryptfs=$(sudo cat $TEMPDIR/file)
	
!











