FROM debian:stable-slim

# Set an environment variable to simplify the configuration later
ENV EXTRACFLAGS="-Ofast -flto -fuse-linker-plugin -ftree-loop-if-convert-stores"

# Install dependencies and build the application
RUN set -eux; \
    apt-get update; \
    apt-get install --no-install-recommends -y \
        autoconf \
        automake \
        curl \
        g++ \
        git \
        libcurl4-openssl-dev \
        libjansson-dev \
        libssl-dev \
        libgmp-dev \
        libz-dev \
        make \
        pkg-config; \
    git clone --recursive https://github.com/tpruvot/cpuminer-multi.git -b linux /tmp/cpuminer; \
    cd /tmp/cpuminer; \
    ./autogen.sh; \
    CFLAGS="-O2 $EXTRACFLAGS -DUSE_ASM -pg" ./configure --with-crypto --with-curl; \
    make install -j$(nproc); \
    apt-get purge --auto-remove -y \
        autoconf \
        automake \
        g++ \
        git \
        make \
        pkg-config; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*; \
    rm -rf /tmp/*; \
    cpuminer --cputest; \
    cpuminer --version

WORKDIR /cpuminer
COPY config.json /cpuminer
CMD ["cpuminer", "--config=config.json"]
