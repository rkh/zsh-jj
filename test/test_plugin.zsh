#!/usr/bin/env zsh
setopt localoptions NO_shwordsplit
source "${0:A:h}/lib.zsh"

plugin="$PLUGIN_ROOT/zsh-jj.plugin.zsh"

test_case "sourcing the plugin twice registers the precmd hook once"
assert_eq "$(zsh -fc 'source "$1"; source "$1"; print ${#${(M)precmd_functions:#precmd_vcs_info}}' _ "$plugin")" "1"

test_case "plugin functions take precedence over other fpath entries"
assert_eq "$(zsh -fc 'source "$1"; print -r -- $fpath[1]' _ "$plugin")" "$PLUGIN_ROOT/functions"

test_case "prompt has a space after the lightning bolt"
assert_eq "$(cd / && zsh -fc 'source "$1"; print -rP -- "$PROMPT"' _ "$plugin" | sed 's/\x1b\[[0-9;]*m//g')" "⚡ ➜ / "

summary_and_exit
