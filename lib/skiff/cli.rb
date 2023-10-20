require "thor"

class Skiff::Cli < Thor
  include Thor::Actions

  def self.exit_on_failure?() true end

  source_root File.expand_path("templates", __dir__)

  desc "new", "Create a new skiff site [NAME]"
  def new(name)
    self.destination_root = File.expand_path(name)

    directory "config"

    directory "public"
    empty_directory_with_keep_file "public/assets/images"
    empty_directory_with_keep_file "public/assets/javascripts"
    empty_directory_with_keep_file "public/assets/stylesheets"

    copy_file "dotfiles/gitignore", ".gitignore"
    copy_file "dotfiles/dockerignore", ".dockerignore"
    copy_file "dotfiles/env", ".env"

    copy_file "Dockerfile"

    copy_file "serve"
    chmod "serve", 0755, verbose: false
    
    inside(destination_root) do
      run("git init && git add . && git commit -m 'New skiff site'")
    end
  end

  desc "dev", "Start development server"
  def dev
    if File.exist?("Dockerfile")
      puts "Starting #{site_name} on http://localhost:8080..."

      docker "build -t #{site_name} ."
      docker "run -it --rm -p 8080:80 -v ./public:/site/public --name #{site_name} #{site_name} nginx '-g daemon off;'"
    else
      puts "No Dockerfile found in current directory"
    end
  end

  desc "go", "Deploy the site"
  def go
    kamal "setup"
  end

  desc "stage", "Deploy the site to staging"
  def stage
    kamal "deploy -d staging"
  end

  desc "flush", "Flush etags after includes have changed (by touching all html files)"
  def flush
    kamal_exec 'find /site/public -type f -name "*.html" -exec touch {} \;'
  end

  desc "restart", "Restart the nginx server with latest config/server.conf"
  def restart
    kamal_exec "nginx -t && nginx -s reload"
  end

  desc "refresh", "Pull latest changes from git"
  def refresh
    kamal_exec 'git checkout -f & git pull \$GIT_URL'
  end

  desc "version", "Show Skiff version"
  def version
    puts Skiff::VERSION
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
      system "kamal #{command}"
    end

    def kamal_exec(commands)
      kamal %(app exec --reuse '/bin/bash -c "#{commands}"')
    end
end
