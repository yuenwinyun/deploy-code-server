#!/bin/bash

START_DIR="${START_DIR:-/home/coder/project}"

PREFIX="deploy-code-server"

mkdir -p $START_DIR

config_git() {
    local GIT_USERNAME="${GIT_USERNAME:-yuenwinyun}"
    local GIT_EMAIL="${GIT_EMAIL:-'geek@yuenwinyun.com'}"

    git config --global user.name $GIT_USERNAME
    git config --global user.email $GIT_EMAIL
}

set_rclone_config() {
    echo "[$PREFIX] Copying rclone config..."
    mkdir -p /home/coder/.config/rclone/
    echo $RCLONE_DATA | base64 -d >/home/coder/.config/rclone/rclone.conf
}

set_vscode_tasks() {
    local RCLONE_VSCODE_TASKS="${RCLONE_VSCODE_TASKS:-true}"

    if [ $RCLONE_VSCODE_TASKS = "true" ]; then
        echo "[$PREFIX] Applying VS Code tasks for rclone"
        cp /tmp/rclone-tasks.json /home/coder/.local/share/code-server/User/tasks.json
    fi
}

execute_rclone_scripts() {
    local RCLONE_AUTO_PUSH="${RCLONE_AUTO_PUSH:-true}"
    local RCLONE_AUTO_PULL="${RCLONE_AUTO_PULL:-true}"
    local RCLONE_REMOTE_PATH=${RCLONE_REMOTE_NAME:-code-server-remote}:${RCLONE_DESTINATION:-code-server-files}
    local RCLONE_SOURCE_PATH=${RCLONE_SOURCE:-$START_DIR}

    echo "rclone sync $RCLONE_SOURCE_PATH $RCLONE_REMOTE_PATH $RCLONE_FLAGS --exclude **/node_modules/** -vv" >/home/coder/push_remote.sh
    echo "rclone sync $RCLONE_REMOTE_PATH $RCLONE_SOURCE_PATH $RCLONE_FLAGS --exclude **/node_modules/** -vv" >/home/coder/pull_remote.sh
    chmod +x push_remote.sh pull_remote.sh

    if rclone ls $RCLONE_REMOTE_PATH; then
        if [ $RCLONE_AUTO_PULL = "true" ]; then
            echo "[$PREFIX] Pulling existing files from remote..."
            /home/coder/pull_remote.sh &
        fi
    else
        if [ $RCLONE_AUTO_PUSH = "true" ]; then
            echo "[$PREFIX] Pushing initial files to remote..."
            /home/coder/push_remote.sh &
        fi
    fi
}

echo "[$PREFIX] Clone files using rclone"

if [[ -n "${RCLONE_DATA}" ]]; then
    set_rclone_config
    set_vscode_tasks
    execute_rclone_scripts
fi

echo "[$PREFIX] Config git"

config_git

echo "[$PREFIX] Starting code-server..."
# Now we can run code-server with the default entrypoint
/usr/bin/entrypoint.sh --bind-addr 0.0.0.0:8080 $START_DIR
