defmodule Switch.Infra.RequestHandler do
  defmacro __using__(_opts) do
    quote do
      alias Switch.Infra.HttpResponse

      import Switch.Infra.RequestHandler

      def unquote(:do)(record) do
        handle_do(record, &handle_request/1)
      end

      def handle_request(%{request_uri: "/"}) do
        HttpResponse.create(
          status: 200,
          headers: [content_type: "text/plain"],
          body: "I am healthy\n"
        )
      end

      def handle_request(_request) do
        HttpResponse.create(
          status: 404,
          headers: [content_type: "text/plain"],
          body: "Not found\n"
        )
      end

      defoverridable handle_request: 1
    end
  end

  alias Switch.Infra.HttpRequest
  alias Switch.Infra.HttpResponse

  def handle_do(record, handle_request) do
    record
    |> HttpRequest.from_record()
    |> handle_request.()
    |> HttpResponse.to_record()
  end
end
