defmodule Switch.Util.Server do
  use Switch.Infra.RequestHandler

  alias Switch.Attrs
  alias Switch.Infra.CommandLine
  alias Switch.Infra.HttpRequest
  alias Switch.Infra.HttpResponse
  alias Switch.Infra.HttpServer
  alias Switch.Logic.Rot13
  alias Switch.Routing.Router

  defstruct [:command_line, :http_server]

  @type t :: %__MODULE__{
          command_line: CommandLine.t(),
          http_server: HttpServer.t()
        }

  @spec create(Attrs.t()) :: t()
  def create(attrs) do
    default_attrs = %{
      http_server: HttpServer.create(),
      command_line: CommandLine.create()
    }

    attrs = Enum.into(attrs, default_attrs)

    struct!(__MODULE__, attrs)
  end

  @spec run(t()) :: {:ok, t()} | {:error, t()}
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

  @spec handle_request(HttpRequest.t()) :: HttpResponse.t()
  def handle_request(request) do
    Router.route(request, fn %{"text" => text} ->
      %{transform: Rot13.transform(text)}
    end)
  end
end
