#!/bin/bash

# Create a new aspel dictionary file
#--------------------------------------------------------

#----------
# Functions
#----------

# exit on error
function exit_on_error {
    echo -e "$1, exiting!"
    exit 1
}

# help
function usage {
    echo -e "\nusage: $0 -p <PATH TO TRUNK>"
    echo -e "   -h This help"
}

trap "exit_on_error '\nCaught SIGTERM/SIGINT'" SIGTERM SIGINT

# -----------------------
# Command line arguments
# -----------------------

while getopts ":h" opt; do
    case $opt in
	\?|h )
	    usage
            exit
	    ;;
	esac
done
shift $((OPTIND - 1))

# exit when not in aspell directory
if [ ! -s "suse_aspell.rws" ]; then 
    usage
    exit 1
fi

#echo "Creating new wordlist ... "

# sort/strip the wordlist to tmp file
cat suse_wordlist.txt | sort | uniq > suse_wordlist_tmp.txt || {
    exit_on_error "\nCould not sort/strip wordlist"
}

# move tmp file to wordlist
mv suse_wordlist_tmp.txt suse_wordlist.txt || {
    exit_on_error "\nCould not move temporary wordlist to final wordlist"
}

# create the new dictionary
aspell --lang=en create master ./suse_aspell.rws < suse_wordlist.txt

#echo -e "done"
echo -e "\n\nSuccessfully created a new dictionary, please commit it to the\nSVN server\n"
