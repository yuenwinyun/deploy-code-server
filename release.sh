#!/bin/bash

LOCAL_BRANCH=draft
RELEASE_BRANCH=main

git checkout $RELEASE_BRANCH
git pull --rebase
git merge $LOCAL_BRANCH
git push
git checkout $LOCAL_BRANCH
