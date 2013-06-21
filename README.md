# dotfiles

My linux configuration and other miscellaneous files.

## First Setup
    cd ~
    git clone https://github.com/vikas-reddy/dotfiles.git
    cd dotfiles
    git submodule update --init

    ln -sf dotfiles/zshrc .zshrc
    ln -sf dotfiles/config/.bashrc .bashrc
    ln -sf dotfiles/config/.gitconfig .gitconfig
    ln -sf dotfiles/config/.tmux.conf .tmux.conf

## Subsequent Setup
    cd ~/dotfiles
    git pull origin master
    git submodule update --init
    cd oh-my-zsh
    mkdir custom/plugins
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git
