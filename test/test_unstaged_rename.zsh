#!/usr/bin/env zsh
setopt localoptions NO_shwordsplit
source "${0:A:h}/lib.zsh"

# jj diff --summary can report R (renamed) and C (copied) in addition to
# M/A/D. This guards against regressing to only counting M/A/D (as the
# original awk-based parser did), which silently dropped rename-only
# changes from the prompt's change summary.

repo=$(new_repo)

(
  cd "$repo"
  print orig >! orig.txt
  jj commit -m base >/dev/null 2>&1
  mv orig.txt renamed.txt
)

test_case "renamed file is counted"
assert_vcs_info "$repo" "branch=root() staged=S unstaged=U misc=[R1] rev=X action="

cleanup_repo "$repo"
summary_and_exit
