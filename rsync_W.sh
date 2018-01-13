#!/bin/sh

#v.000021
# Weekly rsync script


softmkdir() {
	if [ ! -d "$1" ] ; then
		mkdir "$1"
		chmod 0750 "$1"
	fi
}

do_copy() {
	# SETTINGS
	backup_dir=$1
	len=60

	src_dir="$backup_dir/d`printf "%02d" 1`"

	if [ ! -d "$src_dir" ]; then
		echo "Source directory $src_dir not found. Omitting."
		return 1
	fi

	zero_dir="$backup_dir/w`printf "%02d" 0`"
	prev_dir="$backup_dir/w`printf "%02d" 1`"
	last_dir="$backup_dir/w`printf "%02d" $len`"

	date=`date`
	echo "================================="
	echo "Starting copy: $date."
	#echo "Day of week: $dow."

	if [ -d "$zero_dir" ]; then
		echo "Rotating directories up to length of $len."

		# removing last directory
		if [ -d "$last_dir" ]; then
			rm -rf "$last_dir"
		fi

		# rotating
		for i in $(seq  $len -1 0); do
			src="$backup_dir/w`printf "%02d" $i`"
			if [ -d "$src" ]; then
				mv "$src" "$backup_dir/w`printf "%02d" $(($i+1))`"
			fi
		done
	fi

	echo "Found source daily backup. Making hard-linked copy."
	echo "Src/Dst:" "$src_dir" "$zero_dir"
	cp -al "$src_dir" "$zero_dir"
	echo "Hard-linked copy done."

	touch "$zero_dir"


	echo "Backup finished: $date."
	echo "================================="
	echo ""
}


dir_list="
	appsrv01/rsync
"

for d in $dir_list ; do
	#echo "/backup/$d"
	do_copy "/backup/$d"
done
