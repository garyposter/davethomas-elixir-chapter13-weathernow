defmodule Weathernow.CLITable do

  @moduledoc """
  Helper functions to create CLI Tables.
  """

  @doc """
  Given table data and desired column widths such as generated from
  `generate_table_data_from_maps`, and display headers, produce a list of
  strings that can be rendered on a CLI or similar.
  """
  def generate_table({table_data, widths}, headers) do
    widths = update_max_lengths(headers, widths)
    [generate_row(headers, widths) |
      [generate_divider(widths) |
        Enum.map(table_data, &(generate_row(&1, widths)))]]
  end

  @doc """
  Given a row of content and desired width for each, produce a string
  representing the row.

  ## Example
      iex> Issues.CLITable.generate_row(["foo", "barbaz"], [6, 5])
      "foo    ┃ barba"
  """
  def generate_row(content, widths) do
    Enum.map_join(
      Enum.zip(content, widths),
      " \u2503 ", # ┃
      fn({string, width}) ->
        String.ljust(String.slice(string, 0, width), width)
      end)
  end

  @doc """
  Given a list of widths, produce a horizontal divider.

  ## Example
      iex> Issues.CLITable.generate_divider([3,5,2])
      "━━━━╋━━━━━━━╋━━━"
  """
  def generate_divider(widths) do
    Enum.map_join(
      widths,
      "\u2501\u254B\u2501", # ━╋━
      fn(width) ->
        String.duplicate("\u2501", width) # ━
      end)
  end

  @doc """
  Given a collection of maps and desired keys, return a collection of lists of
  the stringified values for the desired keys from each map; and a list of the
  max string lengths of the values in each column.

  ## Example
      iex> Issues.CLITable.generate_table_data_from_maps(
      ...> [%{"a" => 42, "b" => "foobar", "c" => "dinos"},
      ...>  %{"a" => 2015, "b" => "Thanksgiving", "c" => "yo"}], ["c", "a"])
      {[["dinos", "42"], ["yo", "2015"]], [5, 4]}
  """
  # def generate_table_data_from_maps(maps, keys) do
  #   lengths = List.duplicate(0, Enum.count(keys))
  #   Enum.map_reduce(
  #     maps,
  #     lengths,
  #     fn(map, lengths) ->
  #       strings = get_row_data(map, keys)
  #       {strings, update_max_lengths(strings, lengths)}
  #     end)
  # end

  # get_fields_and_widths(table_data, &(get_string_values(&1, keys)))

  def get_rows_and_widths(table_data, get_row_fields \\ &(&1)), do:
    Enum.map_reduce(
      table_data,
      nil,
      fn(row_data, lengths) ->
        fields = get_row_fields.(row_data)
        {fields, update_max_lengths(fields, lengths)}
      end)

  @doc """
  Helps calculating the max string lengths of a collection of rows of strings.
  This function receives the strings from one row of the collection, and the
  current max string lengths.  Return the updated max lengths to take the new
  row into account.

  ## Example
      iex> Issues.CLITable.update_max_lengths(["foo", "shazam"], [4, 5])
      [4, 6]
  """
  def update_max_lengths(strings, nil), do:
    update_max_lengths(strings, List.duplicate(0, Enum.count(strings)))

  def update_max_lengths(strings, lengths) do
    Enum.map(
      Enum.zip(strings, lengths),
      fn({string, max_length}) ->
        max(String.length(string), max_length)
      end)
  end

  @doc """
  Given a map and a collection of keys, return a collection of stringified
  values from the map, matching the given keys.

  ## Example
      iex> Issues.CLITable.get_string_values(
      ...> %{"a" => 42, "b" => "foobar", "c" => "dinos"}, ["c", "a"])
      ["dinos", "42"]
  """
  def get_string_values(map, keys) do
    keys |> Enum.map(&(map[&1] |> to_string))
  end

end
