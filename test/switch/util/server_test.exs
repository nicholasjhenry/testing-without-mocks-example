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

  @valid_request_uri "/rot13/transform"
  @tag :capture_log
  test "responds to request with a transformation" do
    command_line = CommandLine.create_null(args: ["4001"])
    http_server = HttpServer.create_null()

    http_request =
      HttpRequest.create_null(
        request_uri: @valid_request_uri,
        method: "POST",
        entity_body: :json.encode(%{text: "hello"})
      )

    server = Server.create(command_line: command_line, http_server: http_server)
    {:ok, server} = Server.run(server)

    result = HttpServer.simulate_request(server.http_server, http_request)

    assert {:ok, response} = result
    assert response.status == 200
    assert response.headers[:content_type] == "application/json"
    assert json_response(response) == %{"transform" => Rot13.transform("hello")}
  end

  @tag :capture_log
  test "given an invalid URI responds with a not-found error" do
    command_line = CommandLine.create_null(args: ["4001"])
    http_server = HttpServer.create_null()

    http_request =
      HttpRequest.create_null(
        request_uri: "/not-found",
        method: "POST",
        entity_body: :json.encode(%{text: "hello"})
      )

    server = Server.create(command_line: command_line, http_server: http_server)
    {:ok, server} = Server.run(server)

    result = HttpServer.simulate_request(server.http_server, http_request)

    assert {:ok, response} = result
    assert response.status == 404
    assert response.headers[:content_type] == "application/json"
    assert json_response(response) == %{"error" => "not-found"}
  end

  test "validates args" do
    command_line = CommandLine.create_null()
    http_server = HttpServer.create_null()
    server = Server.create(command_line: command_line, http_server: http_server)
    {:error, server} = Server.run(server)
    assert "Usage: run PORT\n" == server.command_line.last_output
  end

  def json_response(response) do
    response.body
    |> :json.decode()
  end
end
