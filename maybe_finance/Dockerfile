# Stage 1: Clone the Maybe Finance repository
ARG BUILD_ARCH
ARG BUILD_FROM
FROM --platform=$BUILD_ARCH $BUILD_FROM AS clone
WORKDIR /src
RUN apk add --no-cache git && \
    git clone https://github.com/maybe-finance/maybe.git . && \
    git checkout 79e1a2c0ffd5191fe6c040da68a311e1c1e6beb4

# Stage 2: Base image with necessary dependencies
ARG BUILD_ARCH
FROM --platform=${BUILD_ARCH} ruby:3.4.1-slim AS base

# Install base packages
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl libvips postgresql-client jq bash && \
    rm -rf /var/lib/apt/lists/*

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

# Copy cloned source code
COPY --from=clone /src /rails
WORKDIR /rails

# Stage 3: Build stage
FROM base AS build

# Install build dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential git libpq-dev pkg-config && \
    rm -rf /var/lib/apt/lists/*

# Install gems
RUN bundle install
RUN rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git
RUN bundle exec bootsnap precompile --gemfile

# Precompile bootsnap and assets
RUN bundle exec bootsnap precompile -j 0 app/ lib/
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# Final stage
FROM base

# Create storage directory in mapped volume path
RUN mkdir -p /data/storage && \
    ln -s /data/storage /rails/storage && \
    chmod -R 777 /data

# Clean up
RUN rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Copy built artifacts
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Copy startup script
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Set permissions to avoid issues with config file
RUN mkdir -p /data && chmod -R 777 /data

# Keep running as root (no user switch)

# Entrypoint prepares the database.
ENTRYPOINT ["/usr/local/bin/run.sh"]

CMD ["./bin/rails", "server"]
