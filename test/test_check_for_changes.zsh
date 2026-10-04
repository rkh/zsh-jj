#!/usr/bin/env zsh
setopt localoptions NO_shwordsplit
source "${0:A:h}/lib.zsh"

# check-for-changes is vcs_info's switch for the expensive working-copy scan.
# For jj that scan is the snapshot: off means report the last snapshot and
# don't create a new operation.

op_count() {
  (cd "$1" && jj --ignore-working-copy op log --no-graph -T '"x\n"' | wc -l)
}

repo=$(new_repo) || exit 1

(
  cd "$repo" || exit 1
  print a >! f.txt
  jj commit -m c1 >/dev/null 2>&1
  print new >! new.txt
)

ops_before=$(op_count "$repo")

TEST_CHECK_FOR_CHANGES=false
test_case "check-for-changes off: unsnapshotted edits are not reported"
assert_vcs_info "$repo" "branch=root() staged=S unstaged= misc= rev=X action="

test_case "check-for-changes off: prompt does not create a jj operation"
assert_eq "$(op_count "$repo")" "$ops_before"

TEST_CHECK_FOR_CHANGES=true
test_case "check-for-changes on: edits are snapshotted and reported"
assert_vcs_info "$repo" "branch=root() staged=S unstaged=U misc=[A1] rev=X action="

summary_and_exit
