
alias c="cd ~/dev"
c

alias top="htop"

alias ls="ls -F --color=always"
alias ll="ls -sailF"
alias .="source"
alias h="history 1"

export LC_ALL=en_US.UTF-8
export LC_CTYPE=zh_CN.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

# rust env
source ~/.cargo/env
export CARGO_GIT_FETCH_WITH_CLI=true
# export RUSTFLAGS="-C target-feature=-crt-static"
# export BTM_VOLUME=/data/...
# export TENDERMINT_HOME=/data/...
# export ROCKSDB_STATIC=1
# export ROCKSDB_LIB_DIR=/usr/local/lib/

# golang env
# export GOPROXY=https://goproxy.cn
export GOPRIVATE=github.com/<YOUR_PRIVATE_REPO>/* # check the `.netrc` file also
export GOPATH=~/.go

PATH=~/cargo/bin:~/go/bin:/opt/homebrew/bin:$PATH
export PATH=${PATH#*:$HOME/.cargo/bin:$HOME/.cargo/bin:}

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
PROMPT="%F{gray}[%F{gray}%n@%m%F{white}:%F{gray}%~%F{gray}]
%fzsh%(2L./1.) %(2v.%U%2v%u.)%f%#%b "
# prompt redhat

# 次提示符，显示当前有效用户身份及工作目录
# RPROMPT="%F{gray}%n@%~%f"

# 忽略所有重复的历史记录
setopt hist_ignore_all_dups

set -o vi

###################################################

alias sj="ssh fh@192.168.10.100"
alias sm="ssh fh@192.168.10.101"
alias sk="ssh fh@192.168.10.102"
alias sl="ssh fh@192.168.10.103"

###################################################
