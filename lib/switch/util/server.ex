defmodule Switch.Util.Server do
  use Switch.Infra.RequestHandler

  alias Switch.Infra.CommandLine
  alias Switch.Infra.HttpServer
  alias Switch.Logic.Rot13

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

        output = "Server started on port #{port}"
        command_line = CommandLine.write_output(server.command_line, output)

        server = %{server | http_server: http_server, command_line: command_line}
        {:ok, server}

      _other_args ->
        output = "Usage: run PORT"
        command_line = CommandLine.write_output(server.command_line, output)
        server = %{server | command_line: command_line}
        {:error, server}
    end
  end

  require Logger

  def handle_request(request) do
    Logger.info("Request received: #{request.request_uri}")

    HttpResponse.create(
      status: 200,
      headers: [content_type: "text/plain"],
      body: Rot13.transform(request.entity_body)
    )
  end
end
