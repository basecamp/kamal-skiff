# Skiff

Skiff uses [Kamal](https://kamal-deploy.org) to deploy static sites using nginx with Server-Side Includes (SSI).

Understand the why and the how in this introduction video: https://www.youtube.com/watch?v=YoabUEzpM6k

## Local development

If you have a Ruby environment available, you can install Skiff globally with:

```sh
gem install kamal-skiff
```

Then run `skiff dev` to start the development server.

...otherwise, you can run a dockerized version via an alias (add this to your .bashrc or similar to simplify re-use). On macOS, use:

```sh
alias skiff-dev="docker build -t skiff-site . && docker run -it --rm -p 4000:80 -v ./public:/site/public --name skiff-site skiff-site nginx '-g daemon off;'"
alias skiff='docker run -it --rm -v "${PWD}:/workdir" -v /run/host-services/ssh-auth.sock:/run/host-services/ssh-auth.sock -e SSH_AUTH_SOCK="/run/host-services/ssh-auth.sock" -v /var/run/docker.sock:/var/run/docker.sock ghcr.io/basecamp/kamal-skiff:latest'
```

Then run `skiff-dev` to start the development server, and use `skiff [command]` for everything else.

## Deploying the site for the first time

First ensure that you've set `GIT_URL` to a repository address with a valid access token embedded in the `.env` file. This access token must have access to pull from the git repository in question.

### Creating a GitHub access token

1. Go to **GitHub → Settings → Developer settings → Personal access tokens → Fine-grained tokens**
   - Direct link: https://github.com/settings/tokens?type=beta

2. Click **Generate new token** and configure:
   - **Token name**: A descriptive name (e.g., `mysite-deploy`)
   - **Expiration**: Choose an appropriate duration
   - **Repository access**: Select "Only select repositories" → choose your site's repository
   - **Permissions**: Repository permissions → **Contents**: `Read-only`

3. Click **Generate token** and copy the value

4. Store the token in 1Password:
   - Use the **Deploy** vault
   - Create or update an item for your site (e.g., `mysite.do`)
   - Add the token as a field named `GITHUB_TOKEN`

5. Update your `.kamal/secrets` to fetch from 1Password and build the `GIT_URL`:
   ```bash
   GITHUB_TOKEN=$(kamal secrets extract GITHUB_TOKEN ${SECRETS})
   GIT_URL=https://${GITHUB_TOKEN}:@github.com/username/repo.git
   ```

Then you must also setup an access token for your Docker image repository (see [Create and manage access tokens for Docker Hub](https://docs.docker.com/security/for-developers/access-tokens/) for an example).

Finally, you must add the server address into `config/deploy.yml`, and ensure that the image and repository configurations are correct.

Now you're ready to run `skiff deploy` to deploy your site to the server. This will install Docker on your server (using `apt-get`), if it isn't already available.

## Deploying changes to production

Changes checked into git are automatically pulled onto the Skiff server every 10 seconds. So all you have to do is checkin your changes and push them.

If you need to change the nginx configuration in `config/server.conf`, make your changes to that file, check them into git, and push. Skiff will detect the update, validate the new config, and reload nginx automatically.

## Deploying changes to staging first

To use a staging server, you must set `GIT_BRANCH` in .env to the branch you're using for staging. Then you can deploy the site to a staging server using `skiff deploy --staging`, which will use the configuration in `config/deploy.staging.yml`, and start pulling updates from the branch specified.

## Flushing etag caches after changing include files

Skiff uses [Server Side Includes](https://nginx.org/en/docs/http/ngx_http_ssi_module.html), which can change independently of your individual HTML files. When that happens, the caching etags for those latter files will not be updated automatically to reflect the change. You can run `skiff flush` to touch all the public HTML files, which will flush the etag cache.

## License

Skiff is released under the [MIT License](https://opensource.org/licenses/MIT).
