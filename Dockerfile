
FROM cirepo/nix:2.2.1-bionic


COPY --chown=ubuntu:ubuntu --from=cirepo/nvm-node:10.15.3-bionic-archive /data/root /
COPY --chown=ubuntu:ubuntu --from=cirepo/pyenv-python:2.7.16_3.7.2-bionic-archive /data/root /
COPY --from=cirepo/rvm-ruby:2.6.1-bionic-archive /data/root /
COPY --from=cirepo/docker:18.09.3-bionic-archive /data/root /
COPY --chown=ubuntu:ubuntu --from=cirepo/rust:stable-bionic-archive /data/root /
COPY --from=cirepo/java-11-openjdk:11.0.2-alpine-3.9-archive /data/root /
COPY --from=cirepo/maven:3.6.0-alpine-archive /data/root /
COPY --from=cirepo/gradle:5.2.1-alpine-archive /data/root /
COPY --from=cirepo/graphviz:latest-bionic-archive /data/root /


ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk-amd64
ENV M2_HOME /opt/maven
ENV GRADLE_HOME /opt/gradle
ENV NODE_HOME /opt/node
ENV PATH ${JAVA_HOME}/bin:${NODE_HOME}/bin:${M2_HOME}/bin:${GRADLE_HOME}/bin:${PATH}


RUN set -ex \
  && sudo chown root:root /tmp \
  && sudo chmod 777 /tmp


# Install openjdk-8-jdk into /usr/lib/jvm/java-8-openjdk-amd64
RUN set -ex \
  && sudo ln -s /usr/lib/jvm/java-11-openjdk-amd64 /usr/lib/jvm/java-11-openjdk \
  && sudo ln -s /usr/lib/jvm/java-11-openjdk-amd64 /usr/lib/jvm/java-11-oracle \
  && sudo apt -y update \
  && sudo apt-cache madison openjdk-8-jdk \
  && sudo apt -yq install openjdk-8-jdk \
  && sudo ln -s /usr/lib/jvm/java-8-openjdk-amd64 /usr/lib/jvm/java-8-openjdk \
  && sudo ln -s /usr/lib/jvm/java-8-openjdk-amd64 /usr/lib/jvm/java-8-oracle \
  && sudo rm -rf /usr/lib/jvm/java-8-openjdk-amd64/*src.zip \
       /usr/lib/jvm/java-8-openjdk-amd64/lib/missioncontrol \
       /usr/lib/jvm/java-8-openjdk-amd64/lib/visualvm \
       /usr/lib/jvm/java-8-openjdk-amd64/lib/*javafx* \
       /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/plugin.jar \
       /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/ext/jfxrt.jar \
       /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/javaws \
       /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/javaws.jar \
       /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/desktop \
       /usr/lib/jvm/java-8-openjdk-amd64/jre/plugin \
       /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/deploy* \
       /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/*javafx* \
       /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/*jfx* \
       /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/amd64/libdecora_sse.so \
       /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/amd64/libprism_*.so \
       /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/amd64/libfxplugins.so \
       /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/amd64/libglass.so \
       /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/amd64/libgstreamer-lite.so \
       /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/amd64/libjavafx*.so \
       /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/amd64/libjfx*.so \
  && POLICY_DIR="UnlimitedJCEPolicyJDK8" \
  && sudo mkdir -p /data \
  && if [ ! -f /data/jce_policy-8.zip ]; then \
       ${ARIA2C_DOWNLOAD} --header="Cookie: oraclelicense=accept-securebackup-cookie" \
       -d /data -o jce_policy-8.zip ${IMAGE_ARG_FILESERVER:-http://download.oracle.com}/otn-pub/java/jce/8/jce_policy-8.zip; \
     fi \
  && unzip /data/jce_policy-8.zip \
  && sudo cp -f ${POLICY_DIR}/US_export_policy.jar /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/security/US_export_policy.jar \
  && sudo cp -f ${POLICY_DIR}/local_policy.jar /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/security/local_policy.jar \
  && rm -rf ${POLICY_DIR} \
  && rm -f /data/jce_policy-8.zip \
  && sudo apt -q -y autoremove \
  && sudo apt -q -y clean && sudo rm -rf /var/lib/apt/lists/* && sudo rm -f /var/cache/apt/*.bin


RUN set -ex \
  && if [ "${USER:-ubuntu}" != "root" ]; then \
        sudo chown ${USER:-ubuntu}:${USER:-ubuntu} /home/${USER:-ubuntu}; \
        if [ -d /home/${USER:-ubuntu}/.pyenv ]; then sudo cp -r /home/${USER:-ubuntu}/.pyenv /root/; sudo chown -R ${USER:-ubuntu}:${USER:-ubuntu} /home/${USER:-ubuntu}/.pyenv; fi; \
        if [ -d /home/${USER:-ubuntu}/.gem ]; then sudo cp -r /home/${USER:-ubuntu}/.gem /root/; sudo chown -R ${USER:-ubuntu}:${USER:-ubuntu} /home/${USER:-ubuntu}/.gem; fi; \
        if [ -d /home/${USER:-ubuntu}/.rvm ]; then sudo cp -r /home/${USER:-ubuntu}/.rvm /root/; sudo chown -R ${USER:-ubuntu}:${USER:-ubuntu} /home/${USER:-ubuntu}/.rvm; fi; \
     fi \
  && if [ "${USER:-ubuntu}" != "root" ]; then sudo gpasswd -a ${USER:-ubuntu} docker; fi \
  && echo '\nexport JAVA_HOME=/usr/lib/jvm/java-11-openjdk\n\
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

RUN set -ex \
  && echo ===== Install ansible ===== \
  && sudo apt -y update \
  && sudo apt -y install python-minimal \
  && sudo apt-add-repository -y ppa:ansible/ansible \
  && sudo apt -y update \
  && sudo apt -y install ansible rsync \
  && sudo apt -q -y autoremove \
  && sudo apt -q -y clean && sudo rm -rf /var/lib/apt/lists/* && sudo rm -f /var/cache/apt/*.bin \
