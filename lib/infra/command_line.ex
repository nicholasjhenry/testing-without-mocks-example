defmodule CommandLine do
  @moduledoc """
  An infrastructure wrapper for a command line.
  """
  defstruct [:write, :argv, :last_output]

  defmodule NullIO do
    def write(_string) do
      :ok
    end
  end

  def create_null(attrs \\ []) do
    args = Access.get(attrs, :args, [])
    # Embedded Stub
    write_fn = &NullIO.write/1
    # Configurable Response
    argv_fn = fn -> args end

    new(write: write_fn, argv: argv_fn)
  end

  def create do
    new(write: &IO.write/1, argv: &System.argv/0)
  end

  def new(attrs) do
    struct(__MODULE__, attrs)
  end

  def args(command_line) do
    command_line.argv.()
  end

  def write_output(command_line, output) do
    output = output <> "\n"
    :ok = command_line.write.(output)
    %{command_line | last_output: output}
  end
end
