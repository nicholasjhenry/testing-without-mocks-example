defmodule Switch.Infra.HttpResponse do
  defstruct [:body, :headers, :status]

  @type t :: %__MODULE__{
          body: String.t(),
          headers: list({String.t(), term()}),
          status: non_neg_integer()
        }

  alias Switch.Attrs

  @spec create(Attrs.t()) :: t()
  def create(attrs) do
    struct!(__MODULE__, attrs)
  end

  @spec to_record(t()) :: tuple()
  def to_record(response) do
    content_length = String.length(response.body)
    content_type = Keyword.fetch!(response.headers, :content_type)

    headers = [
      {:code, response.status},
      {:content_type, to_charlist(content_type)},
      {:content_length, to_charlist(content_length)}
    ]

    response_record = {:response, headers, to_charlist(response.body)}

    {:proceed, [response: response_record]}
  end

  @spec from_record(tuple()) :: t()
  def from_record(record) do
    {:proceed, [response: response]} = record
    {:response, headers, body} = response
    {status, headers} = Keyword.pop(headers, :code)
    headers = Enum.map(headers, fn {key, value} -> {key, to_string(value)} end)

    http_response_attrs = %{
      status: status,
      headers: headers,
      body: to_string(body)
    }

    struct!(__MODULE__, http_response_attrs)
  end
end
