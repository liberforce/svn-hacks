# Copyright (C) 2010, Martin Grenfell [http://github.com/scrooloose]
# Copyright (C) 2017, Luis Menina <liberforce AT freeside DOT fr>
#
# SPDX-License-Identifier: MIT
#-------------------------------------------------------------------
# Purpose:
#
# This script hijacks calls to svn and adds color and pagination to
# some svn commands. Source it from your bashrc.
#
# colordiff must be installed.
#-------------------------------------------------------------------

# intercept calls to svn
svn () {

  # bail if the user didnt specify which subversion command to invoke
  if [ $# -lt 1 ]; then
    command svn
    return
  fi

  local sub_cmd=$1
  shift

  # intercept svn diff commands
  if [ $sub_cmd == diff ]; then

    # colorize the diff
    # remove stupid ^M dos line endings
    # page it if there's more one screen
    command svn diff "$@" | colordiff | sed -e 's/\r//g' | less -RF --no-init

  elif [ $sub_cmd == 'format-patch' ]; then
    # svn diff alias adds colordiff extra characters, not suitable for a patch
    # No colordiff, use unified patch, with c function names to make failing
    # patches easier to adapt
    command svn diff -x '--unified --show-c-function' --patch-compatible "$@" | sed -e 's;^--- ;&a/;' -e 's;^+++ ;&b/;'

  # add some color to svn status output and page if needed:
  # M = blue
  # A = green
  # D/!/~ = red
  # C = magenta
  #
  # note that C and M can be preceded by whitespace - see $svn help status
  elif [[ $sub_cmd =~ ^(status|st)$ ]]; then
    command svn status "$@" | sed -e 's/^\(\([A-Z]\s\+\(+\s\+\)\?\)\?C .*\)$/\o33\[1;35m\1\o33[0m/' \
                                  -e 's/^\(\s*M.*\)$/\o33\[1;34m\1\o33[0m/' \
                                  -e 's/^\(A.*\)$/\o33\[1;32m\1\o33[0m/' \
                                  -e 's/^\(\(D\|!\|~\).*\)$/\o33\[1;31m\1\o33[0m/' | less -RF --no-init

  # Use commit messages templates
  # The cached message template is located at "$HOME/.cache/svn/commit-msg.tpl"
  elif [[ $sub_cmd =~ ^(commit|ci)$ ]]; then
    SVN_EDITOR="file=\$(ls -1 -v svn-commit*.tmp | tail -n 1) ; sed -i '/--$/r $HOME/.cache/svn/commit-msg.tpl' \$file && vi" command svn commit "$@"

  #page some stuff I often end up paging manually
  elif [[ $sub_cmd =~ ^(blame|help|h|cat)$ ]]; then
    command svn $sub_cmd "$@" | less -RF --no-init

  # colorize and page svn log
  # rearrange the date field from:
  #   2010-10-08 21:19:24 +1300 (Fri, 08 Oct 2010)
  # to:
  #   2010-10-08 21:19 (Fri, +1300)
  elif [[ $sub_cmd == log ]]; then
    command svn log "$@" | sed -e 's/^\(.*\)|\(.*\)| \(.*\) \(.*\):[0-9]\{2\} \(.*\) (\(...\).*) |\(.*\)$/\o33\[1;32m\1\o33[0m|\o33\[1;34m\2\o33[0m| \o33\[1;35m\3 \4 (\6, \5)\o33[0m |\7/' | less -RF --no-init

  # let svn handle it as normal
  else
    command svn $sub_cmd "$@"
  fi
}

# vi:sw=2:et:sts=2

