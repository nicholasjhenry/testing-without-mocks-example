defmodule AppTest do
  use ExUnit.Case, async: true

  # Test #1
  test "reads command-line argument, transform it with ROT-13, and writes result" do
    command_line = run(["my input"])

    # pattern: Output Tracking
    assert command_line.last_output == "zl vachg\n"
  end

  # Test #2
  test "writes usage when no argument provided" do
    # patterns: Signature Shielding, Configurable Responses
    command_line = run([])

    # pattern: Output Tracking
    assert command_line.last_output == "Usage: run text_to_transform\n"
  end

  # Test #3
  test "complains when too many command-line arguments provided" do
    # patterns: Signature Shielding, Configurable Responses
    command_line = run(["a", "b"])

    # pattern: Output Tracking
    assert command_line.last_output == "too many arguments\n"
  end

  # pattern: Signature Shielding
  defp run(args) do
    # assert_received {:mix_shell, :info, ["The version 1.0.0-dev has been set"]}

    #  command_line = CommandLine.create_null(args)
    # patterns: Nullable, Infrastructure Wrapper, Configurable Responses, Output Tracking
    command_line = CommandLine.create_null(args: args)
    #  output = CommandLine.track_output()

    # pattern: Signature Shielding
    App.run(command_line)
  end
end
