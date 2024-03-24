defmodule Switch.Util.Command do
  alias Switch.Infra.CommandLine
  alias Switch.Logic.Rot13

  @spec run(CommandLine.t()) :: CommandLine.t()
  def run(command_line) do
    with [input] <- CommandLine.args(command_line) do
      result = Rot13.transform(input)
      CommandLine.write_output(command_line, result)
    else
      [] ->
        CommandLine.write_output(command_line, "Usage: run text_to_transform")

      _many_args ->
        CommandLine.write_output(command_line, "too many arguments")
    end
  end
end
