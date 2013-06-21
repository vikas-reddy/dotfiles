# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Aliases
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias grep='grep --color=auto'
alias ls='ls --color=auto'
alias vi='vim --noplugin'

# Custom commands
alias off='sleep 1 && xset dpms force off'
alias cputemp='cat /sys/class/hwmon/hwmon0/temp*input; grep --color=no "MHz" /proc/cpuinfo'
alias minify='java -jar /home/vikas/softwares/yuicompressor-2.4.2/build/yuicompressor-2.4.2.jar '

export PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[01;34m\] \w \$\[\033[00m\] '

# sudo cpufreq-set -g ondemand

# RVM
[[ -s $HOME/.rvm/scripts/rvm ]] && source $HOME/.rvm/scripts/rvm

EDITOR="vim"

JAVA_HOME="/opt/java"
GRAILS_HOME="${HOME}/softwares/grails"
PATH="${PATH}:/usr/local/bin:/opt/java/bin:${HOME}/.rvm/bin:${HOME}/softwares/bin:${GRAILS_HOME}/bin"

# bash-autocompletion
complete -cf sudo
complete -cf man

# 256 colors
if [ -e /usr/share/terminfo/x/xterm-256color ]; then
    export TERM='xterm-256color'
else
    export TERM='xterm-color'
fi
