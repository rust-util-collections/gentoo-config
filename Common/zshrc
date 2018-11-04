source ~/.cargo/env
export RUST_SRC_PATH=`rustc --print sysroot`/lib/rustlib/src/rust/src
export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup

export HISTSIZE=2000
export HISTFILE="$HOME/.history" 
export SAVEHIST=$HISTSIZE

export GOPATH=~/go
export PATH=~/.bin:~/cargo/bin:$GOPATH/bin:$PATH

autoload -U compinit      ##启动自动补全
compinit
zstyle ':completion:*:descriptions' format '%U%B%d%b%u'                        ##以更悦目的格式显示补全信息
zstyle ':completion:*:warnings' format '%BSorry, no matches for: %d%b'

autoload -U promptinit    ##载入主提示符主题
promptinit
prompt clint

#RPROMPT="%F{magenta}%n@%~%f"  ##次提示符，显示当前有效用户身份及工作目录

setopt hist_ignore_all_dups    ##忽略所有重复的历史记录
#setopt autocd              ##直接进入目录，无需输入 cd

set -o vi

#alias which="whereis"
alias ls="ls -FG"
alias ll="ls -sailFG"
alias .="source"
alias h="history 1"
