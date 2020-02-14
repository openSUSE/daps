#!/bin/bash
# Check wellformedness of a document, including its XIncludes.
# $1 - Document to check
# Error codes:
# - 1  = general error
# - 10 = input file does not exist
# - 20 = dependent files do not exist/there are wellformedness issues


code=0

todo=


find_includes() {
  # $1 - file to find includes in
  local includes
  local new_todo
  # FIXME: unsolved issues:
  # - (explicitly) recognize empty href attributes -- we should be outputting
  #   a file error already though
  # - handle symlinks without going into an endless circle
  # - deal with protocols & non-Unix file systems (https://, file:, C:\\)

  # xmlstarlet has the same error code (1) for "bad entity" and for "no xinclude" :(
  includes=$(xml sel -N xi="http://www.w3.org/2001/XInclude" \
    -t -v '//xi:include/@href' "$1" 2>/tmp/eelform)
  [[ -n $(<"/tmp/eelform") ]] && { cat "/tmp/eelform"; code=20; }
  [ -z "$includes" ] && return 0
  includes=$(echo -e "$includes" | sed -r 's,^[^/],'"$indir"'/&,')
  new_todo=$(comm -1 -3 <(filter "$todo") <(filter "$includes"))
  [ -z "$new_todo" ] && return 0
  todo=$(echo -e "$todo\n$new_todo")
}

filter() {
  # $1 - string to filter
  echo -en "$1" | sort -u
}


infile=$(realpath "$1")
indir=$(dirname "$infile")


[ ! -f "$infile" ] && { echo "$infile: input file does not exist"; exit 10; }

n=0
todo="$infile"
while true; do
  n=$((n+1))
  if [[ $(echo -e "$todo" | wc -l) -ge "$n" ]]; then
    next=$(echo -e "$todo" | sed -n "$n p")
    [[ ! -f "$next" ]] && { echo "$next: file does not exist"; code=20; continue; }
    find_includes "$next"
  else
    break
  fi
done

[[ $code -gt 0 ]] && echo -e "\nThere were errors. (code $code)"
exit $code
