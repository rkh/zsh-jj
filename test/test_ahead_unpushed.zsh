#!/usr/bin/env zsh
setopt localoptions NO_shwordsplit
source "${0:A:h}/lib.zsh"

# Remote-tracking status (⇡ ahead / ⇣ behind) is only observable once a
# bookmark has a remote counterpart. "Remote ahead" (⇣) is not covered here:
# jj auto-fast-forwards tracked bookmarks on `jj git fetch` in the common
# case, so that state is only reachable via genuine bookmark divergence,
# which is too flaky to set up deterministically for a regression test.
# It was verified manually during review instead.

repo=$(new_repo)
remote_dir="${repo}.git"
git init --bare "$remote_dir" >/dev/null 2>&1

(
  cd "$repo"
  jj git remote add origin "$remote_dir" >/dev/null 2>&1
  print a >! f.txt
  jj commit -m c1 >/dev/null 2>&1
  jj bookmark create main -r @- >/dev/null 2>&1
  jj git push -b main >/dev/null 2>&1

  print b >! f.txt
  jj commit -m c2 >/dev/null 2>&1
  jj bookmark set main -r @- >/dev/null 2>&1
)

# The bookmark is moved onto the local commit (as `jj bookmark set` would be
# used in practice before pushing), so it's not "ahead of the bookmark"
# (no staged/↑) — it's ahead of the bookmark's pushed remote counterpart,
# which is what ⇡ reports. jj also marks the bookmark name itself with "*"
# to show it differs from its remote-tracking counterpart.
test_case "unpushed local commit shows ahead-of-remote marker"
assert_vcs_info "$repo" "branch=main* staged= unstaged= misc=⇡1 rev=X action="

cleanup_repo "$repo"
command rm -rf "$remote_dir"
summary_and_exit
