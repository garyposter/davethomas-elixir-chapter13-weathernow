defmodule Weathernow.NOAA do

  @moduledoc """
  Get and parse data from the NOAA current airport observations.
  """

  require Record

  @user_agent [{"User-agent", "Elixir Tutorial Project gary@modernsongs.com"}]
  @options [follow_redirect: true]

  {:ok, xsdModel} = :erlsom.compile_xsd_file(
  Path.join([__DIR__, "data", "current_observation.xsd"]))
  @xsdModel xsdModel

  xml_path = Path.join([__DIR__, "data", "current_observation.hrl"])
  Record.defrecord :current_observation,
                   Record.extract(:current_observation, from: xml_path)
  Record.defrecord :imageType,
                   Record.extract(:imageType, from: xml_path)

  @doc """
  Fetch and parse the weather observations for a given airport code.
  """
  def fetch(airport_code) do
    code_url(airport_code)
    |> HTTPoison.get(@user_agent, @options)
    |> handle_response(airport_code)
  end

  @doc """
  Convert an airport code to an API URL.

      iex> Weathernow.NOAA.code_url("RDU")
      "http://w1.weather.gov/xml/current_obs/KRDU.xml"
  """
  def code_url(code) do
    "http://w1.weather.gov/xml/current_obs/K#{code}.xml"
  end

  @doc """
  Handle a weather observation response or error.
  """
  def handle_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}, _),
    do: {:ok, handle_body(body)}
  def handle_response({:ok, %HTTPoison.Response{status_code: status_code}}, code),
    do: {:error, {to_string(status_code), code}}
  def handle_response({:error, response}, code), do: {:error, {response, code}}

  def erlsom_transform(data = current_observation()), do:
    Enum.into(current_observation(data), Map.new, &_transform_value/1)
  def erlsom_transform(data = imageType()), do:
    Enum.into(imageType(data), Map.new, &_transform_value/1)
  def erlsom_transform(data = [first | _rest]) when is_integer(first), do: List.to_string(data)
  def erlsom_transform(:undefined), do: nil
  def erlsom_transform(data), do: data

  defp _transform_value({k, v}), do: {k, erlsom_transform(v)}

  @doc """
  Parse the body of a weather observation response.
  """
  def handle_body(body) do
    {:ok, data, _rest} = :erlsom.scan(body, @xsdModel)
    erlsom_transform(data)
  end

  # def dict_values_to_string(dict), do:
  #   map_dict(dict, fn({key, value} -> {key, to_string(value)}))
  #
  # def map_dict(dict, f), do:
  #   Enum.into(Enum.map(Enum.to_list(dict), f), Map.new)
end
