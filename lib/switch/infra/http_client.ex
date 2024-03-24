defmodule Switch.Infra.HttpClient do
  @http_version ~c"HTTP/1.1"

  def get(url, headers \\ []) do
    headers = Enum.map(headers, fn {key, value} -> {to_charlist(key), to_charlist(value)} end)
    http_request_opts = []
    result = :httpc.request(:get, {url, headers}, http_request_opts, [])
    handle_response_result(result)
  end

  def post(url, body, content_type, headers \\ []) do
    http_request_opts = []
    result = :httpc.request(:post, {url, headers, content_type, body}, http_request_opts, [])
    handle_response_result(result)
  end

  defp handle_response_result(result) do
    case result do
      {:ok, payload} ->
        {
          {@http_version, status, _msg},
          headers,
          body
        } = payload

        headers = Enum.map(headers, fn {key, value} -> {to_string(key), to_string(value)} end)

        response = %{status: status, headers: headers, body: to_string(body)}
        {:ok, response}

      other_result ->
        other_result
    end
  end
end
