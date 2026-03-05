# Skiff

Skiff uses [Kamal](https://kamal-deploy.org) to deploy static sites using nginx with Server-Side Includes (SSI).

Understand the why and the how in this introduction video: https://www.youtube.com/watch?v=YoabUEzpM6k

## Setting up your first Skiff site

1. Create a new site scaffold and enter the project:
   ```sh
   skiff new mysite
   cd mysite
   ```

2. Add your site files under `public/` (for example, `public/index.html` and includes in `public/_includes/`).

3. Put the site in a Git repository and push it to GitHub, since the server auto-pulls from git:
   ```sh
   git init
   git add .
   git commit -m "Initial site"
   git branch -M master
   git remote add origin git@github.com:username/repo.git
   git push -u origin master
   ```

4. Set `GIT_URL` in `.kamal/secrets` so the server can pull your repository (relying on ENV GITHUB_TOKEN):
   ```bash
   GIT_URL=https://x-access-token:${GITHUB_TOKEN}@github.com/username/repo.git
   ```

### If you need to create a GitHub access token

- Go to **GitHub → Settings → Developer settings → Personal access tokens → Fine-grained tokens**.
  - Direct link: https://github.com/settings/tokens?type=beta
- Click **Generate new token** and configure:
  - **Token name**: A descriptive name (e.g., `mysite-deploy`)
  - **Expiration**: Choose an appropriate duration
  - **Repository access**: Select "Only select repositories" → choose your site's repository
  - **Permissions**: Repository permissions → **Contents**: `Read-only`
- Click **Generate token** and copy the value.
- Store the token in 1Password:
  - Use the **Deploy** vault
  - Create or update an item for your site (e.g., `mysite.do`)
  - Add the token as a field named `GITHUB_TOKEN`

5. Update `config/deploy.yml` with your server address in `servers` and confirm the `image` name.

Kamal 2 uses a local registry by default (`registry.server: localhost:5555`), so you do not need to configure remote registry credentials unless you change that setting.

6. Deploy your site:
   ```sh
   skiff deploy
   ```

   This will install Docker on your server (using `apt-get`) if it is not already available.

If you're upgrading an existing site from Kamal 1, run `kamal upgrade` once (and `kamal upgrade -d staging` for staging) before your next `skiff deploy`.

## Local development

Run `skiff dev` to start the development server on localhost:4000.

## Deploying changes to production

Changes checked into git are automatically pulled onto the Skiff server every 10 seconds. So all you have to do is check in your changes and push them.

If you need to change the nginx configuration in `config/server.conf`, make your changes to that file, check them into git, and push. Skiff will detect the update, validate the new config, and reload nginx automatically.

## Deploying changes to staging first

To use a staging server, set `GIT_BRANCH` in `config/deploy.staging.yml` under `env.clear` to the branch you're using for staging. Then you can deploy the site to a staging server using `skiff deploy --staging`, which will use the configuration in `config/deploy.staging.yml`, and start pulling updates from the branch specified.

## Flushing etag caches after changing include files

Skiff uses [Server Side Includes](https://nginx.org/en/docs/http/ngx_http_ssi_module.html), which can change independently of your individual HTML files. When that happens, the caching etags for those latter files will not be updated automatically to reflect the change. You can run `skiff flush` to touch all the public HTML files, which will flush the etag cache.

## License

Skiff is released under the [MIT License](https://opensource.org/licenses/MIT).
