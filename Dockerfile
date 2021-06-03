FROM codercom/code-server:3.10.2

USER coder
ENV TERRAFORM_VERSION=0.15.4

RUN sudo chown -R coder:coder /home/coder/.local

COPY deploy-container/settings.json .local/share/code-server/User/settings.json
COPY deploy-container/entrypoint.sh /usr/bin/deploy-container-entrypoint.sh
COPY deploy-container/rclone-tasks.json /tmp/rclone-tasks.json
COPY ["deploy-container/entrypoint.sh", "deploy-container/extensions", "deploy-container/.bash_aliases",  "./"]

# Install vscode extensions
RUN for extension in $(cat extensions); do code-server --install-extension $extension done

# Install nvm, yarn and pnpm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
RUN /bin/bash -c "source .nvm/nvm.sh && nvm install 16 && npm -g install yarn pnpm"

# Install rclone
RUN sudo apt-get update && sudo apt-get install unzip -y
RUN curl https://rclone.org/install.sh | sudo bash -

# Install terraform(debian) and rclone
ADD --chown=coder:coder https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip terraform.zip
RUN sudo unzip -q ./terraform.zip -d /usr/bin && \
    sudo rm terraform.zip

ENV PORT=8080
ENTRYPOINT ["/usr/bin/deploy-container-entrypoint.sh"]