#!/usr/bin/env zsh
setopt localoptions NO_shwordsplit
source "${0:A:h}/lib.zsh"

repo=$(new_repo)

test_case "no bookmark, no changes"
assert_vcs_info "$repo" "branch=root() staged= unstaged= misc= rev=X action="

(
  cd "$repo"
  print a >! f.txt
  jj commit -m base >/dev/null 2>&1
  jj bookmark create main -r @ >/dev/null 2>&1
)

test_case "bookmark at @, no changes"
assert_vcs_info "$repo" "branch=main staged= unstaged= misc= rev=X action="

cleanup_repo "$repo"
summary_and_exit
