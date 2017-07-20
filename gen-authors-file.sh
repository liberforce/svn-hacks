#!/bin/bash

usage()
{
    cat << EOF
Usage: $(basename "$0") REPO_PATH_OR_URL

Outputs the list of users needed to generate an authors file usable by git-svn

REPO_PATH_OR_URL      Local path or URL to your local svn repository.
EOF

}

get_author_name()
{
    local author="$1"
    echo $(finger -m ${author} 2> /dev/null | sed -ne "s/.*Name: \(.*\)/\1/gp")
}

main()
{
    local repo=""

    if [ $# -eq 1 ]; then
        repo="$1"
    else
        usage
        exit 1
    fi

    authors=$(svn log "$repo" -q | grep -e '^r' | awk 'BEGIN { FS = "|" } ; { print $2 }' | sort | uniq)
    for author in ${authors}; do
            local name=$(get_author_name "${author}")
            if [ -z "${name}" ] ; then
                    name="Unknown"
            fi
            echo "${author} = ${name} <USER@DOMAIN>";
    done | sort -u
}

main "$@"
