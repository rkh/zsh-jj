fpath=("${0:A:h}/functions" ${fpath:#${0:A:h}/functions})

autoload -Uz vcs_info add-zsh-hook
autoload -U colors && colors

zstyle ':vcs_info:*' enable jj git

precmd_vcs_info() { vcs_info }
add-zsh-hook precmd precmd_vcs_info
setopt prompt_subst

zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*:*' formats " %{$fg[blue]%}(%s %{$fg[red]%}%m%{$fg[yellow]%}%{$fg[magenta]%} %b%{$fg[blue]%})%{$reset_color%}"

PROMPT="%B%{$fg[yellow]%}⚡ %(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )%{$fg[cyan]%}%c%{$reset_color%}"
PROMPT+="\$vcs_info_msg_0_ "
