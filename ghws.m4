#!/bin/bash

APPROOT="ROOTDIR"

gengisturl() {
	rawurl="$(curl -s "$1" | grep '>Raw<' | sed 's/^.*href="//g;s/".*$//g;s/^/https:\/\/gist.githubusercontent.com/g')"
	echo "\"rawurl\":\"$rawurl\""
}

gengists() {
	gisturl="https://gist.github.com/$1"
	echo "\"gists\":["
	while [ -n "$gisturl" ]; do
		curl -s "$gisturl" | grep css-truncate-target | grep -v ">$1<" | sed 's/^.*href="//g;s/".*css-truncate-target">/|/g;s/<.*$//g;s/^/https:\/\/gist.github.com/g;s/^\(.*\)|\(.*\)$/{ "name":"\2", "url":"\1.git" },/g'
		export gisturl=$(curl -s "$gisturl" | grep '>Newer<.*href.*>Older<' | sed 's/^.*href="//g;s/".*$//g')
	done | sed '$s/,$//g'
	echo "]"
}

genrepos() {
	repourl="https://github.com/$1?tab=repositories"
	echo "\"repos\":["
	while [ -n "$repourl" ]; do
		curl -s "$repourl" | grep 'href.*codeRepository' | sed 's/^.*href="\/\(.*\)\/\(.*\)" .*$/{ "name":"\2", "http-url":"https:\/\/github.com\/\1\/\2.git", "ssh-url":"git@github.com:\1\/\2.git" },/g'
		export repourl=$(curl -s "$repourl" | grep '>Previous<.*href.*>Next<' | grep -v 'disabled">Next' | sed 's/^.*href="//g;s/".*$//g;s/^/https:\/\/github.com/g')
	done | sed '$s/,$//g'
	echo "]"
}
genall() {
	genrepos $1
	echo -n ","
	gengists $1
}

availres=(/ws/gists /ws/repos /ws/gisturl /ws/all)
availact=(GET)
read request
action=$(printf "$request" | awk '{ print $1 }')
resource=$(printf "$request" | awk '{ print $2 }')

if [ -z "$(which iostat)" ]; then
	read -r -d '' RESPBODY <<HERE
{ "error":"command iostat unavailable" }
HERE
	echo "HTTP/1.1 500 Internal Server Error"
	echo "Content-Length: ${#RESPBODY}"
	echo "Date: $(date -Ru)"
	echo ""
	echo "$RESPBODY"
elif [ -z "$(awk -v thisact="$action" 'BEGIN { RS=" " } { if (thisact == $1) { print thisact } }' <<< "${availact[@]}")" ]; then
	read -r -d '' RESPBODY <<HERE
{ "error":"invalid HTTP method ($action)" }
HERE
	echo "HTTP/1.1 500 Internal Server Error"
	echo "Content-Length: ${#RESPBODY}"
	echo "Date: $(date -Ru)"
	echo ""
	echo "$RESPBODY"
elif [ -z "$(awk -v thisres="$resource" 'BEGIN { RS=" " } { if (thisres == $1) { print thisres } }' <<< "${availres[@]}")" ]; then
	read -r -d '' RESPBODY <<HERE
{ "error":"invalid path ($resource)" }
HERE
	echo "HTTP/1.1 404 Not Found"
	echo "Content-Length: ${#RESPBODY}"
	echo "Date: $(date -Ru)"
	echo ""
	echo "$RESPBODY"
else
	while read line; do
		[[ -z "$line" ]] && break
	done
	
	read JSONREQ
	
	arg="$(echo \"$JSONREQ\" | $APPROOT/lib/JSON.sh | awk '/\["arg\"\]/ { print gensub(/"/,"","g",$2) }')"
	
	shortrec="$(sed 's/^\/ws[\/]*//g' <<< "$resource")"

	returncode=""
	JSONDATA=""
	
	if [ -z "$arg" ]; then
		JSONDATA="{ \"error\":\"argument empty\" }"
		returncode="500"
	else
		read -r -d '' JSONDATA <<HERE
{
$(gen$shortrec $arg)
}
HERE
		returncode="200"
	fi
	
	echo "HTTP/1.1 $returncode OK"
	echo "Content-Length: ${#JSONDATA}"
	echo "Date: $(date -Ru)"
	echo ""
	echo "$JSONDATA"
fi
