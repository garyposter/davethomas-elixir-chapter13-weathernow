defmodule Weathernow do
  @moduledoc """
  CLI for getting the weather for a given airport.
  """
  require Monad.Error, as: Error
  import Error

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
    Enum.map(
      codes, fn(code) ->
        Error.p do
          Weathernow.NOAA.fetch(code)
          |> pop_all([:location, :latitude, :longitude, :observation_time])
          |> prepare_headers(header_names)
          |> display
        end
      end)
    |> handle_errors
  end

  def handle_errors(list), do:
    for {:error, {message, airport_code}} <- list, do:
        IO.puts("Error retrieving #{airport_code}: #{message}")

  def pop_all(dict, keys, default \\ nil), do: _pop_all(dict, keys, default, [])

  defp _pop_all(dict, [], _default, values), do:
    {:ok, {Enum.reverse(values), dict}}
  defp _pop_all(dict, [first | rest], default, values) do
    {value, new_dict} = Dict.pop(dict, first, default)
    _pop_all(new_dict, rest, default, [value | values])
  end

  def prepare_headers({identifiers, dict}, header_names), do:
    {:ok, {identifiers,Enum.map(
      header_names,
      # XXX to_string is only necessary because erlsom actually handles ints.
      # Using SweetXml's xpath makes this unnecessary.
      fn({key, header}) -> [header, to_string(dict[key])] end)}}

  def display({[location | [latitude | [longitude | time]]], values}) do
    IO.puts("#{location} (#{latitude}, #{longitude})")
    IO.puts(time)
    {rows, lengths} = Weathernow.CLITable.get_rows_and_widths(values)
    Enum.map(rows, fn(row) ->
      IO.puts(Weathernow.CLITable.generate_row(row, lengths))
    end)
    IO.write("\n")
    {:ok, location}
  end

  # def filter_into(source, filter, start, transform \\ &(&1)) do
  #   Enum.filter(source, filter)
  #   |> Enum.into(start, transform)
  # end

end
