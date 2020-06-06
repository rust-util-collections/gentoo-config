# rust env
# export LIBCLANG_PATH=/usr/lib/llvm/8/lib64/
# export RUSTUP_DIST_SERVER=https://mirrors.tuna.tsinghua.edu.cn/rustup
export RUST_SRC_PATH=`rustc --print sysroot`/lib/rustlib/src/rust/src
source ~/.cargo/env

# golang env
export GO111MODULE=on
export GOPROXY=https://goproxy.cn

export PATH=~/.bin:~/cargo/bin:~/go/bin:$PATH

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

alias ls="ls -FG"
alias ll="ls -sailFG"
alias .="source"
alias h="history 1"

alias top="htop"
alias sensors="sensors | head -12"

# ibus
export GTK_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
export QT_IM_MODULE=ibus
