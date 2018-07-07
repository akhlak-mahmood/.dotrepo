# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# END OF DEFAULT UBUNTU DEFINITIONS
# -----------------------------------------------------------------
# BEGIN BASHRC DEFINITIONS

# some stuff we will need later on
# ---------------------------------

# Define Colors {{
	export black='\e[00;90m'
	export BLACK='\e[01;30m'
	export red='\e[00;91m'
	export RED='\e[01;31m'
	export green='\e[00;92m'
	export GREEN='\e[01;32m'
	export yellow='\e[00;93m'
	export YELLOW='\e[01;33m'
	export blue='\e[00;94m'
	export BLUE='\e[01;34m'
	export magenta='\e[00;95m'
	export MAGENTA='\e[01;35m'
	export cyan='\e[00;96m'
	export CYAN='\e[01;36m'
	export white='\e[00;97m'
	export WHITE='\e[01;37m'
	export NC='\e[00m'          # No Color / Reset
# }}


# if command exists
havecmd() { type "$1" &> /dev/null; }

# the `test` may get overwritten
alias __test=$(which test)

# Git helpers
# Some later items depend on it.
# It should be configured first.
# ---------------------------------
if havecmd git; then
	source /usr/share/bash-completion/completions/git

	if [[ ! -f ~/.git-prompt.sh ]]; then
		# download and use the official one
		echo "Downloading git-prompt ..."
		wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh -O ~/.git-prompt.sh && source ~/.git-prompt.sh
		echo "git-prompt loaded."
	else
		source ~/.git-prompt.sh
	fi

	# show all the files in current git repo
	alias gittree='git ls-tree --full-tree -r HEAD'

	# git oneliner log
	alias gitol='git log --oneline -n'

	# git create and switch to a new branch
	# ex: git checkout -b new-branch
	# ex: git checkout -b new-branch based-on-this-old-branch
	alias gitnb='git checkout -b'

	# Version control dotfiles
	# Inspired by: https://developer.atlassian.com/blog/2016/02/best-way-to-store-dotfiles-git-bare-repo/
	if __test -d ~/.dotrepo; then
		dot() {
			git --git-dir=$HOME/.dotrepo/ --work-tree=$HOME "$@"
		}
	else
		dotrepo() {
			cd ~
			git init --bare .dotrepo
			dot() {
				git --git-dir=$HOME/.dotrepo/ --work-tree=$HOME "$@"
			}
			echo '*' >> .dotrepo/info/exclude
			read -p "Press ENTER to continue ..."
			dot config --local status.showUntrackedFiles no
			dot status
			echo
			echo "Repository set. You may want to add remote as 'dot remote add origin <url>'"
			echo "Then pull, add and push."
			unset dotrepo
		}
	fi

else
	echo "Git not installed. Please consider installing it."
fi

# Terminal title and prompt
# ---------------------------------

# Prints the latest exit code
# inspired by https://github.com/slomkowski/bash-full-of-colors
__exit_code() {
	local exit_code=$?
	if [[ exit_code -eq 0 ]]; then
		echo ''
	else
		echo -e " ${red}?${exit_code}${NC}"
	fi
}

# set length of pwd shown on prompt and title
export PROMPT_DIRTRIM=2

# Change the user, host and path colors.
# Call from ~/.bash_aliases
xterm_setcolor() {
	local user host path

	user="${1:-$GREEN}"
	host="${2:-$CYAN}"
	path="${3:-$BLUE}"

	# set prompt style
	if havecmd __git_ps1; then
	    PS1="${debian_chroot:+($debian_chroot)}\[${user}\]\u\[${BLACK}\]@\[${host}\]\h\[${WHITE}\]:\[${path}\]\w\[$MAGENTA\]\$(__git_ps1)\[${NC}\]\$(__exit_code)\$ "
	else
		PS1="${debian_chroot:+($debian_chroot)}\[${user}\]\u\[${BLACK}\]@\[${host}\]\h\[${WHITE}\]:\[${path}\]\w\[$MAGENTA\]\[${NC}\]\$(__exit_code)\$ "
	fi

    # set terminal title
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\h: \w\a\]$PS1"
}

# set default colors
xterm_setcolor $green $GREEN $BLUE

# Common terminal aliases
# ---------------------------------

# Define ls to show files as tree
alias ls='ls -lh --color=auto'

# clear screen
alias cls='clear'

# default editor
if havecmd subl; then
	export EDITOR=subl
else
	export EDITOR=vi
fi

# memory info 
alias free='free -h'

# disk use
alias du='du -h'

# interactive mv and cp
alias mv='mv -i'
alias cp='cp -i'
alias rm='rm -I'

# text to speak
# example 'say "ding dong"'
alias say='spd-say'


# display sorted directory file size 
alias dus="du --max-depth=1 | sort -nr"

# grep history
# you can run a command from history by typing
# !N where N is the command number in history
alias gh='history | grep '

# Copy with a progress bar
alias rsync="rsync -avh --progress"

# Navigation helpers
# ---------------------------------

# Back navigation helpers
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# Hide pushd popd outputs
pushd () {
    command pushd "$@" > /dev/null
}

popd () {
    command popd "$@" > /dev/null
}

cd() {
	if [[ -z "$1" ]]; then
		command cd ~
		# printf "$RED$PWD/$NC: "
	else
		pushd "$1"
	fi
	ls # "it is useful to call ls from cd"
}

# Record cd items to dir structure
alias cd-='popd'
alias cd--='popd -2'
alias cd---='popd -3'

alias d='dirs -v'
alias b='pushd +1'
alias p='pwd'

