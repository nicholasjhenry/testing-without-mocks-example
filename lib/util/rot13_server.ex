defmodule Server do
  use RequestHandler

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

        {:ok, http_server} = HttpServer.start(server.http_server, port, __MODULE__)

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

  require Logger

  def handle_request(path) do
    Logger.info("Request received: #{path}")
    {501, "text/plain", "Not yet implemented\n"}
  end
end
