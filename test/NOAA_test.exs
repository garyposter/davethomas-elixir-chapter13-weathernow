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
    assert data[:dewpoint_string] == "26.1 F (-3.3 C)"
    assert data[:latitude] == "35.89223"
    assert data[:location] == "Raleigh / Durham, Raleigh-Durham International Airport, NC"
    assert data[:longitude] == "-78.78185"
    assert data[:observation_time] == "Last Updated on Dec 3 2015, 8:51 am EST"
    assert data[:pressure_string] == "1020.9 mb"
    assert data[:relative_humidity] == 48 # XXX a string for xpath implementation
    assert data[:temperature_string] == "45.0 F (7.2 C)"
    assert data[:visibility_mi] == "10.00"
    assert data[:weather] == "Mostly Cloudy"
    assert data[:wind_string] == "Northwest at 6.9 MPH (6 KT)"
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
