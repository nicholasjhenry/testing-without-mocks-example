defmodule Rot13.Infra.CommandLineTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO

  describe "command line" do
    test "writes output" do
      command_line = CommandLine.create()
      output = capture_io(fn -> CommandLine.write_output(command_line, "my output") end)
      assert output == "my output\n"
    end

    test "remembers last output" do
      command_line = CommandLine.create_null()
      command_line = CommandLine.write_output(command_line, "my output")
      assert command_line.last_output == "my output\n"
    end

    test "last output is undefined when nothing has been outputed yet" do
      command_line = CommandLine.create_null()
      refute command_line.last_output
    end
  end

  describe "nullability" do
    test "defaults to no arguments" do
      command_line = CommandLine.create_null()
      assert CommandLine.args(command_line) == []
    end

    test "allows arguments to be configured" do
      command_line = CommandLine.create_null(args: ["one", "two"])
      assert CommandLine.args(command_line) == ["one", "two"]
    end

    test "doesn't write output to command line" do
      command_line = CommandLine.create_null()
      output = capture_io(fn -> CommandLine.write_output(command_line, "my output") end)
      assert output == ""
    end
  end
end
