#!/usr/bin/env bash

# Setup rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain 1.72.1
RUN rustup toolchain install 1.72.1
RUN rustup default 1.72.1
RUN rustup target add wasm32-wasi --toolchain=1.72.1
RUN cargo install cargo-nextest@0.9.50 --locked

# Python
python -m pip install --upgrade pip setuptools wheel
