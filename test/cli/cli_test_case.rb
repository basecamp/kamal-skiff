require "test_helper"

class CliTestCase < ActiveSupport::TestCase
  setup do
    ENV["GIT_URL"] = ""
  end

  teardown do
    ENV.delete("GIT_URL")
  end
end
