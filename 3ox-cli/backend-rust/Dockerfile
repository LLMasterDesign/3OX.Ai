FROM rust:1.75-slim as builder

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    pkg-config \
    libssl-dev \
    ruby \
    && rm -rf /var/lib/apt/lists/*

# Copy Cargo files
COPY Cargo.toml ./

# Create a dummy main.rs to build dependencies
RUN mkdir src && echo "fn main() {}" > src/main.rs

# Build dependencies
RUN cargo build --release

# Copy source code
COPY src ./src

# Build the application
RUN cargo build --release

# Runtime stage
FROM debian:bookworm-slim

WORKDIR /app

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    ruby \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy the binary
COPY --from=builder /app/target/release/3ox-sets-viewer-backend /app/

# Create logs directory
RUN mkdir -p /app/logs

# Create 3OX.SETS directory
RUN mkdir -p /app/3OX.SETS

# Expose port
EXPOSE 8001

# Set environment variables
ENV 3OX_SETS_PATH=/app/3OX.SETS
ENV RUST_LOG=info

# Run the application
CMD ["./3ox-sets-viewer-backend"]