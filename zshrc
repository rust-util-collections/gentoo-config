cd ~/_dev_

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

# export DS_DDEV_HOSTS="
# 10.100.131.28|54.212.29.192#ubuntu#22#1#/home/fh/ds.pem,
# 10.100.138.125|34.219.64.79#ubuntu#22#1#/home/fh/ds.pem,
# 10.100.139.213|54.185.61.205#ubuntu#22#1#/home/fh/ds.pem,
# 10.100.156.209|34.220.39.178#ubuntu#22#1#/home/fh/ds.pem,
# 10.100.156.147|18.236.194.97#ubuntu#22#1#/home/fh/ds.pem,
# 10.100.151.163|54.213.244.105#ubuntu#22#1#/home/fh/ds.pem
# "
# export DS_DDEV_HOSTS="
# 10.100.132.40|35.92.45.246#ubuntu#22#1#/home/fh/ds.pem,
# 10.100.133.112|34.217.79.8#ubuntu#22#1#/home/fh/ds.pem,
# 10.100.128.167|35.91.19.115#ubuntu#22#1#/home/fh/ds.pem,
# 10.100.129.230|54.187.129.237#ubuntu#22#1#/home/fh/ds.pem,
# 10.100.143.9|35.92.131.136#ubuntu#22#1#/home/fh/ds.pem,
# 10.100.138.41|34.219.61.94#ubuntu#22#1#/home/fh/ds.pem
# "

# golang env
# export GO111MODULE=on
# export GOPROXY=https://goproxy.cn

PATH=~/cargo/bin:~/go/bin:$PATH
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
PROMPT="%F{red}[%F{green}%n@%m%F{white}:%F{yellow}%~%F{red}]
%fzsh%(2L./1.) %B%h%b %(?..[%?%1v] )%(2v.%U%2v%u.)%f%B%#%b "
# prompt redhat

# 次提示符，显示当前有效用户身份及工作目录
# RPROMPT="%F{gray}%n@%~%f"

# 忽略所有重复的历史记录
setopt hist_ignore_all_dups

set -o vi

alias ls="ls -F --color=always"
alias ll="ls -sailF"
alias .="source"
alias h="history 1"

alias top="htop"
alias sensors="sensors | grep -A 5 k10temp 2>/dev/null"

alias sj="ssh fh@192.168.0.100"
alias sh="ssh fh@192.168.0.101"
alias sk="ssh fh@192.168.0.102"
alias sl="ssh fh@192.168.0.103"

# for i in "${HOME}" "${HOME}/trash"; do
#     for j in $(find $i -maxdepth 1 -type d); do
#         if [[ -d ${j} && -f ${j}/Cargo.toml && (! -d /tmp/${j}/target) ]]; then
#             rm -rf ${j}/target /tmp/${j}/target
#             mkdir -p /tmp/${j}/target || exit 1
#             ln -sv /tmp/${j}/target ${j}/target || exit 1
#         fi
#     done
# done
