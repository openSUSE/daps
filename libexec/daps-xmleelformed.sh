#!/bin/bash
# Check wellformedness of a document, including its XIncludes.
# $1 - Document to check
# Error codes:
# - 1  = general error
# - 10 = input file does not exist
# - 20 = dependent files do not exist/there are wellformedness issues


code=0
log=

checked=
todo=


brexit() {
  # $1 - message
  # $2 - error code
  echo -e "error: $1"
  [[ "$2" =~ ^[0-9]+$ ]] && exit "$2"
  exit 1
}

lint() {
  # $1 - file to check
  checked+="$1\n"
  [ ! -f "$1" ] && { log+="error: File $infile does not exist\n"; code=20; return 1; }
  local messages
  messages=$(xmllint --noout --noent --nonet "$1" 2>&1)
  [ -n "$messages" ] && { log+="$messages\n"; code=20; return 1; }
  return 0
}

find_includes() {
  # $1 - file to find includes in
  local includes
  # FIXME: unsolved issues:
  # - recognize empty href attributes
  # - handle symlinks without going into an endless circle
  # - deal with protocols & non-Unix file systems (https://, file:, C:\\)
  includes=$(xml sel -N xi="http://www.w3.org/2001/XInclude" \
    -t -v '//xi:include/@href' "$1" | sed -r 's,^[^/],'"$indir"'/&,')
  [ -z "$includes" ] && return 0
  [ -z "$todo" ] && { todo=$(comm -1 -3 <(filter "$checked") <(filter "$todo\n$includes")); return 1; }
  todo=$(comm -1 -3 <(filter "$checked") <(filter "$todo\n$includes"))
}

update_todos() {
  #1 - line to remove
  local todo_temp
  todo_temp=
  # this seemed the safest option to handle file names, as it does not
  # involve regexes; probably slows us down, however
  while read -r line; do
    [[ "$line" != "$1" ]] && todo_temp+="$line\n"
  done < <(echo -e "$todo")
  todo=$(filter "$todo_temp")
}

filter() {
  # $1 - string to filter
  echo -en "$1" | sort -u
}


infile=$(realpath "$1")
indir=$(dirname "$infile")


[ ! -f "$infile" ] && brexit "error: Input file $infile does not exist" 10

todo="$infile"
while [ -n "$todo" ]; do
  next=$(echo -e "$todo" | head -1)
  lint "$next" && find_includes "$next"
  update_todos "$next"
done

[[ $code -gt 0 ]] && echo -e "$log\nThere were errors. (code $code)"
exit $code
