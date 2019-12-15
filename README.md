# UTC DateTime

[![Hex.pm](https://img.shields.io/hexpm/v/utc_datetime.svg "Hex")](https://hex.pm/packages/utc_datetime)
[![Build Status](https://travis-ci.org/IanLuites/utc_datetime.svg?branch=master)](https://travis-ci.org/IanLuites/utc_datetime)
[![Coverage Status](https://coveralls.io/repos/github/IanLuites/utc_datetime/badge.svg?branch=master)](https://coveralls.io/github/IanLuites/utc_datetime?branch=master)
[![Hex.pm](https://img.shields.io/hexpm/l/utc_datetime.svg "License")](LICENSE)

A datetime implementation constraint to UTC.


## Goal

The goal is to create datetime type, which unlike `DateTime` guarantees to be
UTC only, without ignoring the existence of timezones like a `NaiveDateTime`.

A secondary goal is to be more efficient or at least on par with
the build in datetimes. (`DateTime`, `NaiveDateTime`)
In practice the goal is to use less memory and
perform common [shared] actions faster.


## Quick Setup

```elixir
iex> UTCDateTime.utc_now
~Z[2019-12-14 16:08:13.042407]

iex> UTCDateTime.from_rfc3339!("2019-12-14T16:08:13.042407+01:00")
~Z[2019-12-14 15:08:13.042407]

iex> UTCDateTime.from_iso8601!("2019-12-14 16:08:13.042407")
~Z[2019-12-14 16:08:13.042407]
```


## Installation

The package can be installed
by adding `utc_datetime` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:utc_datetime, "~> 0.0.1"}
  ]
end
```

The docs can be found at [https://hexdocs.pm/utc_datetime](https://hexdocs.pm/utc_datetime).


## Integration

Currently `UTCDateTime` does not integrate with other libraries.
Please check back later, because integrations are on the roadmap.


## Changelog

### v0.0.2 (2019-12-??)

New Features:
- `~Z` sigil for `UTCDateTime`
- `from_iso8601/1`, `from_iso8601!/1` ([ISO 8601:2004](https://www.iso.org/standard/40874.html))
- `from_rfc3339/1`, `from_rfc3339!/1` ([RFC 3339](https://tools.ietf.org/html/rfc3339))
- `to_iso8601/1` ([ISO 8601:2004](https://www.iso.org/standard/40874.html))
- `to_rfc3339/1` ([RFC 3339](https://tools.ietf.org/html/rfc3339))
- `to_string/1` (including `String.Chars` protocol)


### v0.0.1 (2019-12-14)

Base `UTCDateTime`.

New Features:
- `from_datetime/1`
- `from_naive/1`
- `to_datetime/1`, `to_datetime/2`
- `to_naive/1`, `to_naive/2`
- `utc_now/0`

Experimental:
- `~Z` sigil for `UTCDateTime`
- [RFC3339](https://tools.ietf.org/html/rfc3339) support

Additional:
- Benchmarks
- Roadmap


## Roadmap

- Integrations
  - `:fixtures`
  - `:time_machinex`
- Release 0.0.3
  - Epochs
- Release 0.0.4
  - Conversions erl/etc
  - `to_date/1`
  - `to_time/1`
  - `from_date_and_time/2` (optional time)
  - Benchmarks
- Release 0.0.5
  - Benchmarks page
  - Ecto Support
  - Benchmarks
- Release 0.0.6
  - Jason support
  - Benchmarks
- Release 0.0.7
  - Add / Diff / Truncate
  - Benchmarks
- Release 0.0.8
  - To Unix
  - To windows
  - to_epoch(epoch, time_unit)
  - Benchmarks
- Release 0.0.9
  - `to_local_datetime/1` (in caller)
- Release 0.0.10
  - `from_human/1` best effort parse


## Copyright and License

Copyright (c) 2019, Ian Luites.

UTCDateTime code is licensed under the [MIT License](LICENSE.md).
