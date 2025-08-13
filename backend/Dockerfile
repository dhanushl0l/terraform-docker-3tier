# FROM rust:1.80 AS builder
# WORKDIR /app
# COPY . .

# RUN apt-get update && apt-get install -y \
#     build-essential \
#     pkg-config \
#     libssl-dev \
#     libpq-dev \
#     && rm -rf /var/lib/apt/lists/*

# RUN cargo build --release

# FROM debian:bookworm-slim
# WORKDIR /app
# COPY --from=builder /app/target/release/backend /app/backend
# EXPOSE 8081
# CMD ["./backend"]


FROM debian:bookworm-slim
WORKDIR /app

# Copy already-built binary from host to container
COPY ./target/release/backend /app/backend

# Install runtime dependencies for Postgres
RUN apt-get update && apt-get install -y \
    libssl3 \
    libpq5 \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 8081
CMD ["./backend"]
