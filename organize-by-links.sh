#!/bin/bash

die () {
	echo >&2 "$@"
	echo "Usage $0 my_video_folder"
	exit 1
}

[ "$#" -eq 1 ] || die "1 argument required, $# provided"

[ -d "$1" ] || die "Directory must exists, $1 provided"

# root directory of video files (remove trailing slash)
export DIR="${1%/}"
# directory for ALL files
#export ALL="$DIR/01_ALL"
# directory for NEW files
export NEW="$DIR/02_NEW"
# directory for alpha nums directories
export ALPHANUM="$DIR/03_BY_LETTER"
# how many days before a file is not considered NEW
export NEW_DAYS=60
# how many alpha/numeric directory do you want
export NB_ALPHANUM_DIRS=10
# movie file pattern
export MOVIE_FILE_PATTERN='mkv|avi|iso'

#
# DO NOT EDIT BELOW
#


link_files () {
	
	# split base
	filename=$(basename "$1")
	filename="${filename%.*}"
		
	find -L "$DIR" -maxdepth 1 -type f -iname "$filename*" -exec ln -sf -t "$2" {} \;
	echo "linking $filename into $2"
}
# export functions
typeset -fx link_files




#if [ ! -d "$ALL" ]; then
#	mkdir "$ALL"
#fi

if [ ! -d "$NEW" ]; then
	mkdir "$NEW"
fi

if [ ! -d "$ALPHANUM" ]; then
	mkdir "$ALPHANUM"
fi

#
# identify meta files that are not replicated into base directory
#
find "$NEW" -type f -exec cp -t "$DIR" {} \;
find "$ALPHANUM" -type f -exec cp -t "$DIR" {} \;

#
# identify new files
#
rm "$NEW/"* # cleanup old files

find -L "$DIR" -mtime -$NEW_DAYS -type f -regextype posix-extended -regex ".*($MOVIE_FILE_PATTERN)" -exec bash -c '
	link_files "$0" "$NEW"
' {} ';'

#
# order by AlphaNum directories
#

# count movie files
rm -r "$ALPHANUM/"* # cleanup alphanum directories

NB=`find -L "$DIR" -maxdepth 1 -type f -regextype posix-extended -regex ".*($MOVIE_FILE_PATTERN)" -exec printf '.' \; | wc -c`
echo "We have found $NB video files"

# divide by nb dirs wanted  and round result
NB_TRUNK=`expr $NB / $NB_ALPHANUM_DIRS + 1`
echo "We will have approx $NB_TRUNK files by directory"

CUR_DIR='0'
CUR_NB=0
CUR_TOTAL=0

export TMP_DIR=`mktemp -d`

for letter in {{0..9},{A..Z}}; do
	CUR_NB=`find -L "$DIR" -maxdepth 1 -type f -iname "$letter*" -regextype posix-extended -regex ".*($MOVIE_FILE_PATTERN)" -exec printf '.' \; | wc -c`
	echo "$CUR_NB videos files start by $letter"
	
	CUR_TOTAL=`expr $CUR_TOTAL + $CUR_NB`

	# identify files with $letter as first character and link them into tmp dir
	find -L "$DIR" -maxdepth 1 -type f  -iname "$letter*" -regextype posix-extended -regex ".*($MOVIE_FILE_PATTERN)" -exec bash -c '
		link_files "$0" "$TMP_DIR"
	' {} ';'
	
	if [ "$CUR_TOTAL" -gt "$NB_TRUNK" -o $letter == 'Z' ]; then
		echo "$CUR_DIR - $letter (#$CUR_TOTAL)"
		
		LETTER_RANGE_DIR="$ALPHANUM/$CUR_DIR-$letter [$CUR_TOTAL]"
		
		mkdir -p "$LETTER_RANGE_DIR"
		# move collected files
		mv "$TMP_DIR/"* "$LETTER_RANGE_DIR/"
		CUR_DIR=$letter
		CUR_TOTAL=0
	fi
done

rmdir "$TMP_DIR"




