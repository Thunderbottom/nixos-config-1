#!/usr/bin/env bash
if [ $EUID -ne 0 ]; then
	echo "This script must be run as root"
	exit 1
fi

if [[ "$1" == "mount" ]] || [ -z "$1" ] ; then
	echo -n $(doas -u vin passrs show Uncategorized/Backup/password) | cryptsetup open \
		--type tcrypt \
		--veracrypt \
		/dev/disk/by-id/usb-WD_My_Book_25EE_575834314439375233413344-0:0-part1 backup -d - 

	if [ $? -ne 0 ] ; then
		echo "Could not open the volume. Wrong password?"
		exit 1
	fi

	mount /dev/mapper/backup /backup

	if [ ! -f /backup/.mounted ]; then
		echo "Something went wrong while mounting"
		exit 1
	fi
elif [[ "$1" == "unmount" || "$1" == "umount" ]]; then
	umount /backup

	while [ -f /backup/.mounted ]; do
		sleep 1
	done

	cryptsetup close backup
else
	echo "Choose \`mount\` or \`unmount\` (\`umount\`)"
	exit 1
fi
