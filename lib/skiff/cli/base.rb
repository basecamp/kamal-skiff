require "thor"
require "dotenv"
require "skiff/cli"

module Skiff::Cli
  class Base < Thor
    def self.exit_on_failure?() true end

    class_option :verbose, type: :boolean, aliases: "-v", desc: "Detailed logging"
    class_option :quiet, type: :boolean, aliases: "-q", desc: "Minimal logging"

    def initialize(*)
      super
      load_envs
    end

    private
      def load_envs
        if destination = options[:destination]
          Dotenv.load(".env.#{destination}", ".env")
        else
          Dotenv.load(".env")
        end
      end

      def command
        @skiff_command ||= begin
          invocation_class, invocation_commands = *first_invocation
          if invocation_class == Skiff::Cli::Main
            invocation_commands[0]
          else
            Skiff::Cli::Main.subcommand_classes.find { |command, clazz| clazz == invocation_class }[0]
          end
        end
      end

      def subcommand
        @skiff_subcommand ||= begin
          invocation_class, invocation_commands = *first_invocation
          invocation_commands[0] if invocation_class != Skiff::Cli::Main
        end
      end
  end
end
