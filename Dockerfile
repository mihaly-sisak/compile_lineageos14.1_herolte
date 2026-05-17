# Dockerfile for LineageOS herolte build environment on Ubuntu 22.04
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN dpkg --add-architecture i386 && apt update && apt install -y \
    # get tools
    wget \
    # core build tools
    bc bison build-essential ccache curl flex g++-multilib gcc-multilib git git-lfs gnupg gperf imagemagick protobuf-compiler python3-protobuf lib32readline-dev lib32z1-dev libdw-dev libelf-dev libgnutls28-dev lz4 libsdl1.2-dev libssl-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc xxd zip zlib1g-dev \
    # ncurses
    libncurses5-dev:i386 libncurses5 libncurses5-dev \
    # java jdk
    openjdk-8-jdk \
    # python2
    python2 python2-pip-whl python2-setuptools-whl virtualenv \
    # clean up
    && apt clean && rm -rf /var/lib/apt/lists/*

# enable java 8 TLSv1, TLSv1.1
RUN sed -i "s/ TLSv1, TLSv1\.1,//g" /etc/java-8-openjdk/security/java.security

# create build root folder
RUN mkdir /android

# get google platform-tools
RUN wget -P /android/ https://dl.google.com/android/repository/platform-tools-latest-linux.zip && \
    unzip /android/platform-tools-latest-linux.zip -d /android/

# get google repo
RUN curl https://storage.googleapis.com/git-repo-downloads/repo > /android/platform-tools/repo && \
    chmod a+x /android/platform-tools/repo

ENV PATH="/android/platform-tools:$PATH"

# git
RUN git config --global user.email "[email protected]" && \
    git config --global user.name "Your Name" && \
    git lfs install && \
    git config --global trailer.changeid.key "Change-Id"

# ccache is intentionally left out

# android jack
ENV ANDROID_JACK_VM_ARGS="-Dfile.encoding=UTF-8 -XX:+TieredCompilation -Xmx4G"

# set up a non-root user to match your host UID (avoids permission issues)
ARG USER_ID=1000
ARG GROUP_ID=1000
RUN groupadd -g ${GROUP_ID} builder && \
    useradd -m -u ${USER_ID} -g builder builder

USER builder
ENV USER="builder"
WORKDIR /home/builder

# build lineageos mounted on /android/lineage
CMD virtualenv --python=python2 /home/builder/.lineage_venv && \
    . /home/builder/.lineage_venv/bin/activate && \
    cd /android/lineage && \
    bash -c "source build/envsetup.sh && breakfast herolte && brunch herolte"


