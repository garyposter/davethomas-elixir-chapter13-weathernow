# Weathernow

Following on the amazing hit of [my version of the CLI app from chapter
13](https://github.com/garyposter/davethomas-elixir-chapter13-issues) of Dave
Thomas' [Programming
Elixir](https://pragprog.com/book/elixir/programming-elixir), this is a rough
implementation of the second exercise at the end of the chapter.

The CLI accepts one or more airport codes, and returns the current weather from
the NOAA observation files.

```bash
$ ./weathernow RDU SFO
Raleigh / Durham, Raleigh-Durham International Airport, NC (35.89223, -78.78185)
Last Updated on Dec 8 2015, 7:51 am EST
Weather            ┃ Patches Fog   
Temperature        ┃ 37.0 F (2.8 C)
Relative Humidity  ┃ 96            
Wind               ┃ Calm          
Pressure           ┃ 1021.5 mb     
Dewpoint           ┃ 36.0 F (2.2 C)
Visibility (miles) ┃ 10.00         

San Francisco, San Francisco International Airport, CA (37.61961, -122.36558)
Last Updated on Dec 8 2015, 4:56 am PST
Weather            ┃ Fog            
Temperature        ┃ 54.0 F (12.2 C)
Relative Humidity  ┃ 93             
Wind               ┃ Calm           
Pressure           ┃ 1024.0 mb      
Dewpoint           ┃ 52.0 F (11.1 C)
Visibility (miles) ┃ 0.50           

```

I've explored a few things in the course of this implementation: the Erlang
erlsom library, the Elixir support for Erlang records (needed to use the erlsom
library), and the Error monad.  I might still explore the [dependency injection
approach to testing that José Valim
advocates](http://blog.plataformatec.com.br/2015/10/mocks-and-explicit-contracts/)
but since this is just an exercise, I might push that to another project.
