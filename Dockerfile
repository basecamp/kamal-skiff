# Use the official Ruby 3.2.0 Alpine image as the base image
FROM ruby:3.2.0-alpine

# Install  docker/buildx-bin
COPY --from=docker/buildx-bin /buildx /usr/libexec/docker/cli-plugins/docker-buildx

# Set the working directory to /skiff
WORKDIR /skiff

# Copy the Gemfile, Gemfile.lock into the container
COPY Gemfile Gemfile.lock kamal-skiff.gemspec ./

# Required in skiff.gemspec
COPY lib/skiff/version.rb /skiff/lib/skiff/version.rb

# Install system dependencies
RUN apk add --no-cache --update build-base git docker openrc openssh-client-default \
    && rc-update add docker boot \
    && gem install bundler --version=2.4.3 \
    && bundle install

# Copy the rest of our application code into the container.
# We do this after bundle install, to avoid having to run bundle
# every time we do small fixes in the source code.
COPY . .

# Install the gem locally from the project folder
RUN gem build kamal-skiff.gemspec && \
    gem install ./kamal-skiff-*.gem --no-document

# Set the working directory to /workdir
WORKDIR /workdir

# Tell git it's safe to access /workdir/.git even if
# the directory is owned by a different user
RUN git config --global --add safe.directory /workdir

# Set the entrypoint to run the installed binary in /workdir
# Example:  docker run -it -v "$PWD:/workdir" skiff init
ENTRYPOINT ["skiff"]
