defmodule HttpClient do
  def get(url) do
    headers = []

    http_request_opts = []
    result = :httpc.request(:get, {url, headers}, http_request_opts, [])

    case result do
      {:ok, payload} ->
        {
          {~c"HTTP/1.1", status, msg},
          [
            {~c"date", _date},
            {~c"server", _server},
            {~c"content-length", _content_length},
            {~c"content-type", _content_type}
          ],
          body
        } = payload

        response = %{status: status, msg: msg, body: to_string(body)}
        {:ok, response}

      other_result ->
        other_result
    end
  end
end
