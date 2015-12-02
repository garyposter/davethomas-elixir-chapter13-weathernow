defmodule Weathernow.NOAA do

  import SweetXml

  @user_agent [{"User-agent", "Elixir Tutorial Project gary@modernsongs.com"}]
  def fetch(airport_codes) do
    Enum.map(airport_codes, fn(code) ->
      code_url(code)
      |> HTTPoison.get(@user_agent)
      |> handle_response(code)
    end)
  end

  def code_url(code) do
    "http://w1.weather.gov/xml/current_obs/K#{code}.xml"
  end

  def handle_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}, _),
    do: {:ok, handle_body(body)}
  def handle_response({:ok, %HTTPoison.Response{status_code: status_code}}, code),
    do: {:error, to_string(status_code), code}
  def handle_response({:error, response}, code), do: {:error, response, code}

  def handle_body(body), do: # TODO Consider switching to :erlsom.scan
    body
    |> xpath(~x"//current_observation/*"l, # Get a list of the child nodes.
             tag: ~x"name()", # Get the tag name for each.
             value: ~x"./text()"s) # Get the text for each.
    |> Enum.map(fn(%{tag: tag, value: value}) -> {List.to_atom(tag), value} end)
    |> Enum.into(Map.new)

  # def dict_values_to_string(dict), do:
  #   map_dict(dict, fn({key, value} -> {key, to_string(value)}))
  #
  # def map_dict(dict, f), do:
  #   Enum.into(Enum.map(Enum.to_list(dict), f), Map.new)
end
