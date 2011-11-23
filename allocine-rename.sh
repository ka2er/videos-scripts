#!/bin/bash

# requirements
#
# wget
# let (test si numerique)


#echo "Fetching allocine page : $ALLOCINE_URL"


# set la variable film
# @param id allocine
# @return film
allocine_id_to_name() {
	local id=$1 # id is first param
	
	#echo "Finding film name for allocine id $id"
	
	ALLOCINE_URL="http://iphone.allocine.fr/film/fichefilm_gen_cfilm=$id.html"

	# 1 - recupere la fiche du film en se faissant passer pour un navigateur
	# 2 - recupere la ligne HTML qui presente le titre du film
	# 3 - extrait de la balise B le nom du film
	local film=$(wget $ALLOCINE_URL -U Mozilla/5.0 -q -O - | grep 'class="titre"' | iconv --from-code=ISO-8859-1 | awk -F"<[/]?b>" ' {print $2} ')
	echo $film
}

# @param string file_name
standardize_file_name(){
	local file=$1
	local search="' : , \."

	for char in $search; do
		file=$(echo $file | sed -e s/$char/-/gi)
	done

        # les accents E
        local search="é ë ê"
        for char in $search; do
                file=$(echo $file | sed -e s/$char/e/gi)
        done

        # les lettre à
	file=$(echo $file | sed -e s/à/a/gi)

        # et les espaces	
	file=$(echo $file | sed -e s/\ /-/gi)

	echo $file
}

# @param string file_name
extract_allocine_id(){
	echo $1 | sed 's/.*ac\([0-9]*\).*/\1/'
}

get_file_extension(){
	echo $1 |awk -F . '{print $NF}'
}

## help
if [ $# -lt 1 ]; then
	echo ""
	echo "Usage :"
	echo "Automatic mode"
	echo "	$0 film_file_to_rename.avi "
	echo ""
	echo "Manual mode (id forced)"
	echo "	$0 film_file_to_rename.avi allocineid"
	echo ""
	exit
fi


## main prog

# nom du fichier a renommer
file=$1

if [ $# -eq 2 ]; then
	id=$2
else
	echo "Try to guess allocine film id (2nd line argument could be ID...)"
	id=$(extract_allocine_id "$file")
fi

# verifie que l'id trouve est numérique
if ! let $id 2>/dev/null; then
	echo "Unable to found allocine ID : aborting !!"
	exit
fi


echo "allocine ID used : $id" 


film=$(allocine_id_to_name $id)
echo "film name retrieved from allocine : $film"

file_name=$(standardize_file_name "$film")

ext=$(get_file_extension "$file")
file_name="$file_name.$ext"
echo "renamming proposition : $file => $file_name"

mv "$file" "$file_name"
