require "test_helper"

class CliTestCase < ActiveSupport::TestCase
  setup do
    ENV["GIT_URL"]             = ""
    # Object.send(:remove_const, :SKIFF)
    # Object.const_set(:SKIFF, Skiff::Commander.new)
  end

  teardown do
    ENV.delete("GIT_URL")
  end
end
