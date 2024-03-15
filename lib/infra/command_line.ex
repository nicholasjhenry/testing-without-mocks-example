defmodule CommandLine do
  defstruct [:args, :output]

  defprotocol Output do
    @spec write(t, String.t()) :: String.t()
    def write(value, string)
  end

  defmodule Output.Process do
    defstruct prefix: :command_line

    def new do
      struct!(__MODULE__, [])
    end

    defimpl CommandLine.Output do
      def write(output, string) do
        send(self(), {output.prefix, string})
      end
    end
  end

  defmodule Output.Standard do
    defstruct []

    def new do
      struct!(__MODULE__, [])
    end

    defimpl CommandLine.Output do
      def write(_output, string) do
        IO.write(string)
      end
    end
  end

  def create_null(args) do
    new(args: args, output: Output.Process.new())
  end

  def create(args) do
    new(args: args, output: Output.Standard.new())
  end

  def new(attrs) do
    struct(__MODULE__, attrs)
  end

  def write_output(command_line, output) do
    CommandLine.Output.write(command_line.output, output)
  end
end