# Working Directory
# https://github.com/karlin/working-directory
if [[ -d ~/.wd ]]; then
    export WDHOME=$HOME/.wd
    source $WDHOME/wd.sh
else
	# You may want to install working-directory by running 'installwd'
	installwd() {
		cd /tmp &&\
		git clone https://github.com/karlin/working-directory.git &&\
		cd working-directory &&\
		./install.sh
	    export WDHOME=$HOME/.wd
	    source $WDHOME/wd.sh &&\
		unset installwd
	}
fi

# Quick and fast
# ---------------------------------
alias bashrc='${EDITOR} ~/.bashrc'
alias bashaliases='${EDITOR} ~/.bash_aliases'

# source bashrc
alias sourcerc='. ~/.bashrc'

# frequently used cd
alias cddl='cd ~/Downloads'
alias cddoc='cd ~/Documents'
alias cdt='cd /tmp'
alias cdmed='cd /media/$(whoami)'

__test -d ~/Dropbox && alias cddb='cd ~/Dropbox'
__test -d ~/data && alias cdd='cd ~/data'
__test -d ~/programs && alias cdp='cd ~/programs'
__test -d ~/mnt && alias cdm='cd ~/mnt'

# Installed applications helpers
# ---------------------------------
if havecmd vmd; then alias vmdrc='${EDITOR} ~/.vmdrc'; fi

if havecmd google-chrome; then alias chrome='google-chrome'; fi

alias gimp='flatpak run org.gimp.GIMP'

# Useful tools
# ---------------------------------

# open nautilus here or somewhere
here() {
	local path
	if havecmd nautilus; then
		path="${1:-$(pwd)}"
		nautilus "$path" &
	fi
}

# open a new terminal at a specific directory
alias term="gnome-terminal --working-directory"

# open file with default application
function open () {
  xdg-open "$@">/dev/null 2>&1
}

# quick google search
# example 'google "Weather Today"'
google() {
	open "https://www.google.com/search?q=$@"
}

# usage: localhost <path> <port>
localhost() {
	local port=${2:-8080}
	local path="${1:-/}"
	open "http://localhost:${port}${path}"
}

# Swap two files.
# If the second file doesn't exist, empty one is created.
# Be careful, both files will exist, only contents are swapped.
swap() {
	local file1 file2
	file1="$1"; file2="$2"
	[[ -f "${file2}" ]] || touch "${file2}"
	cp -fv "${file1}" "swap.${file1}" && \
	mv -fv "${file2}" "${file1}" && \
	mv -v "swap.${file1}" "${file2}"
	echo done
}

# Helper function to quickly sync bashrc using Dropbox.
# You may override this function in ~/.bash_aliases
# to include other dot files.
# Consider using dotrepo() to version control dotfiles.
if __test -d ~/Dropbox; then
dotsyn() {
	if __test ~/.bashrc -nt ~/Dropbox/dotfiles/bash.rc; then
		rsync ~/.bashrc ~/Dropbox/dotfiles/bash.rc
	elif __test ~/.bashrc -ot ~/Drobox/dotfiles/bash.rc; then
		rsync ~/Dropbox/dotfiles/bash.rc ~/.bashrc
	else
		echo "Files are in sync."
	fi
}
fi

# from https://github.com/helmuthdu/dotfiles/blob/master/.bashrc
# REMIND ME, ITS IMPORTANT!
# usage: remindme <time> <text>
# e.g.: remindme 10m "omg, the pizza"
remindme() { sleep $1 && zenity --info --text "$2" & }

tellme() { sleep $1 && spd-say "$2" & }

# from https://github.com/trentm/dotfiles/blob/master/home/.bashrc
# List path entries of PATH or environment variable <var>.
# Usage: pls [<var>]
pls () { eval echo \$${1:-PATH} |tr : '\n'; }

# For some reason, rot13 pops up everywhere
rot13 () {
    if [ $# -eq 0 ]; then
        tr '[a-m][n-z][A-M][N-Z]' '[n-z][a-m][N-Z][A-M]'
    else
        echo $* | tr '[a-m][n-z][A-M][N-Z]' '[n-z][a-m][N-Z][A-M]'
    fi
}

# END OF BASHRC DEFINITIONS
# -----------------------------------------------------------------
# Load the local aliases and then the bash completion at the end,
# so local aliases can modify any definitions above if needed.
# -----------------------------------------------------------------

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
else
	cat << EOF > ~/.bash_aliases
# ~/.bash_aliases for ${USER}@${HOSTNAME}
# This file should contain everything that is only specific to 
# this computer (path, variable, color etc.).
# Any sharable configuration should go into ~/.bashrc

# xterm_setcolor $green $RED

EOF
	vi ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi


# Displays a git cheatsheet
# Useful for noobs like me
if havecmd git; then

cheat-git() {
	#cat << EOF | less
	cat << EOF

git checkout -b [new-branch]
	creates and switches to a new branch

git checkout -b [new-branch] [object]
	creates and switches to a new branch based on an existing object

	[object] = [branch-name] or [commit-sha]

git checkout [object]
	checks out the state of the repository at a particular object

git show [object]
	show commited changes of the object
	default object is current working directory/branch

git push -u origin my_branch
	specify -u to create track remote branch
	this sets the remote upstream, so only need to specify once

git branch

git branch -a
	to show remote branches too

git fetch
	get the latest information about the branches on the default remote

git fetch [remote]
	get the latest information about the branches on the named remote

git merge [branch]
	merges the named branch into the working directory/branch

git merge [remote/branch] -m "[message]"
	merges the branch referred to into the working directory
	fetch the remote before the merge

Note
	fetch followed by merge is often safer than pull
	don’t assume that pull will do what you expect it to

EOF
}
fi