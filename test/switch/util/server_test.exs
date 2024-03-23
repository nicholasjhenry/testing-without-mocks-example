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

  @tag :capture_log
  test "responds to request with a transformation" do
    command_line = CommandLine.create_null(args: ["4001"])
    http_server = HttpServer.create_null()
    http_request = HttpRequest.create_null(entity_body: "hello")
    server = Server.create(command_line: command_line, http_server: http_server)
    {:ok, server} = Server.run(server)

    result = HttpServer.simulate_request(server.http_server, http_request)

    assert {:ok, response} = result
    assert response.status == 200
    assert response.body == Rot13.transform("hello")
  end

  test "validates args" do
    command_line = CommandLine.create_null()
    http_server = HttpServer.create_null()
    server = Server.create(command_line: command_line, http_server: http_server)
    {:error, server} = Server.run(server)
    assert "Usage: run PORT\n" == server.command_line.last_output
  end
end
