require "thor"

class Skiff::Cli < Thor
  include Thor::Actions

  def self.exit_on_failure?() true end

  source_root File.expand_path("templates", __dir__)

  desc "new", "Create a new skiff site [SITE_NAME]"
  def new(site_name)
    self.destination_root = File.expand_path(site_name)

    @site_name = site_name
    @user_name = `whoami`.strip

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

    copy_file "Dockerfile"
    template "README.md.tt", "README.md"

    copy_file "serve"
    chmod "serve", 0755, verbose: false
  end

  desc "dev", "Start development server"
  def dev
    if File.exist?("Dockerfile")
      puts "Starting #{site_name} on http://localhost:8080..."

      docker "build -t #{site_name} ."
      docker "run -it --rm -p 8080:80 -v ./public:/site/public --name #{site_name} #{site_name} nginx '-g daemon off;'"
    else
      say "No Dockerfile found in current directory", :red
    end
  end

  desc "deploy", "Deploy the site"
  option :staging, aliases: "-s", type: :boolean, default: false, desc: "On staging server"
  def deploy
    kamal "setup"
  end

  desc "flush", "Flush etags after includes have changed (by touching all html files)"
  option :staging, aliases: "-s", type: :boolean, default: false, desc: "On staging server"
  def flush
    kamal_exec 'find /site/public -type f -name "*.html" -exec touch {} \;'
  end

  desc "restart", "Restart the nginx server with latest config/server.conf"
  option :staging, aliases: "-s", type: :boolean, default: false, desc: "On staging server"
  def restart
    kamal_exec "nginx -t && nginx -s reload"
  end

  desc "refresh", "Force pull latest changes from git"
  option :staging, aliases: "-s", type: :boolean, default: false, desc: "On staging server"
  def refresh
    kamal_exec 'git checkout -f & git pull \$GIT_URL'
  end

  desc "logs", "Follow logs from server"
  option :staging, aliases: "-s", type: :boolean, default: false, desc: "On staging server"
  def logs
    kamal "app logs -f"
  end

  desc "version", "Show Skiff version"
  def version
    say Skiff::VERSION
  end

  private
    def empty_directory_with_keep_file(destination, config = {})
      empty_directory(destination, config)
      keep_file(destination)
    end

    def keep_file(destination)
      create_file("#{destination}/.keep")
    end

    def site_name
      @site_name ||= File.basename(Dir.pwd)
    end

    def docker(command)
      system "docker #{command}"
    end

    def kamal(command)
      system "kamal #{command} #{options[:staging] ? "-d staging" : ""}".strip
    end

    def kamal_exec(commands)
      kamal %(app exec --reuse '/bin/bash -c "#{commands}"')
    end
end
