#!/usr/bin/env zsh
setopt localoptions NO_shwordsplit
source "${0:A:h}/lib.zsh"

repo=$(new_repo)

(
  cd "$repo"
  print a >! m.txt
  print b >! d.txt
  jj commit -m base >/dev/null 2>&1
  print changed >! m.txt
  print new >! a.txt
  command rm -f d.txt
)

test_case "modified + added + deleted files are counted"
assert_vcs_info "$repo" "branch=root() staged=S unstaged=U misc=[M1|A1|D1] rev=X action="

cleanup_repo "$repo"
summary_and_exit
