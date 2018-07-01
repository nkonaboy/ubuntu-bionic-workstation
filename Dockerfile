FROM ubuntu:bionic

RUN apt-get update
RUN apt-get upgrade -y

# Main packages from apt.d
ADD apt.d /tmp/apt.d
RUN bash -c 'set -xeuo pipefail && apt-get install -y $(cat /tmp/apt.d/*.list)'

# Generating locales.
ARG LOCALE=en_US.UTF-8
RUN sudo locale-gen $LOCALE
RUN echo LANG=$LOCALE > /etc/profile.d/locale.sh
RUN echo LANGUAGE=$LOCALE >> /etc/profile.d/locale.sh
RUN echo LC_ALL=$LOCALE >> /etc/profile.d/locale.sh
RUN echo "Following LOCALE is set" && cat /etc/profile.d/locale.sh

# Terminal support so you can use stuff like Vim at higher resolution
ENV TERM=xterm

# Need these dirs for sshd
RUN mkdir -p /var/run/sshd /run/sshd

# Add user and set password
ARG USERNAME=ubuntu
ARG PASSWORD=dummyPassword
ARG LOGINSHELL=/bin/bash
RUN adduser --disabled-password --gecos "" --shell $LOGINSHELL $USERNAME
RUN echo "$USERNAME:$PASSWORD" | chpasswd

# Give super-user permissions to user
RUN echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# SSH login fix. Taken from here https://docs.docker.com/engine/examples/running_ssh_service/
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# Taken from here https://docs.docker.com/engine/examples/running_ssh_service/
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
