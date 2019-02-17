#!/bin/bash

prepare_ssh()
{
    openssl aes-256-cbc -K $encrypted_eab015c51e35_key \
        -iv $encrypted_eab015c51e35_iv \
      -in .travis/bot.enc -out ./deploy_key -d
    chmod 600 ./deploy_key

    eval "$(ssh-agent -s)"
    ssh-add ./deploy_key

    echo -e "Host *\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config
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
    prepare_ssh && deploy
fi
