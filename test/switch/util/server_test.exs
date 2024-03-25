defmodule Switch.Util.ServerTest do
  use ExUnit.Case, async: true

  alias Switch.Infra.CommandLine
  alias Switch.Infra.HttpRequest
  alias Switch.Infra.HttpServer
  alias Switch.Logic.Rot13
  alias Switch.Util.Server

  test "starts server" do
    command_line = CommandLine.create_null(args: ["4001"])
    http_server = HttpServer.create_null()
    server = Server.create(command_line: command_line, http_server: http_server)
    {:ok, server} = Server.run(server)

    assert HttpServer.started?(server.http_server)
  end

  test "validates args" do
    command_line = CommandLine.create_null()
    http_server = HttpServer.create_null()
    server = Server.create(command_line: command_line, http_server: http_server)
    {:error, server} = Server.run(server)
    assert "Usage: run PORT\n" == server.command_line.last_output
  end

  @valid_request_uri "/rot13/transform"
  @valid_method "POST"
  @valid_content_type "application/json"

  @tag :capture_log
  test "responds to request with a transformation" do
    body = :json.encode(%{text: "hello"})
    result = simulate_request(@valid_method, @valid_request_uri, body, @valid_content_type)

    assert {:ok, response} = result
    assert response.status == 200
    assert response.headers[:content_type] == "application/json"
    assert json_response(response) == %{"transform" => Rot13.transform("hello")}
  end

  def simulate_request(method, request_uri, body, content_type) do
    command_line = CommandLine.create_null(args: ["4001"])
    http_server = HttpServer.create_null()

    http_request =
      HttpRequest.create_null(
        request_uri: request_uri,
        method: method,
        entity_body: body,
        headers: [{"content-type", content_type}]
      )

    server = Server.create(command_line: command_line, http_server: http_server)
    {:ok, server} = Server.run(server)
    HttpServer.simulate_request(server.http_server, http_request)
  end

  def json_response(response) do
    response.body
    |> :json.decode()
  end
end
