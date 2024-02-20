# This is the build stage for Substrate. Here we create the binary.
FROM docker.io/paritytech/ci-linux:production as builder

WORKDIR /substrate/bin/node-template
COPY . /substrate
RUN rustup default stable
RUN rustup update
RUN cargo build --locked --release

# This is the 2nd stage: a very small image where we copy the Substrate binary."
FROM docker.io/library/ubuntu:20.04
LABEL description="Multistage Docker image for Substrate: a platform for web3" \
	image.type="builder" \
	image.authors="info@gridpay.net" \
	image.vendor="Gridpay LTD" \
	image.description="Grids is a substrate chain for the Gridpay networks private blockhain" \
	image.source="https://github.com/ausipome/gridpay-chain/substrate/bin" \ 
	image.documentation="https://github.com/ausipome/gridpay-chain"

COPY --from=builder /target/release/substrate-node /usr/local/bin

RUN useradd -m -u 1000 -U -s /bin/sh -d /substrate substrate && \
	mkdir -p /data /substrate/.local/share/substrate && \
	chown -R substrate:substrate /data && \
	ln -s /data /substrate/.local/share/substrate && \
# Sanity checks
	ldd /usr/local/bin/substrate && \
# unclutter and minimize the attack surface
	rm -rf /usr/bin /usr/sbin && \
	/usr/local/bin/substrate --version

USER substrate
EXPOSE 30333 9933 9944 9615
VOLUME ["/data"]
