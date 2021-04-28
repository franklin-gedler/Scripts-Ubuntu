

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

Opcion 1

###Para montar la carpeta home privada en otro linux:
sudo ecryptfs-recover-private /media/franklin/e4aa3bf4-23bf-46c5-b838-f42c35b12238/home/.ecryptfs/franklin.gedler/.Private
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












