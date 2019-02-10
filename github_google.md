
```shell
# download cilent from 'https://sh adowsocks.org/en/download/clients.html'
# or 'cargo install sh adowsocks-rust'

# ~/.zshrc, ~/.bashrc
export CARGO_GIT_FETCH_WITH_CLi=true

# ~/.gitconfig
[http "github.com"]
	proxy = http://127.0.0.1:10800
[https "github.com"]
	proxy = https://127.0.0.1:10800

# Firefox 'Network settings'
set "Proxy DNS when using SOCKS v5"
```
