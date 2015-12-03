# Initialize or update the test data directory.
#
# Run this with `mix run test/test_init.exs`.

url = Weathernow.NOAA.code_url("RDU")
%HTTPoison.Response{body: body} = HTTPoison.get!(url)
File.write!(Path.join([__DIR__, "data", "RDU.xml"]), body)
