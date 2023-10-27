template  "dotfiles/env.tt", ".env"
copy_file "dotfiles/gitignore", ".gitignore"
copy_file "dotfiles/dockerignore", ".dockerignore"

empty_directory "config"
template  "config/deploy.yml.tt", "config/deploy.yml"
copy_file "config/deploy.staging.yml", "config/deploy.staging.yml"
copy_file "config/server.conf", "config/server.conf"

directory "public"
empty_directory_with_keep_file "public/assets/images"
empty_directory_with_keep_file "public/assets/javascripts"
empty_directory_with_keep_file "public/assets/stylesheets"

unless @skip_javascript
  template "javascripts/importmap.json.tt", "public/assets/javascripts/importmap.json"
end

unless @skip_hotwire
  directory "javascripts/hotwire", "public/assets/javascripts"
  get "https://raw.githubusercontent.com/hotwired/stimulus-rails/main/app/assets/javascripts/stimulus-loading.js", "public/assets/javascripts/controllers/stimulus-loading.js"
end

copy_file "Dockerfile"
template "README.md.tt", "README.md"

copy_file "serve"
chmod "serve", 0755, verbose: false
