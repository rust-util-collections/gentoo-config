export LANG=en_US.UTF-8
export LC_CTYPE=zh_CN.UTF-8

# rust env
source ~/.cargo/env

# golang env
export GO111MODULE=on
export GOPROXY=https://goproxy.cn

export PATH=~/cargo/bin:~/go/bin:$PATH

export HISTSIZE=2000
export HISTFILE="$HOME/.history"
export SAVEHIST=$HISTSIZE

export EDITOR=vim
export EIX_LIMIT_COMPACT=0

# 启动自动补全
autoload -U compinit
compinit
# 以更悦目的格式显示补全信息
zstyle ':completion:*:descriptions' format '%U%B%d%b%u'
zstyle ':completion:*:warnings' format '%BSorry, no matches for: %d%b'

# 载入主提示符主题
autoload -U promptinit
promptinit
# 比较悦目的主题还有：gentoo、walters、adam2 等
prompt clint

# 次提示符，显示当前有效用户身份及工作目录
# RPROMPT="%F{magenta}%n@%~%f"

# 忽略所有重复的历史记录
setopt hist_ignore_all_dups

set -o vi

alias ls="ls -F"
alias ll="ls -sailF"
alias .="source"
alias h="history 1"

alias top="htop"
alias sjj="ssh root@192.168.3.22"
