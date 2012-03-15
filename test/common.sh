#
# Common functions to be sourced in testing.sh
# (C) 2012 Thomas Schraitle <toms@opensuse.org>

# ----------------------------------------------------------------------------
# Global Variables
#
# Default path to logfile:
LOGFILE="/tmp/daps-testing.log"
# Main file to include shunit2
SHUNIT2SRC="/usr/share/shunit2/src/shunit2"
# Remove temporary directory? 0=no, 1=yes
DELTEMP=1
# Logging actions to $LOGFILE? 0=no, 1=yes
LOGGING=1


# ----------------------------------------------------------------------------
# Functions

# ---------
# Verbose error handling
#
exit_on_error () {
# Synopsis:
#   $1 error message
# Examples:
#   exit_on_error "This was bad :-("
# Returns:
#   Outputs the string on stderr
#
    echo "ERROR: ${1}" 1>&2
    exit 1;
}

# ---------
# Logs a message in $LOGFILE when $LOGGING is != 0
#
logging() {
# Synopsis:
#   $1 optional result from assert* functions
#   $2 message
# Examples:
#   logging 0 "Found x"
#   logging "Hello World"
# Returns:
#   Nothing, but writes message into $LOGFILE
#
  if [[ $LOGGING -ne 0 ]]; then
   if [[ $# -eq 2 ]]; then
     local RESULT=$1
     local MSG=$2
   elif [[ $# -eq 1 ]]; then
     local RESULT=0
     local MSG=$1
   else
     exit_on_error "Wrong number of arguments in logging()"
   fi

    DATE=$(date +"[%d-%m-%YT%H:%M:%S]")
    if [[ $RESULT -eq 0 ]]; then
      echo "$DATE: $MSG" >> $LOGFILE
    else
      echo "$DATE: [ERROR] $MSG" >> $LOGFILE
    fi
  fi
}



# Short test, if shunit2 is available
[[ -f $SHUNIT2SRC ]] || exit_on_error "No shunit2 package found! :-(("

# EOF