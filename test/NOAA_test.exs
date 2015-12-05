defmodule Weathernow.NOAATest do
  import Weathernow.NOAA, only: [handle_body: 1, handle_response: 2]
  use ExUnit.Case
  doctest Weathernow.NOAA

  def body(), do:
    File.read!(Path.join([__DIR__, "data", "RDU.xml"]))

  def successful_response(), do:
    {:ok, %HTTPoison.Response{status_code: 200, body: body}}

  def unsuccessful_response(), do:
    {:ok, %HTTPoison.Response{status_code: 404}}

  def error_response(), do:
    {:error, "uh-oh"}

  test "handle_body extracts expected observations" do
    data = handle_body(body)
    assert data[:weather] == "Mostly Cloudy"
    # XXX more
  end

  test "handle_response handles successful responses" do
    {:ok, data} = handle_response(successful_response, "RDU")
    assert data[:weather] == "Mostly Cloudy"
  end

  test "handle_response handles unsuccessful responses" do
    {:error, data, code} = handle_response(unsuccessful_response, "RDU")
    assert data == "404"
    assert code == "RDU"
  end

  test "handle_response handles error responses" do
    {:error, data, code} = handle_response(error_response, "RDU")
    assert data == "uh-oh"
    assert code == "RDU"
  end
end
