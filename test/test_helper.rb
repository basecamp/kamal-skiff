require "bundler/setup"
require "active_support/test_case"
require "active_support/testing/autorun"
require "active_support/testing/stream"
require "debug"
require "mocha/minitest" # using #stubs that can alter returns
require "minitest/autorun" # using #stub that take args
require "kamal-skiff"

ActiveSupport::LogSubscriber.logger = ActiveSupport::Logger.new(STDOUT) if ENV["VERBOSE"]

class ActiveSupport::TestCase
  include ActiveSupport::Testing::Stream

  private
    def stdouted
      capture(:stdout) { yield }.strip
    end

    def stderred
      capture(:stderr) { yield }.strip
    end
end
