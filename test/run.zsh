#!/usr/bin/env zsh
setopt localoptions NO_shwordsplit

typeset -g test_dir="${0:A:h}"
typeset -gi total_failures=0
typeset -ga failed_files=()

if ! command -v jj >/dev/null 2>&1; then
  print -u2 "jj not found on PATH; can't run the test suite."
  exit 1
fi

for test_file in "$test_dir"/test_*.zsh(N); do
  print "=== ${test_file:t} ==="
  # -f: no rcs. Without it, an earlier fpath entry (e.g. an installed copy of
  # this plugin) can shadow the copy under test — see the jj prompt review
  # for how that produced misleading results.
  if zsh -f "$test_file"; then
    :
  else
    total_failures+=1
    failed_files+=("${test_file:t}")
  fi
done

print ""
if (( total_failures > 0 )); then
  print -u2 "FAILED: ${failed_files[*]}"
  exit 1
fi
print "All tests passed."
