#!/bin/bash

# Con este pequeño codigo podemos autodestruir cualquier Script que ejecutemos

# el codigo genera un segundo Script el cual es el encargado de borrar el primero

# Dentro del Script que queremos AutoDestruir, al principio (La mejor posicion) debemos
# definir una palabra clave la cual va ser buscada por el segundo Script, en este caso 
# la palabra que definimos es por ejemplo Prepare-MacOS.sh

# esta es la palabra clave que usamos, puedes usar otra palabra, lo ideal es que sea una palabra
# NO comun Ej: MaricoElQueLoLea jajaja, y por obvia razones debe estar como un comentario.

# Capturo el PATH donde se esta alojado el Script, esto lo tengo que pegar al principio de
# Cualquier Script
DirHost=$(pwd)

# Creo un Directorio Temporal
TEMPDIR=`mktemp -d`
cd $TEMPDIR

# Escribo dentro de un archivo el contenido de la variable
echo "$DirHost" > DirHost

# Genero el Script auxiliar el cual se va a encargar de borrar el Script de donde es llamado
cat > $TEMPDIR/aux.sh << 'EOF'
# Leo el contenido del archivo y su valor lo almaceno en una variable
DirHost=$(cat DirHost)

# Comando de la magia, apartir del contenido de $DirHost el cual es el PATH donde esta,
# el Script que queremos auto-destruir, buscamos la palabra Prepare-Macos.sh o la palabra que
# definamos como patron de busqueda, por eso definir esa palabra es fundamental para que el
# comando siguiente detecte la palabra y a su vez extraiga el PATH completo con el nombre del Script
PathFile=$(egrep -r 'Prepare-MacOS.sh' $DirHost | awk -F: 'FNR == 1 {print $1}')

# Ya sabiendo el PATH completo lo procedemos a borrar
rm -rf $PathFile
EOF

# Damos permisos al Script aux que es el encargado de borrar al principal
chmod +x aux.sh

# finalmente lo llamamos si o si con ./ ya que sino nos genera problemas
./aux.sh

# Siempre salimos del principal
exit
