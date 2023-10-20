require_relative "cli_test_case"

class CliTest < CliTestCase
  test "new" do
    Skiff::Cli.any_instance.expects(:new)
    run_command("new")
  end

  test "version" do
    version = stdouted { Skiff::Cli.new.version }
    assert_equal Skiff::VERSION, version
  end

  private
    def run_command(*command)
      stdouted { Skiff::Cli.start([*command]) }
    end
end
