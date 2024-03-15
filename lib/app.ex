defmodule App do
  def run(command_line) do
    with [input] <- command_line.args do
      result = Rot13.transform(input)
      CommandLine.write_output(command_line, result <> "\n")
    else
      [] ->
        CommandLine.write_output(command_line, "Usage: run text_to_transform\n")

      _many_args ->
        CommandLine.write_output(command_line, "too many arguments\n")
    end
  end
end
