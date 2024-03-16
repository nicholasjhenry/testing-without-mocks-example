defmodule Server do
  defstruct [:command_line, :http_server]

  def create(attrs) do
    default_attrs = %{
      http_server: HttpServer.create(),
      command_line: CommandLine.create()
    }

    attrs = Enum.into(attrs, default_attrs)

    struct!(__MODULE__, attrs)
  end

  def run(server) do
    args = CommandLine.args(server.command_line)

    case args do
      [port_as_string] ->
        port = String.to_integer(port_as_string)

        {:ok, http_server} = HttpServer.start(server.http_server, port)

        command_line =
          CommandLine.write_output(server.command_line, "Server started on port #{port}")

        server = %{server | http_server: http_server, command_line: command_line}
        {:ok, server}

      _other_args ->
        command_line = CommandLine.write_output(server.command_line, "Usage: run PORT")
        server = %{server | command_line: command_line}
        {:error, server}
    end
  end
end
