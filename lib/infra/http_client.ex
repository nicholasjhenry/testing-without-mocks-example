defmodule HttpClient do
  def get(url) do
    headers = []

    http_request_opts = []
    result = :httpc.request(:get, {url, headers}, http_request_opts, [])

    case result do
      {:ok, payload} ->
        {
          {~c"HTTP/1.1", status, _msg},
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
