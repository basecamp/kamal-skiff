require "skiff/cli/base"
require "fileutils"
require "pathname"

class Skiff::Cli::Main < Skiff::Cli::Base
  include Thor::Actions

  source_root File.expand_path("templates", __dir__)

  desc "new", "Deploy app to servers"
  option :skip_push, aliases: "-P", type: :boolean, default: false, desc: "Skip image build and push"
  def new(name)
    self.destination_root = File.expand_path(name)

    directory "config"
    directory "public"

    copy_file "dotfiles/gitignore", ".gitignore"
    copy_file "dotfiles/dockerignore", ".dockerignore"
    copy_file "dotfiles/env", ".env"

    copy_file "Dockerfile"

    empty_directory_with_keep_file "assets/images"
    empty_directory_with_keep_file "assets/javascripts"
    empty_directory_with_keep_file "assets/stylesheets"
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
end
