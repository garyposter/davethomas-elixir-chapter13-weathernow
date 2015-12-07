# Initialize or update the data directory.
#
# Run this with `mix run init.exs` (or `mix run lib/weathernow/data/init.exs`
# from project root).

import SweetXml

client = [{"User-agent", "Elixir Tutorial Project gary@modernsongs.com"}]
options = [follow_redirect: true]

url = Weathernow.NOAA.code_url("RDU")
%HTTPoison.Response{body: body} = HTTPoison.get!(url, client, options)
schema_url = body |> xpath(
  ~x"//current_observation/@xsi:noNamespaceSchemaLocation")
%HTTPoison.Response{body: schema_body} = HTTPoison.get!(
  schema_url, client, options)
File.write!(Path.join(__DIR__, "current_observation.xsd"), schema_body)
:erlsom.write_xsd_hrl_file(
  Path.join(__DIR__, "current_observation.xsd"),
  Path.join(__DIR__, "current_observation.hrl"))
