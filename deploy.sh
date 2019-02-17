#!/bin/bash

prepare_ssh()
{
    eval $(ssh-agent -s)
    ssh-add <(echo -e "$blog_key")

    if [ -e /.dockerenv ] ;then
        mkdir -p ~/.ssh
        echo -e "Host *\n\tStrictHostKeyChecking no\n\n" > ~/.ssh/config
    fi
}

deploy() {
    cd public
    git init
    git add .
    git remote add origin git@github.com:lisongmin/lisongmin.github.io.git
    git push -u origin master --force
}

prepare_ssh
deploy
