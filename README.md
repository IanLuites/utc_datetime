# UTC DateTime

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
