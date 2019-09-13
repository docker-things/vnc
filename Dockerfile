# FROM ubuntu:18.04 AS sigil-builder

# # BASE GUI
# RUN echo "\n > UPDATE REPO\n" \
#  && apt-get update \
#  \
#  && echo "\n > INSTALL SIGIL BUILD-DEPENDENCIES\n" \
#  && apt-get install -y --no-install-recommends \
#         wget \
#  \
#  && echo "\n > CREATE USER\n" \
#  && groupadd -g $DOCKER_GROUPID $DOCKER_USERNAME \
#  && useradd -b /home -d /home/$DOCKER_USERNAME -g $DOCKER_GROUPID -m -u $DOCKER_USERID $DOCKER_USERNAME \
#  && usermod -G plugdev $DOCKER_USERNAME \
#  \
#  && echo "\n > CLEANUP\n" \
#  && apt-get autoremove -y \
#  && apt-get clean -y \
#  && apt-get autoclean -y \
#  && rm -rf \
#         /tmp/* \
#         /var/tmp/*

# RUN wget \https://github.com/Sigil-Ebook/Sigil/archive/0.9.10.zip


FROM ubuntu:18.04

# ARGS
ARG DOCKER_USERID
ARG DOCKER_GROUPID
ARG DOCKER_USERNAME
ARG PHP_VERSION

# ENVIRONMENT
ENV DEBIAN_FRONTEND="noninteractive" \
    TERM="xterm" \
    LANG="C.UTF-8" \
    LC_ALL="C.UTF-8"

# BASE GUI
RUN echo -e "\n > SET RANDOM ROOT PASSWORD\n" \
 && echo "root:$(echo "`date`-`hostname`" | md5sum -t | awk -F' ' '{print $1}')" | chpasswd \
 \
 && echo "\n > UPDATE REPO\n" \
 && apt-get update \
 \
 && echo "\n > INSTALL DEPENDENCIES\n" \
 && apt-get install -y --no-install-recommends \
        apt-transport-https \
        apt-utils \
        ca-certificates \
        gpg-agent \
        software-properties-common \
 \
 && echo "\n > INSTALL VNC & XFCE4\n" \
 && apt-get install -y --no-install-recommends \
        vnc4server \
        xfce4 \
        xorg \
        dbus-x11 \
        xfce4-goodies \
 \
 && echo "\n > INSTALL BASICS\n" \
 && apt-get install -y --no-install-recommends \
        curl \
        nano \
        rsync \
        ssh \
        sudo \
        rename \
        less \
        wget \
 \
 && echo "\n > CREATE USER\n" \
 && groupadd -g $DOCKER_GROUPID $DOCKER_USERNAME \
 && useradd -b /home -d /home/$DOCKER_USERNAME -g $DOCKER_GROUPID -m -u $DOCKER_USERID $DOCKER_USERNAME \
 && usermod -G plugdev $DOCKER_USERNAME \
 \
 && echo "\n > ADD USER TO SUDOERS\n" \
 && mkdir -p /etc/sudoers.d \
 && echo "$DOCKER_USERNAME ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$DOCKER_USERNAME \
 && chmod 0440 /etc/sudoers.d/$DOCKER_USERNAME\
 \
 && echo "\n > CLEANUP\n" \
 && apt-get autoremove -y \
 && apt-get clean -y \
 && apt-get autoclean -y \
 && rm -rf \
        /tmp/* \
        /var/tmp/*

RUN echo "\n > INSTALL PHP\n" \
 && add-apt-repository -y ppa:ondrej/php \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
        php${PHP_VERSION}-cli \
        php${PHP_VERSION}-curl \
 \
 && echo "\n > INSTALL CALIBRE\n" \
 && apt-get install -y --no-install-recommends \
        xz-utils \
 && wget -nv -O- https://download.calibre-ebook.com/linux-installer.sh | sh /dev/stdin \
 \
 && echo "\n > SUBLIME TEXT - REPO\n" \
 && curl -fsSL https://download.sublimetext.com/sublimehq-pub.gpg | apt-key add - \
 && add-apt-repository "deb https://download.sublimetext.com/ apt/stable/" \
 && echo "\n > SUBLIME TEXT - UPDATE REPO\n" \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
        sublime-text \
 \
 && echo "\n > CLEANUP\n" \
 && apt-get autoremove -y \
 && apt-get clean -y \
 && apt-get autoclean -y \
 && rm -rf \
        /tmp/* \
        /var/tmp/*

RUN echo "\n > INSTALL APPS\n" \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
        firefox \
        chromium-browser \
        libreoffice \
        asunder \
        clementine \
        audacity \
        id3tool \
        vlc \
        eject \
        git \
        subversion \
        flac \
        cuetools \
        shntool \
        evince \
 \
 && echo "\n > CLEANUP\n" \
 && apt-get autoremove -y \
 && apt-get clean -y \
 && apt-get autoclean -y \
 && rm -rf \
        /tmp/* \
        /var/tmp/*

RUN echo "\n > INSTALL APPS - PART 2\n" \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
        file-roller \
        sqlitebrowser \
 \
 && echo "\n > CLEANUP\n" \
 && apt-get autoremove -y \
 && apt-get clean -y \
 && apt-get autoclean -y \
 && rm -rf \
        /tmp/* \
        /var/tmp/*

# RUN curl -fSL -o /tmp/teamviewer_linux.deb https://download.teamviewer.com/download/linux/teamviewer_amd64.deb \
#  && dpkg -i /tmp/teamviewer_linux.deb \
#  || apt-get install -yq --no-install-recommends -f

# APPS
# SET USER PASSWORD
ARG DOCKER_USER_PASS
RUN echo -e "\n > SET USER PASSWORD\n" \
 && echo "$DOCKER_USERNAME:$DOCKER_USER_PASS" | chpasswd

# ADD SCRIPTS
COPY install /scripts
RUN echo "\n > CONFIG VNC STARTUP\n" \
 && chown $DOCKER_USERNAME:$DOCKER_USERNAME -R /scripts/user \
 && chmod 777 /scripts/user \
 && chmod 544 /scripts/user/*

# SWITCH USER
USER $DOCKER_USERNAME
ENV USER="$DOCKER_USERNAME"
WORKDIR /home/$DOCKER_USERNAME

# CREATE VNC PASSWORD
ARG VNC_PASSWORD
RUN echo "\n > CREATE VNC PASSWORD\n" \
 && echo "$VNC_PASSWORD\n$VNC_PASSWORD\nn" | vncpasswd \
 && mv /home/$DOCKER_USERNAME/.vnc/passwd /scripts/user/ \
 && rm -rf /home/$DOCKER_USERNAME/*

# PORT
EXPOSE 5901

# LAUNCH VNC
ENTRYPOINT ["/bin/bash", "/scripts/launcher.sh"]
