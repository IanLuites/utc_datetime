defmodule UTCDateTime do
  @moduledoc ~S"""
  A datetime implementation constraint to UTC.
  """
  alias Calendar.ISO

  @enforce_keys [:year, :month, :day, :hour, :minute, :second]
  defstruct [
    :year,
    :month,
    :day,
    :hour,
    :minute,
    :second,
    microsecond: {0, 0}
  ]

  @typedoc @moduledoc
  @type t :: %__MODULE__{
          year: Calendar.year(),
          month: Calendar.month(),
          day: Calendar.day(),
          hour: Calendar.hour(),
          minute: Calendar.minute(),
          second: Calendar.second(),
          microsecond: Calendar.microsecond()
        }

  ### Sigil ###

  @doc @moduledoc
  defmacro __using__(_opts \\ []) do
    quote do
      require unquote(__MODULE__)
      import unquote(__MODULE__), only: [sigil_Z: 2]
    end
  end

  @doc ~S"""
  Handles the sigil `~Z` to create a `UTCDateTime`.

  By default, this sigil requires UTC date times
  to be written in the ISO8601 format:

      ~Z[yyyy-mm-dd hh:mm:ssZ]
      ~Z[yyyy-mm-dd hh:mm:ss.ssssssZ]
      ~Z[yyyy-mm-ddThh:mm:ss.ssssss+00:00]

  such as:

      ~Z[2015-01-13 13:00:07Z]
      ~Z[2015-01-13T13:00:07.123+00:00]

  The given `utc_datetime_string` must include "Z" or "00:00" offset
  which marks it as UTC, otherwise an error is raised.

  The lower case `~z` variant does not exist as interpolation
  and escape characters are not useful for date time sigils.
  More information on date times can be found in the `UTCDateTime` module.

  ## Examples

  ```elixir
  iex> ~Z[2015-01-13 13:00:07Z]
  ~Z[2015-01-13 13:00:07Z]
  iex> ~Z[2015-01-13T13:00:07.001+00:00]
  ~Z[2015-01-13 13:00:07.001Z]
  ```
  """
  defmacro sigil_Z(utc_datetime_string, modifiers)

  defmacro sigil_Z({:<<>>, _, [string]}, []) do
    # A placeholder to improve testing
    string
    |> NaiveDateTime.from_iso8601!()
    |> from_naive
    |> Macro.escape()
  end

  defimpl Inspect do
    import UTCDateTime.Utility, only: [pad2: 1, pad4: 1, microsecond: 2]

    def inspect(
          %UTCDateTime{
            year: year,
            month: month,
            day: day,
            hour: hour,
            minute: minute,
            second: second,
            microsecond: {microsecond, precision}
          },
          _
        ) do
      if precision == 0 do
        :erlang.iolist_to_binary([
          "~Z[",
          pad4(year),
          "-",
          pad2(month),
          "-",
          pad2(day),
          " ",
          pad2(hour),
          ":",
          pad2(minute),
          ":",
          pad2(second),
          "]"
        ])
      else
        :erlang.iolist_to_binary([
          "~Z[",
          pad4(year),
          "-",
          pad2(month),
          "-",
          pad2(day),
          " ",
          pad2(hour),
          ":",
          pad2(minute),
          ":",
          pad2(second),
          microsecond(microsecond, precision),
          "]"
        ])
      end
    end
  end

  ### Epochs ###

  @doc ~S"""
  Returns the current UTC datetime.

  ## Examples

  ```elixir
  iex> utc_datetime = UTCDateTime.utc_now()
  iex> utc_datetime.year >= 2016
  true
  ```
  """
  @spec utc_now :: t
  def utc_now do
    {:ok, {year, month, day}, {hour, minute, second}, microsecond} =
      Calendar.ISO.from_unix(:os.system_time(), :native)

    %__MODULE__{
      year: year,
      month: month,
      day: day,
      hour: hour,
      minute: minute,
      second: second,
      microsecond: microsecond
    }
  end

  ### DateTime ###

  @doc ~S"""
  Converts the given `UTCDateTime` to `NaiveDateTime`.

  The given `utc_datetime` does not contain a calendar,
  so `Calendar.ISO` is set by default.
  It is possible to manually pass a different calendar.

  ## Examples

  ```elixir
  iex> UTCDateTime.to_datetime(~Z[2016-05-24 13:26:08.003])
  ~U[2016-05-24 13:26:08.003Z]
  """
  @spec to_datetime(UTCDateTime.t(), Calendar.calendar()) :: DateTime.t()
  def to_datetime(utc_datetime, calendar \\ Calendar.ISO)

  def to_datetime(
        %__MODULE__{
          year: year,
          month: month,
          day: day,
          hour: hour,
          minute: minute,
          second: second,
          microsecond: microsecond
        },
        calendar
      ) do
    %DateTime{
      year: year,
      month: month,
      day: day,
      calendar: calendar,
      hour: hour,
      minute: minute,
      second: second,
      microsecond: microsecond,
      std_offset: 0,
      time_zone: "Etc/UTC",
      utc_offset: 0,
      zone_abbr: "UTC"
    }
  end

  @doc ~S"""
  Converts the given `datetime` into a `UTCDateTime`.

  Any `datetime` with a none UTC time zone will be converted to UTC.

  ## Examples

  ```elixir
  iex> dt = %DateTime{year: 2000, month: 2, day: 29, zone_abbr: "UTC",
  ...>                hour: 23, minute: 0, second: 7, microsecond: {0, 1},
  ...>                utc_offset: 0, std_offset: 0, time_zone: "Etc/UTC"}
  iex> UTCDateTime.from_datetime(dt)
  ~Z[2000-02-29 23:00:07.0]
  ```

  ```elixir
  iex> dt = %DateTime{year: 2000, month: 2, day: 29, zone_abbr: "CET",
  ...>                hour: 23, minute: 0, second: 7, microsecond: {0, 1},
  ...>                utc_offset: 3600, std_offset: 0, time_zone: "Europe/Warsaw"}
  iex> UTCDateTime.from_datetime(dt)
  ~Z[2000-02-29 22:00:07.0]
  ```
  """
  @spec from_datetime(DateTime.t()) :: UTCDateTime.t()
  def from_datetime(datetime)

  def from_datetime(%DateTime{
        year: year,
        month: month,
        day: day,
        hour: hour,
        minute: minute,
        second: second,
        microsecond: microsecond,
        std_offset: 0,
        utc_offset: 0
      }),
      do: %__MODULE__{
        year: year,
        month: month,
        day: day,
        hour: hour,
        minute: minute,
        second: second,
        microsecond: microsecond
      }

  def from_datetime(%DateTime{
        calendar: calendar,
        year: year,
        month: month,
        day: day,
        hour: hour,
        minute: minute,
        second: second,
        microsecond: microsecond,
        std_offset: std_offset,
        utc_offset: utc_offset
      }) do
    {year, month, day, hour, minute, second, _microsecond} =
      year
      |> calendar.naive_datetime_to_iso_days(month, day, hour, minute, second, microsecond)
      |> ISO.add_day_fraction_to_iso_days(-(utc_offset + std_offset), 86_400)
      |> ISO.naive_datetime_from_iso_days()

    %__MODULE__{
      year: year,
      month: month,
      day: day,
      hour: hour,
      minute: minute,
      second: second,
      microsecond: microsecond
    }
  end

  ### NaiveDateTime ###

  @doc ~S"""
  Converts the given `UTCDateTime` into a `NaiveDateTime`.

  The given `utc_datetime` does not contain a calendar,
  so `Calendar.ISO` is set by default.
  It is possible to manually pass a different calendar.

  ## Examples

  iex> dt = %UTCDateTime{year: 2016, month: 5, day: 24,
  ...>                   hour: 13, minute: 26, second: 8,
  ...>                   microsecond: {3000, 3}}
  iex> UTCDateTime.to_naive(dt)
  ~N[2016-05-24 13:26:08.003]
  """
  @spec to_naive(UTCDateTime.t(), Calendar.calendar()) :: NaiveDateTime.t()
  def to_naive(utc_datetime, calendar \\ Calendar.ISO)

  def to_naive(
        %__MODULE__{
          year: year,
          month: month,
          day: day,
          hour: hour,
          minute: minute,
          second: second,
          microsecond: microsecond
        },
        calendar
      ) do
    %NaiveDateTime{
      year: year,
      month: month,
      day: day,
      calendar: calendar,
      hour: hour,
      minute: minute,
      second: second,
      microsecond: microsecond
    }
  end

  @doc ~S"""
  Converts the given `NaiveDateTime` to `UTCDateTime`.

  It expects the given `naive_datetime` to be in the "Etc/UTC" time zone.

  ## Examples

  ```elixir
  iex> UTCDateTime.from_naive(~N[2016-05-24 13:26:08.003])
  ~Z[2016-05-24 13:26:08.003]
  ```
  """
  @spec from_naive(NaiveDateTime.t()) :: t
  def from_naive(naive_datetime)

  def from_naive(%NaiveDateTime{
        year: year,
        month: month,
        day: day,
        hour: hour,
        minute: minute,
        second: second,
        microsecond: microsecond
      }),
      do: %__MODULE__{
        year: year,
        month: month,
        day: day,
        hour: hour,
        minute: minute,
        second: second,
        microsecond: microsecond
      }

  ### RFC 3339 ###

  # Very Naive, just for debugging
  import __MODULE__.Utility, only: [pad2: 1, pad4: 1, microsecond: 2]

  @doc ~S"""
  Parses the extended "Date and time of day" format described by
  [RFC3339](https://tools.ietf.org/html/rfc3339).

  Time zone offset may be included in the string but they will be
  converted to UTC time and stored as such.

  The year parsed by this function is limited to four digits and,
  while ISO 8601 allows datetimes to specify 24:00:00 as the zero
  hour of the next day, this notation is not supported by Elixir.

  Note leap seconds are not supported.

  ## Examples

  ```elixir
  iex> UTCDateTime.from_rfc3339("2015-01-23t23:50:07")
  {:ok, ~Z[2015-01-23 23:50:07]}
  iex> UTCDateTime.from_rfc3339("2015-01-23T23:50:07")
  {:ok, ~Z[2015-01-23 23:50:07]}
  iex> UTCDateTime.from_rfc3339("2015-01-23T23:50:07Z")
  {:ok, ~Z[2015-01-23 23:50:07]}
  ```

  ```elixir
  iex> UTCDateTime.from_rfc3339("2015-01-23T23:50:07.0")
  {:ok, ~Z[2015-01-23 23:50:07.0]}
  iex> UTCDateTime.from_rfc3339("2015-01-23T23:50:07,0123456")
  {:ok, ~Z[2015-01-23 23:50:07.012345]}
  iex> UTCDateTime.from_rfc3339("2015-01-23T23:50:07.0123456")
  {:ok, ~Z[2015-01-23 23:50:07.012345]}
  iex> UTCDateTime.from_rfc3339("2015-01-23T23:50:07.123Z")
  {:ok, ~Z[2015-01-23 23:50:07.123]}
  iex> UTCDateTime.from_rfc3339("2016-02-29T23:50:07")
  {:ok, ~Z[2016-02-29 23:50:07]}
  ```

  ```elixir
  iex> UTCDateTime.from_rfc3339("2015-01-23P23:50:07")
  {:error, :invalid_format}
  iex> UTCDateTime.from_rfc3339("2015:01:23 23-50-07")
  {:error, :invalid_format}
  iex> UTCDateTime.from_rfc3339("2015-01-23 23:50:07A")
  {:error, :invalid_format}
  iex> UTCDateTime.from_rfc3339("2015-01-23T24:50:07")
  {:error, :invalid_hour}
  iex> UTCDateTime.from_rfc3339("2015-01-23T23:61:07")
  {:error, :invalid_minute}
  iex> UTCDateTime.from_rfc3339("2015-01-23T23:50:61")
  {:error, :invalid_second}
  iex> UTCDateTime.from_rfc3339("2015-13-12T23:50:07")
  {:error, :invalid_month}
  iex> UTCDateTime.from_rfc3339("2015-01-32T23:50:07")
  {:error, :invalid_day}
  iex> UTCDateTime.from_rfc3339("2015-02-29T23:50:07")
  {:error, :invalid_day}
  ```

  ```elixir
  iex> UTCDateTime.from_rfc3339("2015-01-23T23:50:07.123+02:30")
  {:ok, ~Z[2015-01-23 21:20:07.123]}
  iex> UTCDateTime.from_rfc3339("2015-01-23T23:50:07.123+00:00")
  {:ok, ~Z[2015-01-23 23:50:07.123]}
  iex> UTCDateTime.from_rfc3339("2015-01-23T23:50:07.123-02:30")
  {:ok, ~Z[2015-01-24 02:20:07.123]}
  ```

  ```elixir
  iex> UTCDateTime.from_rfc3339("2015-01-23T23:50:07.123-00:00")
  {:error, :invalid_format}
  iex> UTCDateTime.from_rfc3339("2015-01-23T23:50:07.123-00:60")
  {:error, :invalid_format}
  iex> UTCDateTime.from_rfc3339("2015-01-23T23:50:07.123-24:00")
  {:error, :invalid_format}
  ```
  """
  @spec from_rfc3339(String.t()) :: {:ok, UTCDateTime.t()} | {:error, reason :: :invalid_format}
  def from_rfc3339(datetime)

  @sep_rfc3339 [?t, ?T]
  [match_date, guard_date, read_date] = Calendar.ISO.__match_date__()
  [match_time, guard_time, read_time] = Calendar.ISO.__match_time__()

  def from_rfc3339(string) do
    with <<unquote(match_date), sep, unquote(match_time), rest::binary>> <- string,
         true <- unquote(guard_date) and sep in @sep_rfc3339 and unquote(guard_time),
         {microsec, rest} <- ISO.parse_microsecond(rest),
         {offset, ""} <- ISO.parse_offset(rest) do
      {year, month, day} = unquote(read_date)
      {hour, minute, second} = unquote(read_time)

      cond do
        month > 12 ->
          {:error, :invalid_month}

        day > ISO.days_in_month(year, month) ->
          {:error, :invalid_day}

        hour > 23 ->
          {:error, :invalid_hour}

        minute > 59 ->
          {:error, :invalid_minute}

        second > 59 ->
          {:error, :invalid_second}

        offset == nil or offset == 0 ->
          {:ok,
           %__MODULE__{
             year: year,
             month: month,
             day: day,
             hour: hour,
             minute: minute,
             second: second,
             microsecond: microsec
           }}

        true ->
          {year, month, day, hour, minute, second, _microsecond} =
            year
            |> ISO.naive_datetime_to_iso_days(month, day, hour, minute, second, {0, 0})
            |> ISO.add_day_fraction_to_iso_days(-offset, 86_400)
            |> ISO.naive_datetime_from_iso_days()

          {:ok,
           %__MODULE__{
             year: year,
             month: month,
             day: day,
             hour: hour,
             minute: minute,
             second: second,
             microsecond: microsec
           }}
      end
    else
      _ -> {:error, :invalid_format}
    end
  end

  @doc ~S"""
  Converts the given `utc_datetime` to
  [RFC3339](https://tools.ietf.org/html/rfc3339).

  ## Examples

  ```elixir
  iex> UTCDateTime.to_rfc3339(~Z[2019-12-14 08:06:24.289659])
  "2019-12-14T08:06:24.289659Z"
  iex> UTCDateTime.to_rfc3339(~Z[2019-12-14 08:06:24])
  "2019-12-14T08:06:24Z"
  ```
  """
  @spec to_rfc3339(t) :: String.t()
  def to_rfc3339(utc_datetime)

  def to_rfc3339(%UTCDateTime{
        year: year,
        month: month,
        day: day,
        hour: hour,
        minute: minute,
        second: second,
        microsecond: {microsecond, precision}
      }) do
    if precision == 0 do
      :erlang.iolist_to_binary([
        pad4(year),
        "-",
        pad2(month),
        "-",
        pad2(day),
        "T",
        pad2(hour),
        ":",
        pad2(minute),
        ":",
        pad2(second),
        "Z"
      ])
    else
      :erlang.iolist_to_binary([
        pad4(year),
        "-",
        pad2(month),
        "-",
        pad2(day),
        "T",
        pad2(hour),
        ":",
        pad2(minute),
        ":",
        pad2(second),
        microsecond(microsecond, precision),
        "Z"
      ])
    end
  end
end
