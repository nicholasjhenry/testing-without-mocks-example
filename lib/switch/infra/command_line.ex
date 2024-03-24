defmodule Switch.Infra.CommandLine do
  @moduledoc """
  An infrastructure wrapper for a command line.
  """

  alias Switch.Attrs

  defstruct [:write, :argv, :last_output, :args]

  @type t :: %__MODULE__{}

  defmodule NullIO do
    def write(_string) do
      :ok
    end
  end

  @spec create_null() :: t
  @spec create_null(Attrs.t) :: t
  def create_null(attrs \\ []) do
    args = Access.get(attrs, :args, [])
    # Embedded Stub
    write_fn = &NullIO.write/1
    # Configurable Response
    argv_fn = fn -> args end

    new(write: write_fn, argv: argv_fn, args: args)
  end

  @spec create() :: t
  def create do
    new(write: &IO.write/1, argv: &System.argv/0)
  end

  defp new(attrs) do
    struct(__MODULE__, attrs)
  end

  @spec args(t()) :: list(String.t)
  def args(command_line) do
    command_line.argv.()
  end

  @spec write_output(t(), String.t()) :: t()
  def write_output(command_line, output) do
    output = output <> "\n"
    :ok = command_line.write.(output)
    %{command_line | last_output: output}
  end
end
