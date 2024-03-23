defmodule Switch.Infra.HttpRequest do
  require Record

  # Wrap the Erlang Record to make the request_uri parameter easier to access
  # https://github.com/erlang/otp/blob/master/lib/inets/include/httpd.hrl
  Record.defrecord(:httpd, Record.extract(:mod, from_lib: "inets/include/httpd.hrl"))

  defstruct [:http_version, :method, :absolute_uri, :request_uri, :headers, :entity_body]

  def create_null(attrs \\ %{}) do
    default_attrs = %{
      http_version: "HTTP/1.1",
      method: "GET",
      request_uri: "/",
      absolute_uri: "localhost:4002/",
      headers: [
        {"connection", "keep-alive"},
        {"host", "localhost:4002"},
        {"te", []},
        {"content-length", "0"}
      ],
      entity_body: []
    }

    attrs = Enum.into(attrs, default_attrs)

    struct!(__MODULE__, attrs)
  end

  def from_record(record) do
    entity_body = record |> httpd(:entity_body) |> to_string
    request_uri = record |> httpd(:request_uri) |> to_string
    method = record |> httpd(:method) |> to_string

    headers =
      record
      |> httpd(:parsed_header)
      |> Enum.map(fn {key, value} -> {to_string(key), to_string(value)} end)

    http_request_attrs = %{
      http_version: "HTTP/1.1",
      method: method,
      absolute_uri: "???",
      request_uri: request_uri,
      headers: headers,
      entity_body: entity_body
    }

    struct!(__MODULE__, http_request_attrs)
  end

  def to_record(http_request) do
    data = []
    socket_type = :ip_comm
    socket = nil
    config_db = :httpd_conf_4002default
    request_line = ~c"#{http_request.method} / #{http_request.http_version}"
    connection = true

    headers =
      Enum.map(http_request.headers, fn
        {key, value} when is_binary(key) and is_binary(value) ->
          {to_charlist(key), to_charlist(value)}

        {key, value} when is_binary(key) ->
          {to_charlist(key), value}
      end)

    {
      :mod,
      init_data(),
      data,
      socket_type,
      socket,
      config_db,
      to_charlist(http_request.method),
      to_charlist(http_request.absolute_uri),
      to_charlist(http_request.request_uri),
      to_charlist(http_request.http_version),
      request_line,
      headers,
      to_charlist(http_request.entity_body),
      connection
    }
  end

  defp init_data do
    peername = {57743, ~c"127.0.0.1"}
    sockname = {4002, ~c"127.0.0.1"}
    resolve = ~c"Auckland"
    {:init_data, peername, sockname, resolve}
  end
end
