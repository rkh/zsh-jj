#!/usr/bin/env zsh
setopt localoptions NO_shwordsplit
source "${0:A:h}/lib.zsh"

# A bookmark on a divergent change (two visible commits sharing a change id)
# must still produce the ahead count: change ids are ambiguous in revsets
# then, commit ids are not.

repo=$(new_repo) || exit 1

(
  cd "$repo" || exit 1
  print a >! f.txt
  jj commit -m c1 >/dev/null 2>&1
  c1=$(jj log --no-graph -r @- -T change_id)
  op=$(jj op log -n 1 --no-graph -T 'id')
  jj describe -r "$c1" -m c1-x >/dev/null 2>&1
  jj --at-op "$op" describe -r "$c1" -m c1-y >/dev/null 2>&1
  target=$(jj log --no-graph -r "change_id($c1) & description(substring:c1-x)" -T commit_id 2>/dev/null)
  jj bookmark create main -r "$target" >/dev/null 2>&1
  jj new "$target" >/dev/null 2>&1
  print b >! f.txt
  jj commit -m c2 >/dev/null 2>&1
)

test_case "bookmark on a divergent change still reports ahead count"
assert_vcs_info "$repo" "branch=main staged=S unstaged= misc=↑1 rev=X action="

summary_and_exit
