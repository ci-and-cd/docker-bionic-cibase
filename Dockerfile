
FROM cirepo/nix:2.0.4_bionic


COPY --chown=ubuntu:ubuntu --from=cirepo/bionic-nvm-node:9.11.1-archive /data/root /
COPY --chown=ubuntu:ubuntu --from=cirepo/bionic-pyenv-python:2.7.14_3.6.5-archive /data/root /
COPY --from=cirepo/bionic-rvm-ruby:2.4.1-archive /data/root /
COPY --from=cirepo/bionic-docker:18.05.0-archive /data/root /
COPY --chown=ubuntu:ubuntu --from=cirepo/bionic-rust:stable-archive /data/root /
COPY --from=cirepo/java-oracle:8u171-archive /data/root /
COPY --from=cirepo/java-oracle:9.0.4-archive /data/root /
COPY --from=cirepo/alpine-maven:3.5.3-archive /data/root /
COPY --from=cirepo/alpine-gradle:4.7-archive /data/root /
COPY --from=cirepo/bionic-graphviz:latest-archive /data/root /


ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
ENV M2_HOME /opt/maven
ENV GRADLE_HOME /opt/gradle
ENV NODE_HOME /opt/node
ENV PATH ${JAVA_HOME}/bin:${NODE_HOME}/bin:${M2_HOME}/bin:${GRADLE_HOME}/bin:${PATH}


RUN set -ex \
  && if [ "$(whoami)" != "root" ]; then sudo chown $(whoami):$(whoami) /home/$(whoami); sudo chown -R $(whoami):$(whoami) /home/$(whoami)/.gem /home/$(whoami)/.rvm; fi \
  && if [ "$(whoami)" != "root" ]; then sudo gpasswd -a $(whoami) docker; fi \
  && echo '\nexport JAVA_HOME=/usr/lib/jvm/java-8-oracle\n\
export M2_HOME=/opt/maven\n\
export NODE_HOME=/opt/node\n\
export GRADLE_HOME=/opt/gradle\n\n\
export PATH=$JAVA_HOME/bin:$NODE_HOME/bin:$GRADLE_HOME/bin:$M2_HOME/bin:$PATH\n' | sudo tee -a /etc/profile
