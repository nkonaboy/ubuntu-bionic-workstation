FROM ubuntu:bionic

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get -y install \
    binutils \
    bsdutils \
    build-essential \
    bzip2 \
    coreutils \
    cron \
    curl \
    dnsutils \
    findutils \
    git \
    gzip \
    less \
    moreutils \
    net-tools \
    openssh-client \
    openssh-server \
    p7zip-full \
    perl \
    python \
    python-pip \
    python3 \
    python3-pip \
    rsync \
    ruby \
    sed \
    sudo \
    vim \
    wget \
    zsh \
    dash

# This is the segment I drop in additional packages, so for above steps docker-cache can be used.
RUN apt-get install -y iproute2 man locales tmux nano

# Generating locales. A must-have for my favourite theme `agnoster`
RUN sudo locale-gen "en_US.UTF-8"
RUN echo 'LANG="en_US.UTF-8"' > /etc/profile.d/locale.sh
RUN echo 'LANGUAGE="en_US.UTF-8"' >> /etc/profile.d/locale.sh
RUN echo 'LC_ALL="en_US.UTF-8"' >> /etc/profile.d/locale.sh

# Terminal support so you can use stuff like Vim at higher resolution
ENV TERM=xterm

# Need these dirs for sshd
RUN mkdir -p /var/run/sshd /run/sshd

# Setting root password. Don't do this at home
RUN echo 'root:<setRootPasswordHere>' | chpasswd

# Modify sshd_config to allow root login. 
# Goes without saying, this and above can be removed if you figured out how to use ssh key within your environment
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Taken from here https://docs.docker.com/engine/examples/running_ssh_service/
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# Creating my user, baking my password into login, giving sudo permission with no password prompt
RUN echo 'yourUsername:x:1000:1000::/home/yourUsername:/usr/bin/zsh' >> /etc/passwd
RUN echo 'yourUsername:x:1000:' >> /etc/group
RUN echo 'yourUsername:$6$scm9LOg4$<TRUNCATED salted password in shadow file>:17706:0:99999:7:::' >> /etc/shadow
RUN usermod -aG sudo yourUsername
RUN echo 'yourUsername ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# Taken from here https://docs.docker.com/engine/examples/running_ssh_service/
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
