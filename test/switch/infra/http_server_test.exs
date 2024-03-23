defmodule Switch.Infra.HttpServerTest do
  use ExUnit.Case, async: true

  alias Switch.Infra.HttpRequest
  alias Switch.Infra.HttpServer
  alias Switch.Infra.HttpClient

  # Bevhaviour Simulation

  @port 4002

  describe "http server" do
    test "starts and stops server (and can do so multiple times)" do
      http_server = HttpServer.create()

      {:ok, http_server} = HttpServer.start(http_server, @port)
      assert {:ok, http_server} = HttpServer.stop(http_server)

      {:ok, http_server} = HttpServer.start(http_server, @port)
      assert {:ok, _http_server} = HttpServer.stop(http_server)
    end
  end

  test "determines if the server has started" do
    http_server = HttpServer.create()
    refute HttpServer.started?(http_server)

    {:ok, http_server} = HttpServer.start(http_server, @port)
    assert HttpServer.started?(http_server)

    HttpServer.stop(http_server)
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
    http_server = %{http_server | httpd: build_pid()}
    assert {:error, :no_such_service} = HttpServer.stop(http_server)
  end

  describe "requests and responses" do
    defmodule TestRequestHandler do
      use Switch.Infra.RequestHandler

      def handle_request(%{request_uri: "/exception"}) do
        raise "Foo"
      end

      def handle_request(%{request_uri: "/invalid"}) do
        "foo"
      end

      def handle_request(%{request_uri: "/"}) do
        HttpResponse.create(
          status: 200,
          headers: [content_type: "text/plain"],
          body: "Hello World"
        )
      end
    end

    test "runs a call callback when a request is received and serves the response" do
      http_server = HttpServer.create()
      {:ok, http_server} = HttpServer.start(http_server, @port, TestRequestHandler)

      # result = HttpClient.get("http://localhost:#{@port}")
      result = HttpClient.post("http://localhost:#{@port}", "foo", [~c"application/json"])

      {:ok, _http_server} = HttpServer.stop(http_server)

      assert {:ok, response} = result
      assert response.status == 200
      assert response.body == "Hello World"
    end

    test "fails gracefully when request handler throws exception" do
      http_server = HttpServer.create()
      {:ok, http_server} = HttpServer.start(http_server, @port, TestRequestHandler)

      result = HttpClient.get("http://localhost:#{@port}/exception")

      {:ok, _http_server} = HttpServer.stop(http_server)

      assert {:ok, response} = result
      assert response.status == 500
      assert response.body =~ "Internal Server Error"
    end

    test "simulates requests" do
      http_server = HttpServer.create_null()
      {:ok, http_server} = HttpServer.start(http_server, @port, TestRequestHandler)
      http_request = HttpRequest.create_null()
      result = HttpServer.simulate_request(http_server, http_request)

      assert {:ok, response} = result
      assert response.status == 200
      assert response.body =~ "Hello World"
    end

    test "returns an error when simulates requests if server is not started" do
      http_server = HttpServer.create_null()

      http_request = HttpRequest.create_null()
      result = HttpServer.simulate_request(http_server, http_request)

      assert result == {:error, :server_not_started}
    end

    test "fails gracefully when return in correct response" do
      http_server = HttpServer.create()
      {:ok, http_server} = HttpServer.start(http_server, @port, TestRequestHandler)

      result = HttpClient.get("http://localhost:#{@port}/invalid")

      {:ok, _http_server} = HttpServer.stop(http_server)

      assert {:ok, response} = result
      assert response.status == 500
      assert response.body =~ "Internal Server Error"
    end
  end

  describe "nullability" do
    test "doesn't actually start or stop the server" do
      http_server = HttpServer.create_null()

      {:ok, http_server} = HttpServer.start(http_server, @port)
      result = HttpServer.start(http_server, @port)
      assert {:ok, http_server} == result
      assert {:ok, http_server} = HttpServer.stop(http_server)
      assert is_nil(http_server.httpd)
    end
  end

  defp build_pid do
    :c.pid(0, 250, 0)
  end
end
