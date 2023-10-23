# Skiff

Skiff uses [Kamal](https://kamal-deploy.org) to deploy static sites using nginx with Server-Side Includes (SSI).

## Local development

If you have a Ruby environment available, you can install Skiff globally with:

```sh
gem install kamal-skiff
```

...otherwise, you can run a dockerized version via an alias (add this to your .bashrc or similar to simplify re-use). On macOS, use:

```sh
alias skiff="docker run -it --rm -v '${PWD}:/workdir' -v '/run/host-services/ssh-auth.sock:/run/host-services/ssh-auth.sock' -e SSH_AUTH_SOCK='/run/host-services/ssh-auth.sock' -v /var/run/docker.sock:/var/run/docker.sock ghcr.io/basecamp/kamal-skiff:latest"
```

Then run `skiff dev` to start the development server.

## Deploying changes to production (or staging)

Changes checked into git are automatically pulled onto the Skiff server every 10 seconds. So all you have to do is checkin your changes and push them.

If you need to change the nginx configuration in `config/server.conf`, make your changes to that file, check them into git and push, and then run `skiff restart` to test the configuration file and restart the server if it's valid.

## Deploying the site for the first time

First ensure that you've set `GIT_URL` to a repository address with a valid access token embedded in the `.env` file. This access token must have access to pull from the git repository in question (see [personal access tokens for GitHub](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens) for an example).

Then you must also setup an access token for your Docker image repository (see [Create and manage access tokens for Docker Hub](https://docs.docker.com/security/for-developers/access-tokens/) for an example).

Finally, you must add the server address into `config/deploy.yml`, and ensure that the image and repository configurations are correct.

Now you're ready to run `skiff deploy` to deploy your site to the server. This will install Docker on your server (using `apt-get`), if it isn't already available.

## Flushing etag caches after changing include files

Skiff uses [Server Side Includes](https://nginx.org/en/docs/http/ngx_http_ssi_module.html), which can change independently of your individual HTML files. When that happens, the caching etags for those latter files will not be updated automatically to reflect the change. You can run `skiff flush` to touch all the public HTML files, which will flush the etag cache.

## License

Skiff is released under the [MIT License](https://opensource.org/licenses/MIT).
