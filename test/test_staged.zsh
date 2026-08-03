#!/usr/bin/env zsh
setopt localoptions NO_shwordsplit
source "${0:A:h}/lib.zsh"

repo=$(new_repo)

(
  cd "$repo"
  print a >! f.txt
  jj commit -m c1 >/dev/null 2>&1
  jj bookmark create main -r @- >/dev/null 2>&1
  print b >! f.txt
  jj commit -m c2 >/dev/null 2>&1
)

# @'s parent (c2) is a real, non-empty commit ahead of the bookmark (c1), so
# staged=S and the ahead count is 1 (the trailing empty @ commit itself must
# NOT be counted — see test_ahead_unpushed.zsh for the dedicated regression).
test_case "commit ahead of bookmark shows staged and ahead=1"
assert_vcs_info "$repo" "branch=main staged=S unstaged= misc=↑1 rev=X action="

cleanup_repo "$repo"
summary_and_exit
