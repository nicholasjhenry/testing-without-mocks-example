defmodule HttpServer do
  @moduledoc """
  https://tylerpachal.medium.com/creating-an-http-server-using-pure-otp-c600fb41c972
  """
  use Norm
  use RequestHandler

  require Logger

  defstruct [:httpd, :internet_services, :request_handler]

  def s do
    schema(%__MODULE__{
      httpd: spec(is_pid() or is_nil())
    })
  end

  defmodule NullInets do
    def start(:httpd, _port) do
      pid = :c.pid(0, 250, 0)
      {:ok, pid}
    end

    def stop(:httpd, _pid) do
      :ok
    end
  end

  def create_null do
    struct!(__MODULE__, %{internet_services: NullInets})
  end

  def create do
    struct!(__MODULE__, %{internet_services: :inets})
  end

  def port, do: spec(is_integer() and (&(&1 in 4000..5000)))

  @contract start(s(), port(), spec(is_atom())) ::
              one_of([{:ok, s()}, {:error, {:already_started, spec(is_pid())}}])
  def start(http_server, port, request_handler \\ __MODULE__) do
    server_opts = [
      {:port, port},
      {:server_name, ~c(httpd_test)},
      {:server_root, ~c(/tmp)},
      {:document_root, ~c(/tmp)},
      {:modules, [request_handler]}
    ]

    with {:ok, httpd} <- http_server.internet_services.start(:httpd, server_opts) do
      http_server = %{http_server | httpd: httpd, request_handler: request_handler}
      {:ok, http_server}
    end
  end

  def started?(http_server) do
    not is_nil(http_server.httpd)
  end

  def stop(http_server) do
    with :ok <- verify_running(http_server),
         :ok <- http_server.internet_services.stop(:httpd, http_server.httpd) do
      http_server = %{http_server | httpd: nil}
      {:ok, http_server}
    end
  end

  defp verify_running(http_server) do
    case http_server.httpd do
      nil -> {:error, :not_running}
      _pid -> :ok
    end
  end

  def simulate_request(http_server, http_request) do
    case http_server.httpd do
      httpd when is_pid(httpd) ->
        response =
          http_request
          |> HttpRequest.to_record()
          |> http_server.request_handler.do()
          |> HttpResponse.from_record()

        {:ok, response}

      _no_pid ->
        {:error, :server_not_started}
    end
  end
end
