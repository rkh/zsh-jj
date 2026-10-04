#!/usr/bin/env zsh
setopt localoptions NO_shwordsplit
source "${0:A:h}/lib.zsh"

# jj warnings (here: a new file over snapshot.max-new-file-size) must not be
# printed above every prompt.

repo=$(new_repo) || exit 1

(
  cd "$repo" || exit 1
  print a >! f.txt
  jj commit -m c1 >/dev/null 2>&1
  head -c 2000000 /dev/zero >! big.bin
)

test_case "jj warnings are not printed by the prompt"
assert_eq "$(vcs_info_result "$repo" 2>&1 >/dev/null)" ""

summary_and_exit
