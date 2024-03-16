defmodule RequestHandler do
  require Record

  # Wrap the Erlang Record to make the request_uri parameter easier to access
  # https://github.com/erlang/otp/blob/master/lib/inets/include/httpd.hrl
  Record.defrecord(:httpd, Record.extract(:mod, from_lib: "inets/include/httpd.hrl"))

  defmacro __using__(_opts) do
    quote do
      import RequestHandler

      def unquote(:do)(record), do: handle_do(record, &handle_request/1)

      def handle_request("/"), do: {200, "text/plain", "I am healthy\n"}
      def handle_request(_), do: {404, "text/plain", "Not found\n"}

      defoverridable handle_request: 1
    end
  end

  def handle_do(record, handle_request) do
    response =
      record
      |> httpd(:request_uri)
      |> to_string
      |> handle_request.()
      |> format_response

    {:proceed, [response: response]}
  end

  def format_response(response) do
    {status, content_type, body} = response
    content_length = String.length(body)

    headers = [
      {:code, status},
      {:content_type, to_charlist(content_type)},
      {:content_length, to_charlist(content_length)}
    ]

    {:response, headers, to_charlist(body)}
  end
end