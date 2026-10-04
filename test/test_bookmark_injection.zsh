#!/usr/bin/env zsh
setopt localoptions NO_shwordsplit
source "${0:A:h}/lib.zsh"

# Bookmark names are attacker-controlled (git refs may contain $, (, ), >,
# backticks and quotes, and fetched remote bookmarks show up in the prompt).
# The backend must treat them as data, never evaluate them as shell code.

repo=$(new_repo) || exit 1

(
  cd "$repo" || exit 1
  print a >! f.txt
  jj commit -m c1 >/dev/null 2>&1
  jj bookmark create main -r @- >/dev/null 2>&1
  jj bookmark create '"x$(id>PWNED)`id>PWNED2`"' -r @- >/dev/null 2>&1
)

result=$(vcs_info_result "$repo")

test_case "bookmark name with \$(...) is not executed"
assert_eq "$(print -l "$repo"/PWNED*(N))" ""

test_case "bookmark name is shown verbatim (as jj quotes it)"
assert_eq "${result%% staged=*}" 'branch=main "x$(id>PWNED)`id>PWNED2`"'

summary_and_exit
