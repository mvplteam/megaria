FROM narima/base:bull 

# Setup Meh    
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN apt-get -qq update && apt-get -qq -y install --no-install-recommends software-properties-common curl gpg \
    && apt-add-repository non-free \
    # for important package
    && apt-get -qq update \
    && apt-get -qq -y install --no-install-recommends \
        # build deps
        autoconf automake g++ gcc git libtool m4 make swig \
        # mega sdk deps
        libc-ares-dev libcrypto++-dev libcurl4-openssl-dev \
        libfreeimage-dev libsodium-dev libsqlite3-dev libssl-dev zlib1g-dev  \
        # mirror bot deps
        wget jq locales pv mediainfo python3-lxml unzip aria2 xz-utils \
        neofetch qbittorrent-nox p7zip-full p7zip-rar ffmpeg \
        # arm64 stuff
        libpq-dev libffi-dev \
    && apt-get -qq -y autoremove --purge \
    && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
    && locale-gen \
    # requirements mirror-bot
    && curl https://raw.githubusercontent.com/Ncode2014/megaria/req/requirements.txt -o requirements.txt\
    && pip3 install --no-cache-dir -r requirements.txt \
    && rm -f requirements.txt \
    # setup mega sdk
    && MEGA_SDK_VERSION='3.9.5' \
    && git clone https://github.com/meganz/sdk.git --depth=1 -b v$MEGA_SDK_VERSION ~/home/sdk \
    && cd ~/home/sdk && rm -rf .git \
    && autoupdate -fIv && ./autogen.sh \
    && ./configure --disable-silent-rules --enable-python --with-sodium --disable-examples \
    && make -j$(nproc --all) \
    && cd bindings/python/ && python3 setup.py bdist_wheel \
    && cd dist/ && pip3 install --no-cache-dir megasdk-$MEGA_SDK_VERSION-*.whl 

    # cleanup env
RUN apt-get -qq -y purge --autoremove \
       autoconf gpg automake g++ gcc libtool m4 make software-properties-common swig \
    && apt-get -qq -y clean && apt-get clean --dry-run \
    && rm -rf -- /var/lib/apt/lists/* /var/cache/apt/archives/* /etc/apt/sources.list.d/* /home/sdk

# just adding
WORKDIR /usr/src/app
RUN chmod 777 /usr/src/app

# enviroments
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8
