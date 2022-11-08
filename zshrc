export LANG=en_US.UTF-8
export LC_CTYPE=zh_CN.UTF-8

# rust env
source ~/.cargo/env
export CARGO_GIT_FETCH_WITH_CLI=true
# export RUSTFLAGS="-C target-feature=-crt-static"
# export BTM_VOLUME=/data/...
# export TENDERMINT_HOME=/data/...
# export ROCKSDB_STATIC=1
# export ROCKSDB_LIB_DIR=/usr/local/lib/

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
# prompt redhat

# 次提示符，显示当前有效用户身份及工作目录
# RPROMPT="%F{magenta}%n@%~%f"

# 忽略所有重复的历史记录
setopt hist_ignore_all_dups

set -o vi

alias ls="ls -F --color=always"
alias ll="ls -sailF"
alias .="source"
alias h="history 1"

alias top="htop"
alias sensors="sensors 2>/dev/null"

# for i in "${HOME}" "${HOME}/trash"; do
#     for j in $(find $i -maxdepth 1 -type d); do
#         if [[ -d ${j} && -f ${j}/Cargo.toml && (! -d /tmp/${j}/target) ]]; then
#             rm -rf ${j}/target /tmp/${j}/target
#             mkdir -p /tmp/${j}/target || exit 1
#             ln -sv /tmp/${j}/target ${j}/target || exit 1
#         fi
#     done
# done
