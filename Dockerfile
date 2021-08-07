FROM python:3-slim-buster

# Setup Meh    
RUN apt-get -qq update \
    && apt-get -qq -y install software-properties-common curl gpg \
    && apt-add-repository non-free \
    && echo "deb http://deb.debian.org/debian experimental main" > /etc/apt/sources.list.d/experimental.list \
    # for qbittorrent enchaned
    && echo 'deb http://download.opensuse.org/repositories/home:/nikoneko:/test/Debian_10/ /' | tee /etc/apt/sources.list.d/home:nikoneko:test.list \
    && curl -fsSL https://download.opensuse.org/repositories/home:nikoneko:test/Debian_10/Release.key | gpg --dearmor | tee /etc/apt/trusted.gpg.d/home_nikoneko_test.gpg > /dev/null \
    && apt-get -qq update \
    && apt-get -qq -y install --no-install-recommends \
        # build deps
        autoconf automake g++ gcc git libtool m4 make swig \
        # mega sdk deps
        libc-ares-dev libcrypto++-dev libcurl4-openssl-dev \
        libfreeimage-dev libsodium-dev libsqlite3-dev libssl-dev zlib1g-dev \
        # mirror bot deps
        wget jq locales pv mediainfo python3-lxml unzip aria2 xz-utils neofetch qbittorrent-enhanced ca-certificates \
    && apt-get -qq -t experimental upgrade -y && apt-get -qq -y autoremove --purge \
    && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
    && locale-gen \
    # requirements mirror-bot
    && wget https://raw.githubusercontent.com/Ncode2014/megaria/req/requirements.txt \
    && pip3 install --no-cache-dir -r requirements.txt \
    && rm requirements.txt \
    # setup mega sdk
    && MEGA_SDK_VERSION='3.8.2' \
    && git clone https://github.com/meganz/sdk.git --depth=1 -b v$MEGA_SDK_VERSION ~/home/sdk \
    && cd ~/home/sdk && rm -rf .git \
    && autoupdate -fIv && ./autogen.sh \
    && ./configure --disable-silent-rules --enable-python --with-sodium --disable-examples \
    && make -j$(nproc --all) \
    && cd bindings/python/ && python3 setup.py bdist_wheel \
    && cd dist/ && pip3 install --no-cache-dir megasdk-$MEGA_SDK_VERSION-*.whl 

# rewrite Some important stuff to make efficient time
RUN mkdir -p /tmp/ && cd /tmp/ \
    && gdown --id 1pwY8R_nCkVorOqzrkSJkaSY2dZUiHgau -O /tmp/megaria.tar.gz \
    && tar -xzvf megaria.tar.gz && cd megaria/ \
    && cp -v ffmpeg ffprobe /usr/bin \
    && chmod +x /usr/bin/ffmpeg /usr/bin/ffprobe \
    && rm -rf megaria && cd ~/home && rm -f ~/tmp/megaria.tar.gz \
    # 7zip unofficial
    && cd /tmp/ \
    && wget https://www.7-zip.org/a/7z2102-linux-x64.tar.xz \
    && tar -xvf 7z2102-linux-x64.tar.xz \
    && cp -v 7zz /usr/bin/ && chmod +x /usr/bin/7zz \
    && rm -f ~/tmp/7z2102-linux-x64.tar.xz && rm -r /tmp/* \

    # cleanup env
    && apt-get -qq -y purge --autoremove \
       autoconf gpg automake g++ gcc libtool m4 make software-properties-common swig \
    && apt-get -qq -y clean \
    && rm -rf -- /var/lib/apt/lists/* /var/cache/apt/archives/* /etc/apt/sources.list.d/* /home/sdk

# just adding
WORKDIR /usr/src/app
RUN chmod 777 /usr/src/app

# enviroments
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8
