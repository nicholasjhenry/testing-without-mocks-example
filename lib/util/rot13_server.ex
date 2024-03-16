defmodule Server do
  defstruct [:command_line]

  def create(attrs) do
    struct!(__MODULE__, attrs)
  end

  def run(server) do
    args = CommandLine.args(server.command_line)

    case args do
      [port_as_string] ->
        port = String.to_integer(port_as_string)
        CommandLine.write_output(server.command_line, "Server started on port #{port}")
        http_server = HttpServer.create()
        HttpServer.start(http_server, port)

      _ ->
        CommandLine.write_output(server.command_line, "Usage: run PORT")
    end
  end
end
