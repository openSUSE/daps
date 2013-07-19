#!/bin/bash
#
# Extract translator credits from the msgid "translator-credits"
# section of a .po file
# Deals with various data variants
#
# Copyright (C) 2013 SUSE Linux Products GmbH 
#
# Authors:
# Frank Sundermeyer <fsundermeyer@opensuse.org>
# Karl Eichwalder
#

shopt -s extglob

declare -a TRANSLATORS=()
declare -a RESULTS=()
declare -a S_RESULTS=()

ME=$(basename $0)
PREFIX=""
RECORD_DELIMITER=""
SUFFIX=""

#DEFAULT DATA_DIR
DATA_DIR="."

# default sort command: remove duplicates
SORT_CMD="uniq"

#-------------------------------------------------
# Functions
#

function usage () {
    echo "
Usage: $ME [options]

--datadir             Directory with *.po files
                      Default: current directory

--delimiter           Specify a custom delimiter separating the translator
                      records
                      Default: \n

-h, --help            This help text

--prefix              Prefix to add to each translator record. Can be used to
                      add XML tags. e.g. \"<member>\"

--sort                Sort criteria. Valid values are date, name, none
                      Default: none

--suffix              Suffix to add to each translator record. Can be used to
                      add XML tags. e.g. \"</member>\"

$ME reports errors to STDERR on data records it cannot parse."
}

function exit_on_error () {
    echo "$1"
    exit 1
}

trap "exit_on_error '\nCaught SIGTERM/SIGINT'" SIGTERM SIGINT

ARGS=$(getopt -o h -l datadir:,delimiter:,help,prefix:,sort:,suffix: -n $ME -- "$@")
eval set -- "$ARGS"
while true ; do
    case "$1" in
	--datadir)
	    if [[ -d "$2" ]]; then
		# set DATA_DIR to $2 and remove trailing slash
		DATA_DIR="${2%/}"
	    else
		exit_on_error "The directory specified with --datadir does not exist"
	    fi
	    shift 2
	    ;;
	--delimiter)
	    RECORD_DELIMITER="$2"
	    shift 2
	    ;;
	--help|-h)
	    usage
	    exit 0
	    ;;
	--prefix)
	    PREFIX="$2"
	    shift 2
	    ;;
	--suffix)
	    SUFFIX="$2"
	    shift 2
	    ;;
	--sort)
	    case "$2" in
		date)
		    SORT_CMD="sort -u"
		    shift 2
		    ;;
		name)
		    SORT_CMD="sort -u -k2"
		    shift 2
		    ;;
		none)
		    SORT_CMD="uniq"
		    shift 2
		    ;;
		*)
		    exit_on_error "Wrong parameter for --sort. Use one of date, name, none"
		    ;;
	    esac
	    ;;
	--) shift ; break ;;
        *) exit_on_error "Internal error!" ;;
    esac
done

for FILE in ${DATA_DIR}/*.po; do
    TRANS=$( \
	msggrep --no-wrap -K -e "^translator-credits$" $FILE | \
	awk 'BEGIN{p=0};p==1{print};/^msgid \"translator-credits\"/{p=1;print}' | \
	msgexec cat )

    if [[ -n $RECORD_DELIMITER ]]; then
        # Split translator string at RECORD_DELIMITER and save the output in 
        # the array TRANSLATORS
        #
	OLD_IFS="$IFS"
	IFS=$"$RECORD_DELIMITER"
	read -ra TRANSLATORS <<< "$TRANS"
	IFS="$OLD_IFS"
    else
	# Split at newline and save to array
	# works, but there must be a better way - this solution looks strange
	#
	OLD_IFS="$IFS"
	IFS=$'\n'
	J=0
	for LINE in $(echo "$TRANS"); do
	    TRANSLATORS[$J]="$LINE"
	    let J++
	done
	IFS="$OLD_IFS"
    fi

    for TRANSL in "${TRANSLATORS[@]}"; do
	_RESULT=""
	#
	# Check for errors
	# Strings are ignored and an error message is printed to STDERR
        #
	# two email addresses => entries have not been separated with ";"
	egrep -sq "[^@]*@[^@]*@" <<< "$TRANS"  >/dev/null 2>&1
	if [[ 0 -eq $? ]]; then
	    echo -e "Format error in $FILE: $TRANSL" >&2
	    continue
	fi

	# Process all remaining strings 
	#
	# extract email
	#
	EMAIL=$(expr match "$TRANSL" '.*<\(.*@[^<]*\)>.*')
	if [[ -n $EMAIL ]]; then
	    # Remove email from TRANSL string
	    TRANSL=${TRANSL/*(<)${EMAIL}*(>)/}
	else
	    echo -e "$FILE: No Value for EMAIL specified" >&2
	fi

	# extract year(s)
	# expr can only handle basic regexp, so let's use egrep here
	# the regexp catches the following occurences:
        # <DATA>, YEAR
	# <DATA>,YEAR
	# <DATA> YEAR
	# <DATA>, YEAR, YEAR
	# <DATA>,YEAR, YEAR
	# <DATA>,YEAR,YEAR
	# <DATA> YEAR, YEAR
	# <DATA> YEAR-YEAR
	# <DATA> YEAR - YEAR
	# <DATA>, YEAR-YEAR
	# <DATA>,YEAR - YEAR
	# ...
	# and the same variant with with YEAR following DATA
        YEAR=$(egrep -o "([，, ] *[[:digit:]]{4}( *[，, -] *[[:digit:]]{4})?|^[[:digit:]]{4}( *[，, -] *)?([[:digit:]]{4})?)" <<< "$TRANS" )
	if [[ -n $YEAR ]]; then
	    # Remove year from TRANSL string
	    TRANSL=${TRANSL/"$YEAR"/}
	    # Make YEAR pretty
	    # remove whitespace
	    YEAR=${YEAR//[[:space:]]/}
	    # remove leading nad trailing comma
	    YEAR=${YEAR/#[，,]/}
	    YEAR=${YEAR/%[，,]/}
	    # replace remaining comma between to digits with "-"
	    YEAR=${YEAR/@(，|,)/-}
	else
	    echo -e "$FILE: No Value for YEAR specified" >&2
	fi

	# The remaining string is the name
	NAME=${TRANSL/\\\n/}
	if [[ -n $NAME ]]; then
	    # remove leading and trailing spaces
	    NAME=${NAME##+([[:space:]])}
	    NAME=${NAME%%+([[:space:]])}
	else
	     echo -e "$FILE: No Value for NAME specified" >&2
	fi

	# Data colletcion complete, create result string
	#
	[[ -n $YEAR ]] && _RESULT="${_RESULT}$YEAR, "
	[[ -n $NAME ]] && _RESULT="${_RESULT}$NAME "
	[[ -n $EMAIL ]] && _RESULT="${_RESULT}<ulink url=\\\"mailto:${EMAIL}\\\"/>"
	_RESULT="${_RESULT}"
	RESULTS+=( "$_RESULT" )
    done
done

# sort the results
OLD_IFS="$IFS"
IFS=$'\n'
S_RESULTS=($(eval "$SORT_CMD <<<\"${RESULTS[*]}\""))
IFS=$OLD_IFS

# print the results, add prefix and suffix
for LINE in "${S_RESULTS[@]}"; do 
    echo -e "${PREFIX}${LINE}${SUFFIX}"
done

exit 0
