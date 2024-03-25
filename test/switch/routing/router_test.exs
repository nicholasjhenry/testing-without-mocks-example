defmodule Switch.Routing.RouterTest do
  use ExUnit.Case, async: true

  alias Switch.Infra.HttpRequest
  alias Switch.Routing.Router

  @moduletag :capture_log

  @valid_request_uri "/rot13/transform"
  @valid_method "POST"
  @valid_content_type "application/json"

  test "responds to request with a transformation" do
    body = json(%{text: "hello"})
    response = simulate_request(@valid_method, @valid_request_uri, body, @valid_content_type)

    assert response.status == 200
    assert response.headers[:content_type] == "application/json"
    assert json_response(response) == %{"transform" => "hello"}
  end

  test "given an invalid URI responds with a not-found error" do
    body = json(%{text: "hello"})
    response = simulate_request(@valid_method, "/not-found", body, "application/json")

    assert response.status == 404
    assert response.headers[:content_type] == "application/json"
    assert json_response(response) == %{"error" => "not found"}
  end

  test "given an invalid method responds with a method-not-allowed error" do
    body = json(%{text: "hello"})
    response = simulate_request("GET", @valid_request_uri, body, @valid_content_type)

    assert response.status == 405
    assert response.headers[:content_type] == "application/json"
    assert json_response(response) == %{"error" => "method not allowed"}
  end

  test "given an invalid JSON payload responds with an invalid content error" do
    body = json(%{invalid: "hello"}) |> to_string
    response = simulate_request(@valid_method, @valid_request_uri, body, @valid_content_type)

    assert response.status == 400
    assert response.headers[:content_type] == "application/json"
    assert json_response(response) == %{"error" => "Incorrect payload: must have 'text' key"}
  end

  test "given an invalid content-type responds with an invalid content-type error" do
    body = json(%{text: "hello"})
    response = simulate_request(@valid_method, @valid_request_uri, body, "plain/text")

    assert response.status == 400
    assert response.headers[:content_type] == "application/json"
    assert json_response(response) == %{"error" => "Must be application/json"}
  end

  defp simulate_request(method, request_uri, body, content_type) do
    http_request =
      HttpRequest.create(
        request_uri: request_uri,
        method: method,
        entity_body: body,
        headers: [{"content-type", content_type}]
      )

    Router.route(http_request, fn %{"text" => text} -> %{"transform" => text} end)
  end

  defp json(term) do
    term |> :json.encode() |> to_string
  end

  def json_response(response) do
    :json.decode(response.body)
  end
end
