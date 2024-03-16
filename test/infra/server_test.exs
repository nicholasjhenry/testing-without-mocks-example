defmodule Rot13.ServerTest do
  use ExUnit.Case, async: true

  describe "server" do
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
  end
end
