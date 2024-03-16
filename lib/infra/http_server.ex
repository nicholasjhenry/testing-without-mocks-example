defmodule HttpServer do
  @moduledoc """
  https://tylerpachal.medium.com/creating-an-http-server-using-pure-otp-c600fb41c972
  """
  use Norm

  require Logger
  require Record

  # Wrap the Erlang Record to make the request_uri parameter easier to access
  # https://github.com/erlang/otp/blob/master/lib/inets/include/httpd.hrl
  Record.defrecord(:httpd, Record.extract(:mod, from_lib: "inets/include/httpd.hrl"))

  defstruct [:httpd]

  def s do
    schema(%__MODULE__{
      httpd: spec(is_pid() or is_nil())
    })
  end

  def create do
    attrs = %{}
    new(attrs)
  end

  def new(attrs) do
    struct!(__MODULE__, attrs)
  end

  def port, do: spec(is_integer() and (&(&1 in 4000..5000)))

  @contract start(s(), port()) ::
              one_of([{:ok, s()}, {:error, {:already_started, spec(is_pid())}}])
  def start(http_server, port) do
    server_opts = [
      {:port, port},
      {:server_name, ~c(httpd_test)},
      {:server_root, ~c(/tmp)},
      {:document_root, ~c(/tmp)},
      {:modules, [__MODULE__]}
    ]

    with {:ok, httpd} <- :inets.start(:httpd, server_opts) do
      http_server = %{http_server | httpd: httpd}
      {:ok, http_server}
    end
  end

  def stop(http_server) do
    with :ok <- verify_running(http_server),
         :ok <- :inets.stop(:httpd, http_server.httpd) do
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

  def unquote(:do)(record) do
    response =
      case httpd(record, :request_uri) do
        ~c"/" ->
          {200, ~c"I am healthy"}

        _ ->
          {404, ~c"Not found"}
      end

    {:proceed, [response: response]}
  end
end
