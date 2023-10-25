FROM nginx:latest

# Install git to provide polling updates
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y git && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Site lives here
WORKDIR /site

# Configure nginx
RUN echo 'include /site/config/server.conf;' > /etc/nginx/conf.d/default.conf

# Copy site
COPY --link . .

CMD ["/site/serve"]
