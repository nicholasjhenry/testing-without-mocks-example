defmodule Rot13.Infra.HttpServerTest do
  use ExUnit.Case, async: true

  # Bevhaviour Simulation

  @port 4002

  describe "http server" do
    test "starts and stops server" do
      http_server = HttpServer.create()
      {:ok, http_server} = HttpServer.start(http_server, @port)

      result = HttpClient.get("http://localhost:4002/")
      assert {:ok, %{status: 200}} = result

      assert {:ok, http_server} = HttpServer.stop(http_server)
      assert is_nil(http_server.httpd)
    end
  end

  test "fails fast if server is started twice" do
    http_server = HttpServer.create()
    {:ok, http_server} = HttpServer.start(http_server, @port)

    result = HttpServer.start(http_server, @port)

    assert {:error, reason} = result
    assert {:already_started, httpd} = reason
    assert httpd == http_server.httpd

    assert {:ok, _http_server} = HttpServer.stop(http_server)
  end

  test "fails fast if server is stopped when it's not started" do
    http_server = HttpServer.create()
    assert {:error, :not_running} = HttpServer.stop(http_server)
  end

  test "fails fast if server is stopped when it's not running" do
    http_server = HttpServer.create()
    http_server = %{http_server | httpd: :c.pid(0, 250, 0)}
    assert {:error, :no_such_service} = HttpServer.stop(http_server)
  end
end
