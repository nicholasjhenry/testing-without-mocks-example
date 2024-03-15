defmodule AppTest do
  use ExUnit.Case, async: true

  # Test #1
  test "reads command-line argument, transform it with ROT-13, and writes result" do
    run(["my input"])

    # Output Tracking
    assert_receive {:command_line, "zl vachg\n"}
  end

  # Test #2
  test "writes usage when no argument provided" do
    # patterns: Signature Shielding, Configurable Responses
    run([])

    # Output Tracking
    assert_receive {:command_line, "Usage: run text_to_transform\n"}
  end

  # Test #3
  test "complains when too many command-line arguments provided" do
    # patterns: Signature Shielding, Configurable Responses
    run(["a", "b"])

    # pattern: Output Tracking
    assert_receive {:command_line, "too many arguments\n"}
  end

  # pattern: Signature Shielding
  defp run(args) do
    # assert_received {:mix_shell, :info, ["The version 1.0.0-dev has been set"]}

    #  command_line = CommandLine.create_null(args)
    # patterns: Nullable, Infrastructure Wrapper, Configurable Responses, Output Tracking
    command_line = CommandLine.create_null(args)
    #  output = CommandLine.track_output()

    # pattern: Signature Shielding
    App.run(command_line)
  end
end