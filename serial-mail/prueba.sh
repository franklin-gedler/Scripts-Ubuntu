#!/bin/bash

#var1='dn: cn=dbagrp,ou=groups,dc=tgs,dc=com
#changetype: modify
#add: memberuid
#memberuid: adam'

#echo "$var1"

vardn='ar.infra.d'
varusr='franklin.diaz'

head -c -1 << EOF > ./file1.ldif
dn: $vardn
changetype: modify
add: memberuid
memberuid: $varusr
EOF

cat file1.ldif

