#!/bin/bash

START_DIR="${START_DIR:-/home/coder/project}"

PREFIX="deploy-code-server"

mkdir -p $START_DIR

config_git() {
    git config --global user.name $GIT_USERNAME
    git config --global user.email $GIT_EMAIL
}

install_vscode_extensions() {
    for extension in $(cat /home/coder/extensions); do
        code-server --install-extension $extension
    done
    rm /home/coder/extensions
}

set_rclone_config() {
    echo "[$PREFIX] Copying rclone config..."
    mkdir -p /home/coder/.config/rclone/
    echo $RCLONE_DATA | base64 -d >/home/coder/.config/rclone/rclone.conf
}

set_vscode_tasks() {
    RCLONE_VSCODE_TASKS="${RCLONE_VSCODE_TASKS:-true}"

    if [ $RCLONE_VSCODE_TASKS = "true" ]; then
        echo "[$PREFIX] Applying VS Code tasks for rclone"
        cp /tmp/rclone-tasks.json /home/coder/.local/share/code-server/User/tasks.json
        code-server --install-extension actboy168.tasks &
    fi
}

execute_rclone_scripts() {
    RCLONE_AUTO_PUSH="${RCLONE_AUTO_PUSH:-true}"
    RCLONE_AUTO_PULL="${RCLONE_AUTO_PULL:-true}"
    RCLONE_REMOTE_PATH=${RCLONE_REMOTE_NAME:-code-server-remote}:${RCLONE_DESTINATION:-code-server-files}
    RCLONE_SOURCE_PATH=${RCLONE_SOURCE:-$START_DIR}

    echo "rclone sync $RCLONE_SOURCE_PATH $RCLONE_REMOTE_PATH $RCLONE_FLAGS --exclude **/node_modules/** -vv" >/home/coder/push_remote.sh
    echo "rclone sync $RCLONE_REMOTE_PATH $RCLONE_SOURCE_PATH $RCLONE_FLAGS --exclude **/node_modules/** -vv" >/home/coder/pull_remote.sh
    chmod +x push_remote.sh pull_remote.sh

    if [ $RCLONE_AUTO_PULL = "true" ]; then
        echo "[$PREFIX] Pulling existing files from remote..."
        /home/coder/pull_remote.sh &
    fi

    if [ $RCLONE_AUTO_PUSH = "true" ]; then
        echo "[$PREFIX] Pushing initial files to remote..."
        /home/coder/push_remote.sh &
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

echo "[$PREFIX] Installing vscode extensions"

install_vscode_extensions &

echo "[$PREFIX] Starting code-server..."
# Now we can run code-server with the default entrypoint
/usr/bin/entrypoint.sh --bind-addr 0.0.0.0:8080 $START_DIR
