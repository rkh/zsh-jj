setopt localoptions NO_shwordsplit

typeset -g PLUGIN_ROOT="${${0:A:h}:h}"
typeset -g TEST_FORMAT="branch=%b staged=%c unstaged=%u misc=%m rev=%i action=%a"
typeset -g TEST_CHECK_FOR_CHANGES=true
typeset -gi TEST_FAILURES=0
typeset -g CURRENT_TEST=""

# Everything a test creates lives under one temp root, removed on exit or
# interrupt, so a failing or aborted test doesn't leak repos.
typeset -g TEST_TMP
TEST_TMP=$(mktemp -d "${TMPDIR:-/tmp}/zsh-jj-test.XXXXXX") || exit 1
TRAPEXIT() { (( ZSH_SUBSHELL )) || command rm -rf "$TEST_TMP" }
TRAPINT() { exit 130 }

# Keep the user's jj and git config (aliases, signing, snapshot limits, hooks)
# from changing what the backend sees.
export JJ_CONFIG="$TEST_TMP/jj-config.toml"
print -r -- '[user]
name = "Test"
email = "test@example.com"' >| "$JJ_CONFIG"
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1

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

assert_eq() {
  if [[ "$1" == "$2" ]]; then
    pass
  else
    fail "expected [$2], got [$1]"
  fi
}

# Compares vcs_info output against an expected string; records pass/fail.
# rev=<id> is a randomly generated jj change id, so it's normalized to
# "rev=X" on both sides before comparing — callers should write "rev=X"
# in their expected string.
assert_vcs_info() {
  local repo_dir="$1" expected="$2"
  assert_eq "$(vcs_info_result "$repo_dir" | sed -E 's/rev=[^ ]+/rev=X/')" "$expected"
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
    zstyle ':vcs_info:*' check-for-changes "$TEST_CHECK_FOR_CHANGES"
    zstyle ':vcs_info:*:*' formats "$TEST_FORMAT"
    zstyle ':vcs_info:*:*' actionformats "$TEST_FORMAT"
    vcs_info
    print -r -- "$vcs_info_msg_0_"
  )
}

# Creates a colocated jj repo under $TEST_TMP and prints its path.
new_repo() {
  local dir
  dir=$(mktemp -d "$TEST_TMP/repo.XXXXXX") || exit 1
  if ! jj git init --colocate "$dir" >/dev/null 2>&1; then
    print -u2 "setup failed: jj git init in $dir"
    exit 1
  fi
  print -r -- "$dir"
}

summary_and_exit() {
  if (( TEST_FAILURES > 0 )); then
    print -u2 "${TEST_FAILURES} failure(s) in ${ZSH_ARGZERO:t}"
    exit 1
  fi
  exit 0
}
