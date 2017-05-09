# Noaa

Accepts a NOAA Station ID and outputs the current weather data from that
station.

Stations can be found on the
[NOAA Website](http://w1.weather.gov/xml/current_obs/).

## Installation

Run `mix escript.build` from the command line

## Usage

### Station Data
Once built (see above), from the command line:

```shell
./noaa <station ID>
```

So to look at the Los Angeles International Airport data, you would
run:

```shell
./noaa KLAX
```

And output would be similar to the following:

```shell
 Los Angeles, Los Angeles International Airport, CA
 KLAX
 33.93806, -118.38889

 Last Updated            Tue, 09 May 2017 07:53:00 -0700
 Weather                 Overcast
 Temperature             61.0 F (16.1 C)
 Dewpoint                55.0 F (12.8 C)
 Relative Humidity (%)   81
 Wind                    Variable at 4.6 MPH (4 KT)
 Visibility (mi.)        7.00
 Altimeter (in. Hg)      29.88
```

### Help
To display help you can do `-h` or `--help`:

```shell
./issues -h
```