# Jujutsu support for Z Shell 

This repository contains two things:

* VCS Info support for Jujutsu (inside [functions](functions) directory)
* A pre-configured zsh prompt for both Jujutsu and git, as a zsh plugin, inspired by [zap-prompt](https://github.com/zap-zsh/zap-prompt)

If you want to use the prompt out of the box, you can set it up however you install zsh plugins.

With [zap](https://www.zapzsh.com/), add the following to your `.zshrc`:

```shell
plug "rkh/zsh-jj"
```

Without a plugin manager, clone the repository, and source `zsh-jj.plugin.zsh` in your `.zshrc`:

```shell
source /path/to/zsh-jujutsu/zsh-jj.plugin.zsh
```

If you only want JJ support, but not the prompt, add the functions directory to your `$fpath` and enable `jj` in your `.zshrc`:

```shell
fpath+=/path/to/zsh-jujutsu/functions
zstyle ':vcs_info:*' enable jj
```

With `zstyle ':vcs_info:*' check-for-changes true` (set by the plugin), every prompt snapshots the working copy so file changes show up immediately; jj records each snapshot as an operation. Without it, the prompt reports the last snapshot taken by any jj command and never writes to the repository.

Tested with jj 0.45. Older versions may lack template methods the backend relies on, in which case the prompt shows no jj details.

Run the tests with `zsh test/run.zsh` (requires `jj` and `git`).
