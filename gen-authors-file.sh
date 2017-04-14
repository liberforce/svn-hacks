#!/usr/bin/env bash

if [ $# -gt 0 ]; then
  repo="$1"
else
  repo=""
fi

authors=$(svn log "$repo" -q | grep -e '^r' | awk 'BEGIN { FS = "|" } ; { print $2 }' | sort | uniq)
for author in ${authors}; do
	name=$(finger -m ${author} 2> /dev/null | sed -ne "s/.*Name: \(.*\)/\1/gp")
	if [ -z "${name}" ] ; then
		name="Unknown"
	fi
	echo "${author} = ${name} <USER@DOMAIN>";
done | sort -u
