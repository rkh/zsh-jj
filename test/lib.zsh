setopt localoptions NO_shwordsplit

typeset -g PLUGIN_ROOT="${${0:A:h}:h}"
typeset -g TEST_FORMAT="branch=%b staged=%c unstaged=%u misc=%m rev=%i action=%a"
typeset -gi TEST_FAILURES=0
typeset -g CURRENT_TEST=""

test_case() {
  CURRENT_TEST="$1"
}

fail() {
  print -u2 "not ok - ${CURRENT_TEST}: $1"
  TEST_FAILURES+=1
}

pass() {
  print "ok - ${CURRENT_TEST}"
}

# Compares vcs_info output against an expected string; records pass/fail.
# rev=<id> is a randomly generated jj change id, so it's normalized to
# "rev=X" on both sides before comparing — callers should write "rev=X"
# in their expected string.
assert_vcs_info() {
  local repo_dir="$1" expected="$2"
  local actual
  actual=$(vcs_info_result "$repo_dir" | sed -E 's/rev=[^ ]+/rev=X/')
  if [[ "$actual" == "$expected" ]]; then
    pass
  else
    fail "expected [$expected], got [$actual]"
  fi
}

# Runs vcs_info in $1 (a jj repo) using this plugin's functions and prints
# vcs_info_msg_0_. Runs in a subshell so fpath/zstyle/cwd stay local to the call.
vcs_info_result() {
  local repo_dir="$1"
  (
    cd "$repo_dir" || exit 1
    fpath=("$PLUGIN_ROOT/functions" $fpath)
    autoload -Uz vcs_info
    zstyle ':vcs_info:*' enable jj
    zstyle ':vcs_info:*' check-for-changes true
    zstyle ':vcs_info:*:*' formats "$TEST_FORMAT"
    zstyle ':vcs_info:*:*' actionformats "$TEST_FORMAT"
    vcs_info
    print -r -- "$vcs_info_msg_0_"
  )
}

# Creates a colocated jj repo under a fresh mktemp dir and prints its path.
new_repo() {
  local dir
  dir=$(mktemp -d "${TMPDIR:-/tmp}/zsh-jj-test.XXXXXX")
  jj git init --colocate "$dir" >/dev/null 2>&1
  print -r -- "$dir"
}

cleanup_repo() {
  [[ -n "$1" && "$1" == */zsh-jj-test.* ]] && command rm -rf "$1"
}

summary_and_exit() {
  if (( TEST_FAILURES > 0 )); then
    print -u2 "${TEST_FAILURES} failure(s) in ${CURRENT_TEST:-<unknown>}"
    exit 1
  fi
  exit 0
}
