#!/bin/bash

prepare_ssh()
{
    (npm bin)/set-up-ssh --key "$encrypted_eab015c51e35_key" \
                         --iv "$encrypted_eab015c51e35_iv" \
                         --path-encrypted-key ".travis/bot.enc"
}

deploy() {
    git config --global user.name lisongmin
    git config --global user.email lisongmin9@gmail.com

    cd public
    git init
    git add .
    git commit -m "update blog."
    git remote add origin git@github.com:lisongmin/lisongmin.github.io.git
    git push -u origin master --force
}

if [ "$TRAVIS_BRANCH" == "master"  ];then
    prepare_ssh
    deploy
fi
