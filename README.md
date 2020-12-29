# gentoo-config

#### <1> VIM nerd_tree 侧栏乱码问题:

```shell
#
# 注释掉不能显示的富文本字体
# vim /usr/local/share/vim/vim74/plugin/NERD_tree.vim
#

"if !nerdtree#runningWindows() && !nerdtree#runningCygwin()
"    call s:initVariable('g:NERDTreeDirArrowExpandable', '▸')
"    call s:initVariable('g:NERDTreeDirArrowCollapsible', '▾')
"else
    call s:initVariable('g:NERDTreeDirArrowExpandable', '+')
    call s:initVariable('g:NERDTreeDirArrowCollapsible', '~')
"endif
```