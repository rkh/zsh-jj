#!/usr/bin/env zsh
setopt localoptions NO_shwordsplit
source "${0:A:h}/lib.zsh"

# Each case gets its own repo + bare remote. The remote's default branch is
# irrelevant (bare), so any bookmark name can be pushed.
new_repo_with_remote() {
  local repo
  repo=$(new_repo) || exit 1
  git init --bare "${repo}.git" >/dev/null 2>&1 || exit 1
  (cd "$repo" && jj git remote add origin "${repo}.git" >/dev/null 2>&1) || exit 1
  print -r -- "$repo"
}

# Another remote bookmark (aaa) on the same commit as zzz@origin, plus the
# colocated @git refs, must not be mistaken for zzz's tracking counterpart.
repo=$(new_repo_with_remote) || exit 1
(
  cd "$repo" || exit 1
  print a >! f.txt
  jj commit -m c1 >/dev/null 2>&1
  jj bookmark create zzz aaa -r @- >/dev/null 2>&1
  jj git push -b zzz -b aaa >/dev/null 2>&1
  print b >! f.txt
  jj commit -m c2 >/dev/null 2>&1
  jj bookmark set zzz -r @- >/dev/null 2>&1
)
test_case "ahead-of-remote uses the matching bookmark when others share its remote commit"
assert_vcs_info "$repo" "branch=zzz* staged= unstaged= misc=⇡1 rev=X action="

# Local bookmark moved back behind what was pushed: remote is ahead (⇣),
# and the pushed commit is still ahead of the local bookmark (↑, staged).
repo=$(new_repo_with_remote) || exit 1
(
  cd "$repo" || exit 1
  print a >! f.txt
  jj commit -m c1 >/dev/null 2>&1
  print b >! f.txt
  jj commit -m c2 >/dev/null 2>&1
  jj bookmark create main -r @- >/dev/null 2>&1
  jj git push -b main >/dev/null 2>&1
  jj bookmark set main -r @-- --allow-backwards >/dev/null 2>&1
)
test_case "remote bookmark ahead of local shows behind-remote marker"
assert_vcs_info "$repo" "branch=main* staged=S unstaged= misc=↑1 ⇣1 rev=X action="

# "a*" has no remote; "ab" (same commit, pushed then moved) does. The name is
# compared literally, so ab's counts must not be attributed to "a*".
repo=$(new_repo_with_remote) || exit 1
(
  cd "$repo" || exit 1
  print a >! f.txt
  jj commit -m c1 >/dev/null 2>&1
  jj bookmark create ab -r @- >/dev/null 2>&1
  jj git push -b ab >/dev/null 2>&1
  print b >! f.txt
  jj commit -m c2 >/dev/null 2>&1
  jj bookmark set ab -r @- >/dev/null 2>&1
  jj bookmark create '"a*"' -r @- >/dev/null 2>&1
)
test_case "bookmark name with glob characters is matched literally"
assert_vcs_info "$repo" 'branch=a* ab* staged= unstaged= misc= rev=X action='

summary_and_exit
