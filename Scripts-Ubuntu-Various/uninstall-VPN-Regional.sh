#!/bin/sh

TMP_DIR=/tmp
COMMAND_TO_RUN="/usr/bin/snx -d > /dev/null; rm -f /usr/bin/snx; rm -f /usr/bin/snx_uninstall; rm -f /usr/lib/libcpc++-libc6.1-2.so.3; rm -rf /etc/snx"

IsNotSupperUser()
{
	if [ `id -u` != 0 ]
	then
		return 0
	fi

	return 1
}

Cleanup()
{
	rm -f ${TMP_DIR}/SNX\ Uninstall
	exit 0
}

trap Cleanup 2
trap Cleanup 3
trap Cleanup 13
trap Cleanup 15

if IsNotSupperUser
then
	echo "Uninstalling SNX requires the root password"
	echo "Please provide the root password"
fi

# Change directory to ${TMP_DIR}
cd ${TMP_DIR}
ln -s `which su` SNX\ Uninstall
PATH="${PATH}:."
SNX\ Uninstall -c "${COMMAND_TO_RUN}"
STATUS=$?

if [ ${STATUS} = 0 ]
then
	echo "Uninstallation successfull"
else
	echo "Uninstallation failed"
fi

Cleanup

