#!/bin/sh

#v.000022


softmkdir() {
	if [ ! -d "$1" ] ; then
		mkdir "$1"
		chmod 0750 "$1"
	fi
}

#do_rsync() {
	# SETTINGS
	user=root
	host=appsrv01
	#rpath=/home/
	backup_dir=/backup/appsrv01/rsync
	len=30

	softmkdir "$backup_dir"

	tmpname=new
	tmp_dir="$backup_dir/$tmpname"
	zero_dir="$backup_dir/d`printf "%02d" 0`"
	prev_dir="$backup_dir/d`printf "%02d" 1`"
	last_dir="$backup_dir/d`printf "%02d" $len`"


	date=`date`
	echo "================================="
	echo "Starting backup: $date."
	#echo "Day of week: $dow."

	if [ -d "$zero_dir" ]; then
		echo "Rotating directories up to length of $len."

		# removing last directory
		if [ -d "$last_dir" ]; then
			rm -rf "$last_dir"
		fi

		# rotating
		for i in $(seq  $len -1 0); do
			src="$backup_dir/d`printf "%02d" $i`"
			if [ -d "$src" ]; then
				mv "$src" "$backup_dir/d`printf "%02d" $(($i+1))`"
			fi
		done
	fi

	if [ ! -d "$tmp_dir" ] ; then
#		echo "Warning: directory \"$tmp_dir\" does not exists."

		if [ -d "$prev_dir" ] ; then
			echo "Found previous backup. Making hard-linked copy."
			cp -al "$prev_dir" "$tmp_dir"
			echo "Hard-linked copy done."
			test -d "$tmp_dir" && touch "$tmp_dir"
		else
			echo "Previous backup not found. Creating init backup."
			softmkdir "$tmp_dir"
		fi
	else
		echo "Found temporary directory (not finished last backup), resuming it."
	fi

	# Backing up DB
	#ssh $user@$host $rpath/backup_db.sh

	echo "Starting rsync..."
#	rsync -rtzKL --delete --ignore-errors --stats -v $user@$host:$rpath "$tmp_dir"

	rsync -aH --delete --ignore-errors --numeric-ids "$@" $user@$host:/backup/ "$tmp_dir/backup"
	rsync -azH --delete --ignore-errors --numeric-ids "$@" $user@$host:/etc/ "$tmp_dir/etc"
	rsync -azH --delete --ignore-errors --numeric-ids "$@" $user@$host:/var/lib/lxc/ "$tmp_dir/lxc"
	rsync -az --delete --ignore-errors --numeric-ids "$@" $user@$host:/root/ "$tmp_dir/root"
	rsync -az --delete --ignore-errors --numeric-ids "$@" $user@$host:/var/www/ "$tmp_dir/www"
	rsync -az --delete --ignore-errors --numeric-ids "$@" $user@$host:/home/ "$tmp_dir/home"

	rsync -rtzKL --delete --ignore-errors "$@" $user@$host:/var/vmail/" "$tmp_dir/vmail"

	test -d "$tmp_dir" && touch "$tmp_dir"
	echo "Rsync done."


#	if [ $? -eq 0 ] ; then
		# moving temporary to latest
		echo "Moving temporary dir name to normal backup name."
		mv "$tmp_dir" "$zero_dir"
#	fi

	echo "Backup finished: $date."
	echo "================================="
	echo ""
#}

