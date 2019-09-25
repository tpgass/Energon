#!/bin/bash -eux
SSH_USER=${SSH_USERNAME:-ansible}

## Disable IPv6 forever
tee -a /etc/sysctl.d/99-sysctl.conf << 'EOF' > /dev/null
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOF

## apply IPv6 changes
sysctl -p > /dev/null

# add UFW rules to deny all but ssh (for now)
ufw default deny incoming
ufw limit 22
ufw enable

sudo -u ${SSH_USER} mkdir -p /home/${SSH_USER}/.ssh
sudo -u ${SSH_USER} echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN/wZnXwxSNSBcW5zIDcrroYJVtLN1EVBv0L7NLsKtG8 2019-05-16 Ansible Lab SSH Key' > /home/${SSH_USER}/.ssh/authorized_keys

# Set the systemwide vimrc file with some sane defaults
tee /etc/vim/vimrc.local > /dev/null <<'EOF'
" Colors {{{
syntax enable           " enable syntax processing
colorscheme pablo
" }}}
" Misc {{{
set backspace=indent,eol,start
set clipboard=unnamed
" }}}
" Spaces & Tabs {{{
set tabstop=4           " 4 space tab
set expandtab           " use spaces for tabs
set softtabstop=4       " 4 space tab
set shiftwidth=4
set modelines=1
filetype indent on
filetype plugin on
set autoindent
" Always wrap long lines:
set wrap
" }}}
" UI Layout {{{
set number              " show line numbers
set showcmd             " show command in bottom bar
set nocursorline        " highlight current line
set wildmenu
set lazyredraw
set showmatch           " higlight matching parenthesis
set fillchars+=vert:\ 
" }}}
" Searching {{{
set ignorecase          " ignore case when searching
set incsearch           " search as characters are entered
set hlsearch            " highlight all matches
" }}}
" Folding {{{
"=== folding ===
set foldmethod=indent   " fold based on indent level
set foldnestmax=10      " max 10 depth
set foldenable          " don't fold files by default on open
nnoremap <space> za
set foldlevelstart=10   " start with fold level of 1
" }}}
" Mouse Support {{{
set mouse=a
" }}}
EOF

## Make sure we wait until all the data is written to disk, otherwise
## Packer might quite too early before the large files are deleted
sync