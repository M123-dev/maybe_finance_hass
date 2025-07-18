# syntax=docker/dockerfile:1

# Build image locally using
# docker buildx build --build-arg BUILD_ARCH=aarch64 .
# or with amd64


############################
# Stage 1: Clone the Repository
############################
ARG BUILD_ARCH
FROM --platform=${BUILD_ARCH} alpine/git AS clone
WORKDIR /src
RUN apk add --no-cache git && \
    git clone https://github.com/maybe-finance/maybe.git . && \
    git checkout ab6fdbbb6806e870362f44728f88f0c82831ff10

############################
# Stage 2: Base image with necessary dependencies
############################
ARG BUILD_ARCH
FROM --platform=${BUILD_ARCH} ruby:3.4.4-slim AS base

# Install base packages and clean up in one layer
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      curl \
      libvips \
      postgresql-client \
      libyaml-0-2 \
      jq \
      bash \
      git

# Set environment variables
ENV RAILS_ENV=production \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT=development

WORKDIR /rails
# Copy the entire repository from the clone stage
COPY --from=clone /src/ /rails/

############################
# Stage 3: Build stage
############################
FROM base AS build

# Install build dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      libpq-dev \
      pkg-config \
      libyaml-dev

# Leverage Docker caching by copying Gemfile(s) first
COPY --from=clone /src/Gemfile /rails/Gemfile
COPY --from=clone /src/Gemfile.lock /rails/Gemfile.lock
RUN bundle install --jobs `getconf _NPROCESSORS_ONLN`

# Now copy the rest of the application code from the remote repository
COPY --from=clone /src/ /rails/

# Clean bundler caches to reduce image size
RUN rm -rf ~/.bundle/ \
    "${BUNDLE_PATH}"/ruby/*/cache \
    "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

# Precompile bootsnap and assets in one go
RUN bundle exec bootsnap precompile --gemfile && \
    bundle exec bootsnap precompile -j 0 app/ lib/ && \
    SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

############################
# Stage 4: Final image
############################
FROM base AS final

# Copy built artifacts from the build stage
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Copy and set permissions for the startup script
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

WORKDIR /rails
ENTRYPOINT ["/usr/local/bin/run.sh"]
CMD ["./bin/rails", "server"]
