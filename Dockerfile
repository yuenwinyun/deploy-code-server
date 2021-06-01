FROM codercom/code-server:3.10.2

USER coder
ENV SHELL=/bin/bash

COPY deploy-container/settings.json .local/share/code-server/User/settings.json
COPY deploy-container/rclone-tasks.json /tmp/rclone-tasks.json
COPY deploy-container/extensions deploy-container/.bash_aliases ./
COPY deploy-container/entrypoint.sh /usr/bin/deploy-container-entrypoint.sh

RUN sudo chown -R coder:coder /home/coder/.local
RUN sudo mkdir project && sudo chown -R coder:coder /home/coder/project

RUN curl -fsSL https://deb.nodesource.com/setup_15.x | sudo bash -
RUN sudo apt-get update && sudo apt-get install software-properties-common gnupg2 nodejs -y

RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
RUN sudo apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
RUN sudo apt-get update && \
    sudo apt-get install terraform -y && \
    sudo npm -g install yarn pnpm && \
    sudo apt-get clean

ENV PORT=80
ENTRYPOINT ["/usr/bin/deploy-container-entrypoint.sh"]
