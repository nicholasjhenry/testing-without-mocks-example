defmodule Switch.Routing.Router do
  alias Switch.Infra.HttpRequest
  alias Switch.Infra.HttpResponse

  require Logger

  @spec route(HttpRequest.t(), (term -> term)) :: HttpResponse.t()
  def route(request, fun) do
    Logger.info("Request received: #{request.request_uri}")

    with :ok <- validate(request, :request_uri),
         :ok <- validate(request, :method),
         :ok <- validate(request, :content_type),
         {:ok, params} <- parse_params(request) do
      json_response(200, fun.(params))
    else
      {:error, error_response} -> error_response
    end
  end

  defp validate(%{request_uri: "/rot13/transform"}, :request_uri), do: :ok

  defp validate(_request, :request_uri),
    do: {:error, json_response(404, %{"error" => "not found"})}

  defp validate(%{method: "POST"}, :method), do: :ok

  defp validate(_request, :method),
    do: {:error, json_response(405, %{"error" => "method not allowed"})}

  defp validate(request, :content_type) do
    if {"content-type", "application/json"} in request.headers do
      :ok
    else
      {:error, json_response(400, %{"error" => "Must be application/json"})}
    end
  end

  defp parse_params(request) do
    case :json.decode(request.entity_body) do
      %{"text" => _text} = params ->
        {:ok, params}

      _invalid_payload ->
        response = json_response(400, %{"error" => "Incorrect payload: must have 'text' key"})
        {:error, response}
    end
  end

  defp json_response(status, data) do
    body =
      data
      |> :json.encode()
      |> to_string

    HttpResponse.create(
      status: status,
      headers: [content_type: "application/json"],
      body: body
    )
  end
end
