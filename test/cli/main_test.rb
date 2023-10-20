require_relative "cli_test_case"

class CliTest < CliTestCase
  test "new" do
    # Skiff::Cli.any_instance.expects(:invoke).with("skiff:cli:server:bootstrap")
    # Skiff::Cli.any_instance.expects(:invoke).with("skiff:cli:env:push")
    # Skiff::Cli.any_instance.expects(:invoke).with("skiff:cli:accessory:boot", [ "all" ])
    # Skiff::Cli.any_instance.expects(:deploy)
    # 
    # run_command("new")
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
