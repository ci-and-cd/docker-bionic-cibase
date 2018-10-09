
FROM cirepo/nix:2.1.1-bionic


COPY --chown=ubuntu:ubuntu --from=cirepo/nvm-node:9.11.1-bionic-archive /data/root /
COPY --chown=ubuntu:ubuntu --from=cirepo/pyenv-python:2.7.15_3.6.6-bionic-archive /data/root /
COPY --from=cirepo/rvm-ruby:2.4.1-bionic-archive /data/root /
COPY --from=cirepo/docker:18.06.1-bionic-archive /data/root /
COPY --chown=ubuntu:ubuntu --from=cirepo/rust:stable-bionic-archive /data/root /
COPY --from=cirepo/java-oracle:8u181-alpine-3.8-archive /data/root /
COPY --from=cirepo/java-oracle:9.0.4-alpine-3.8-archive /data/root /
COPY --from=cirepo/java-oracle:10.0.2-alpine-3.8-archive /data/root /
COPY --from=cirepo/maven:3.5.4-alpine-archive /data/root /
COPY --from=cirepo/gradle:4.7-alpine-archive /data/root /
COPY --from=cirepo/graphviz:latest-bionic-archive /data/root /


ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
ENV M2_HOME /opt/maven
ENV GRADLE_HOME /opt/gradle
ENV NODE_HOME /opt/node
ENV PATH ${JAVA_HOME}/bin:${NODE_HOME}/bin:${M2_HOME}/bin:${GRADLE_HOME}/bin:${PATH}


RUN set -ex \
  && if [ "${USER:-ubuntu}" != "root" ]; then \
        sudo chown ${USER:-ubuntu}:${USER:-ubuntu} /home/${USER:-ubuntu}; \
        if [ -d /home/${USER:-ubuntu}/.pyenv ]; then sudo cp -r /home/${USER:-ubuntu}/.pyenv /root/; sudo chown -R ${USER:-ubuntu}:${USER:-ubuntu} /home/${USER:-ubuntu}/.pyenv; fi; \
        if [ -d /home/${USER:-ubuntu}/.gem ]; then sudo cp -r /home/${USER:-ubuntu}/.gem /root/; sudo chown -R ${USER:-ubuntu}:${USER:-ubuntu} /home/${USER:-ubuntu}/.gem; fi; \
        if [ -d /home/${USER:-ubuntu}/.rvm ]; then sudo cp -r /home/${USER:-ubuntu}/.rvm /root/; sudo chown -R ${USER:-ubuntu}:${USER:-ubuntu} /home/${USER:-ubuntu}/.rvm; fi; \
     fi \
  && if [ "${USER:-ubuntu}" != "root" ]; then sudo gpasswd -a ${USER:-ubuntu} docker; fi \
  && echo '\nexport JAVA_HOME=/usr/lib/jvm/java-8-oracle\n\
export M2_HOME=/opt/maven\n\
export NODE_HOME=/opt/node\n\
export GRADLE_HOME=/opt/gradle\n\n\
export PATH=$JAVA_HOME/bin:$NODE_HOME/bin:$GRADLE_HOME/bin:$M2_HOME/bin:$PATH\n' | sudo tee -a /etc/profile \
  && echo "pyenv and rvm for user root" \
  && sudo touch /root/.profile \
  && echo '\nexport PATH="${HOME}/.pyenv/bin:${PATH}"\n\
if which pyenv > /dev/null; then eval "$(pyenv init -)"; eval "$(pyenv virtualenv-init -)"; fi\n\
' | sudo tee -a /root/.profile \
  && echo '\n\
# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.\n\
export PATH="$PATH:$HOME/.rvm/bin"\n\
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*\n\
' | sudo tee -a /root/.profile \
  && echo "pyenv and rvm for user ${USER:-ubuntu}" \
  && touch /home/${USER:-ubuntu}/.profile \
  && echo '\nexport PATH="${HOME}/.pyenv/bin:${PATH}"\n\
if which pyenv > /dev/null; then eval "$(pyenv init -)"; eval "$(pyenv virtualenv-init -)"; fi\n\
' | tee -a /home/${USER:-ubuntu}/.profile \
  && echo '\n\
# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.\n\
export PATH="$PATH:$HOME/.rvm/bin"\n\
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*\n\
' | tee -a /home/${USER:-ubuntu}/.profile

RUN set -ex \
  && echo 'make directories' \
  && mkdir -p /home/${USER:-ubuntu}/.docker && chmod 775 /home/${USER:-ubuntu}/.docker \
  && mkdir -p /home/${USER:-ubuntu}/.gnupg && chmod 700 /home/${USER:-ubuntu}/.gnupg \
  && mkdir -p /home/${USER:-ubuntu}/.gradle && chmod 775 /home/${USER:-ubuntu}/.gradle \
  && mkdir -p /home/${USER:-ubuntu}/.m2 && chmod 775 /home/${USER:-ubuntu}/.m2 \
  && mkdir -p /home/${USER:-ubuntu}/.ssh && chmod 755 /home/${USER:-ubuntu}/.ssh \
  && touch /home/${USER:-ubuntu}/.ssh/config \
  && echo '\n\
# ssh config\n\
Host *\n\
    StrictHostKeyChecking no\n\
    UserKnownHostsFile /dev/null\n\
\n' | tee -a /home/${USER:-ubuntu}/.ssh/config \
  && chmod 644 /home/${USER:-ubuntu}/.ssh/config \
  && echo 'setup user group' \
  && sudo usermod -a -G docker ${USER:-ubuntu}
