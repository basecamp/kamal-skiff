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

    eval File.read(File.join(File.dirname(__FILE__), "templates/site.rb"))
  end

  desc "dev", "Start development server"
  def dev
    if File.exist?("Dockerfile")
      puts "Starting #{site_name} on http://localhost:4000..."

      docker "build -t #{site_name} ."
      docker "run -it --rm -p 4000:80 -v $(pwd)/public:/site/public --name #{site_name} #{site_name} nginx '-g daemon off;'"
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
