# 3OX.Ai — minimal runtime image
# Ruby + Rust for agent cubes. Use with docker run or docker-compose.

FROM ruby:3.2-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install Rust (for brain compilation)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

WORKDIR /app

# Copy repo
COPY . .

# Default: run root station
CMD ["ruby", ".3ox/.vec3/rc/run.rb", "status"]
