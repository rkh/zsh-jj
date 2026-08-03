#!/usr/bin/env zsh
setopt localoptions NO_shwordsplit
source "${0:A:h}/lib.zsh"

repo=$(new_repo)

(
  cd "$repo"
  print base >! f.txt
  jj commit -m base >/dev/null 2>&1
  jj bookmark create main -r @- >/dev/null 2>&1
  base_id=$(jj log --no-graph -r @- -T change_id)

  print A >! f.txt
  jj commit -m branchA >/dev/null 2>&1
  a_id=$(jj log --no-graph -r @- -T change_id)

  jj new "$base_id" -m branchB >/dev/null 2>&1
  print B >! f.txt
  jj commit -m branchB-commit >/dev/null 2>&1
  b_id=$(jj log --no-graph -r @- -T change_id)

  jj new "$a_id" "$b_id" -m merge >/dev/null 2>&1
)

test_case "conflicted merge shows the conflict action marker"
assert_vcs_info "$repo" "branch=main staged=S unstaged= misc=↑2 rev=X action=⚡"

cleanup_repo "$repo"
summary_and_exit
