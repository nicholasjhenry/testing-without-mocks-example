defmodule Switch.Util.Server do
  use Switch.Infra.RequestHandler

  alias Switch.Attrs
  alias Switch.Infra.CommandLine
  alias Switch.Infra.HttpRequest
  alias Switch.Infra.HttpResponse
  alias Switch.Infra.HttpServer
  alias Switch.Logic.Rot13

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
    route(request, fn text ->
      %{transform: Rot13.transform(text)}
    end)
  end

  defp route(request, fun) do
    Logger.info("Request received: #{request.request_uri}")

    with :ok <- validate(request, :request_uri),
         :ok <- validate(request, :method),
         :ok <- validate(request, :content_type),
         {:ok, text} <- parse_text(request) do
      json_response(200, fun.(text))
    else
      {:error, error_response} -> error_response
    end
  end

  defp validate(%{request_uri: "/rot13/transform"}, :request_uri), do: :ok

  defp validate(_request, :request_uri),
    do: {:error, json_response(404, %{"error" => "not found"})}

  defp validate(%{method: "POST"}, :method), do: :ok

  defp validate(_request, :method),
    do: {:error, json_response(405, %{"error" => "method not allowed"})}

  defp validate(request, :content_type) do
    if {"content-type", "application/json"} in request.headers do
      :ok
    else
      {:error, json_response(400, %{"error" => "Must be application/json"})}
    end
  end

  defp parse_text(request) do
    case :json.decode(request.entity_body) do
      %{"text" => text} ->
        {:ok, text}

      _invalid_payload ->
        response = json_response(400, %{"error" => "Incorrect payload: must have 'text' key"})
        {:error, response}
    end
  end

  defp json_response(status, data) do
    body =
      data
      |> :json.encode()
      |> to_string

    HttpResponse.create(
      status: status,
      headers: [content_type: "application/json"],
      body: body
    )
  end
end
