defmodule Weathernow do
  @moduledoc """
  CLI for getting the weather for a given airport.
  """

  @header_names [
    weather: "Weather",
    temperature_string: "Temperature",
    relative_humidity: "Relative Humidity",
    wind_string: "Wind",
    pressure_string: "Pressure",
    dewpoint_string: "Dewpoint",
    visibility_mi: "Visibility (miles)"
  ]

  @doc """
  Given one or more airport codes, return the weather for each.
  """
  def main(argv) do
    parse_args(argv)
    |> process
  end

  def parse_args(argv) do
    parse = OptionParser.parse(
      argv, switches: [help: :boolean], aliases: [h: :help])
    case parse do
      {[help: true], _, _} -> :help
      {_, codes = [_first | _rest], _} -> {codes, @header_names}
      {_, _, _} -> :help
    end
  end

  def process(:help) do
    IO.puts("""
    Get the weather for one or more airports.

    Usage: weathernow <airport code> ...
    """)
    System.halt(0)
  end

  def process({codes, header_names}) do
    codes
    |> Weathernow.NOAA.fetch
    |> handle_errors # XXX investigate monads to be able to insert into the
                     # per-airport pipeline below.
    |> Enum.map(
      &(pop_all(&1, [:location, :latitude, :longitude, :observation_time]))
      |> prepare_headers(header_names)
      |> display
      )
  end

  def handle_errors([]), do: []
  def handle_errors([{:ok, data} | rest]), do: [data | handle_errors(rest)]
  def handle_errors([{:error, message, airport_code} | rest]) do
    IO.puts("Error retrieving #{airport_code}: #{message}")
    handle_errors(rest)
  end

  def pop_all(dict, keys, default \\ nil), do: _pop_all(dict, keys, default, [])

  defp _pop_all(dict, [], _default, values), do: {Enum.reverse(values), dict}
  defp _pop_all(dict, [first | rest], default, values) do
    {value, new_dict} = Dict.pop(dict, first, default)
    _pop_all(new_dict, rest, default, [value | values])
  end

  def prepare_headers({identifiers, dict}, header_names), do:
    {identifiers, Enum.map(
      header_names,
      fn({key, header}) -> [header, dict[key]] end)}

  def display({[location | [latitude | [longitude | time]]], values}) do
    IO.puts("#{location} (#{latitude}, #{longitude})")
    IO.puts(time)
    {rows, lengths} = Weathernow.CLITable.get_rows_and_widths(values)
    Enum.map(rows, fn(row) ->
      IO.puts(Weathernow.CLITable.generate_row(row, lengths))
    end)
    IO.write("\n")
  end

  # def filter_into(source, filter, start, transform \\ &(&1)) do
  #   Enum.filter(source, filter)
  #   |> Enum.into(start, transform)
  # end

end
