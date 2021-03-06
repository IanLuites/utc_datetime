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

  @epochs_docs ~S"""
  | Epoch | Date | Aliases |
  |-|-|-|
  | `:go` | 0001-01-01 | `:dotnet`, `:rata_die`, `:rexx` |
  | `:uuid` | 1582-10-15 | |
  | `:win` | 1601-01-01 | `:win_nt`, `:win32`, `:cobol`, `:ntfs` |
  | `:mumps` | 1840-12-31 | |
  | `:vms` | 1858-11-17 | `:vms`, `:usno`, `:dvb`, `:mjd` |
  | `:pascal` | 1899-12-30 | `:ms_com`, `:libre_office_calc`, `:google_sheets` |
  | `:ms_c` | 1899-12-31 | `:dyalog_alp` |
  | `:ms_excel` | 1900-01-00 | `:ms_excel`, `:lotus` |
  | `:unix` | 1970-01-01 | `:posix` |
  """

  @typedoc """
  Common datetime epochs.

  ## Epochs

  #{@epochs_docs}
  """
  @type epoch ::
          :cobol
          | :dotnet
          | :dvb
          | :dyalog_alp
          | :go
          | :google_sheets
          | :libre_office_calc
          | :lotus
          | :mjd
          | :ms_c
          | :ms_com
          | :ms_excel
          | :mumps
          | :ntfs
          | :pascal
          | :posix
          | :rata_die
          | :rexx
          | :unix
          | :usno
          | :uuid
          | :vms
          | :win
          | :win32
          | :win64
          | :win_nt

  ### Sigil ###

  @doc false
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
    string
    |> from_iso8601!()
    |> Macro.escape()
  end

  defimpl String.Chars do
    def to_string(utc_datetime), do: UTCDateTime.to_rfc3339(utc_datetime)
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

  @doc ~S"""
  Compares two `UTCDateTime` structs.

  Returns `:gt` if first (`utc_datetime1`) is later than the second
  (`utc_datetime2`) and `:lt` for vice versa. If the two `UTCDateTime`
  are equal `:eq` is returned.

  ## Examples

  ```elixir
  iex> UTCDateTime.compare(~Z[2016-04-16 13:30:15], ~Z[2016-04-28 16:19:25])
  :lt
  iex> UTCDateTime.compare(~Z[2016-04-16 13:30:15.1], ~Z[2016-04-16 13:30:15.01])
  :gt
  iex> UTCDateTime.compare(~Z[2016-04-16 13:30:15.654321], ~Z[2016-04-16 13:30:15.654321])
  :eq
  ```
  """
  @spec compare(t, t) :: :lt | :eq | :gt
  def compare(utc_datetime1, utc_datetime2)

  def compare(
        %__MODULE__{
          year: y1,
          month: m1,
          day: d1,
          hour: h1,
          minute: min1,
          second: s1,
          microsecond: {ms1, _}
        },
        %__MODULE__{
          year: y2,
          month: m2,
          day: d2,
          hour: h2,
          minute: min2,
          second: s2,
          microsecond: {ms2, _}
        }
      ) do
    do_compare([
      {y1, y2},
      {m1, m2},
      {d1, d2},
      {h1, h2},
      {min1, min2},
      {s1, s2},
      {ms1, ms2}
    ])
  end

  defp do_compare([]), do: :eq

  defp do_compare([{a, b} | rest]) do
    cond do
      a == b -> do_compare(rest)
      a < b -> :lt
      true -> :gt
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

  @doc ~S"""
  Converts the given `utc_datetime` to a string using the format
  defined by [RFC 3339](https://tools.ietf.org/html/rfc3339).

  For more examples see: `to_rfc3339/1`.

  ### Examples

  ```elixir
  iex> UTCDateTime.to_string(~Z[2000-02-28 23:00:13])
  "2000-02-28T23:00:13Z"
  iex> UTCDateTime.to_string(~Z[2000-02-28 23:00:13.001])
  "2000-02-28T23:00:13.001Z"
  ```
  """
  @spec to_string(UTCDateTime.t()) :: String.t()
  def to_string(utc_datetime), do: UTCDateTime.to_rfc3339(utc_datetime)

  @doc """
  A `UTCDateTime` representing the given `epoch`.

  ## Epochs

  #{@epochs_docs}

  ## Examples

  ```elixir
  iex> UTCDateTime.epoch(:unix)
  ~Z[1970-01-01 00:00:00]

  iex> UTCDateTime.epoch(:win)
  ~Z[1601-01-01 00:00:00]

  iex> UTCDateTime.epoch(:go)
  ~Z[0001-01-01 00:00:00]
  ```
  """
  @spec epoch(epoch :: epoch) :: t | no_return
  def epoch(epoch), do: __MODULE__.Epochs.epoch(epoch)

  ### DateTime ###

  @doc ~S"""
  Converts the given `UTCDateTime` to `DateTime`.

  The given `utc_datetime` does not contain a calendar,
  so `Calendar.ISO` is set by default.
  It is possible to manually pass a different calendar.

  ## Examples

  ```elixir
  iex> UTCDateTime.to_datetime(~Z[2016-05-24 13:26:08.003])
  ~U[2016-05-24 13:26:08.003Z]
  ```
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

  import __MODULE__.Utility, only: [pad2: 1, pad4: 1, microsecond: 2]

  @doc ~S"""
  Parses the extended "Date and time of day" format described by
  [RFC 3339](https://tools.ietf.org/html/rfc3339).

  Time zone offset may be included in the string but they will be
  converted to UTC time and stored as such.

  The year parsed by this function is limited to four digits and,
  while RFC 3339 allows datetimes to specify 24:00:00 as the zero
  hour of the next day, this notation is not supported.

  Passing `-00:00` as undefined timezone is also not supported and
  will be interpreted as UTC.

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
  iex> UTCDateTime.from_rfc3339("2015-01-23T23:50:07.123+0230")
  {:ok, ~Z[2015-01-23 21:20:07.123]}
  iex> UTCDateTime.from_rfc3339("2015-01-23T23:50:07.123-0230")
  {:ok, ~Z[2015-01-24 02:20:07.123]}
  iex> UTCDateTime.from_rfc3339("2015-01-23T23:50:07.123+02")
  {:ok, ~Z[2015-01-23 21:50:07.123]}
  iex> UTCDateTime.from_rfc3339("2015-01-23T23:50:07.123-02")
  {:ok, ~Z[2015-01-24 01:50:07.123]}
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
  @spec from_rfc3339(String.t()) ::
          {:ok, UTCDateTime.t()}
          | {:error,
             reason ::
               :invalid_format
               | :invalid_month
               | :invalid_day
               | :invalid_hour
               | :invalid_minute
               | :invalid_second}
  def from_rfc3339(datetime)

  @sep_rfc3339 [?t, ?T]
  [match_date, guard_date, read_date] = __MODULE__.ISO.__match_date__()
  [match_time, guard_time, read_time] = __MODULE__.ISO.__match_time__()

  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  def from_rfc3339(string) do
    with <<unquote(match_date), sep, unquote(match_time), rest::binary>> <- string,
         true <- unquote(guard_date) and sep in @sep_rfc3339 and unquote(guard_time),
         {microsec, rest} <- __MODULE__.ISO.parse_microsecond(rest),
         {offset, ""} <- __MODULE__.ISO.parse_offset(rest) do
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

  ### ISO 8601 ###
  @sep_iso8601 [?T, ?\s, ?t]

  @doc ~S"""
  Parses the extended "Date and time of day" format described by
  [ISO 8601:2004](https://www.iso.org/standard/40874.html).

  Time zone offset may be included in the string but they will be
  converted to UTC time and stored as such.

  The year parsed by this function is limited to four digits and,
  while ISO 8601 allows datetimes to specify 24:00:00 as the zero
  hour of the next day, this notation is not supported by Elixir.

  Note leap seconds are not supported.

  ## Examples

  ```elixir
  iex> UTCDateTime.from_iso8601("2015-01-23t23:50:07")
  {:ok, ~Z[2015-01-23 23:50:07]}
  iex> UTCDateTime.from_iso8601("2015-01-23T23:50:07")
  {:ok, ~Z[2015-01-23 23:50:07]}
  iex> UTCDateTime.from_iso8601("2015-01-23 23:50:07")
  {:ok, ~Z[2015-01-23 23:50:07]}
  iex> UTCDateTime.from_iso8601("2015-01-23T23:50:07Z")
  {:ok, ~Z[2015-01-23 23:50:07]}
  ```

  ```elixir
  iex> UTCDateTime.from_iso8601("2015-01-23T23:50:07.0")
  {:ok, ~Z[2015-01-23 23:50:07.0]}
  iex> UTCDateTime.from_iso8601("2015-01-23T23:50:07,0123456")
  {:ok, ~Z[2015-01-23 23:50:07.012345]}
  iex> UTCDateTime.from_iso8601("2015-01-23T23:50:07.0123456")
  {:ok, ~Z[2015-01-23 23:50:07.012345]}
  iex> UTCDateTime.from_iso8601("2015-01-23T23:50:07.123Z")
  {:ok, ~Z[2015-01-23 23:50:07.123]}
  iex> UTCDateTime.from_iso8601("2016-02-29T23:50:07")
  {:ok, ~Z[2016-02-29 23:50:07]}
  ```

  ```elixir
  iex> UTCDateTime.from_iso8601("2015-01-23P23:50:07")
  {:error, :invalid_format}
  iex> UTCDateTime.from_iso8601("2015:01:23 23-50-07")
  {:error, :invalid_format}
  iex> UTCDateTime.from_iso8601("2015-01-23 23:50:07A")
  {:error, :invalid_format}
  iex> UTCDateTime.from_iso8601("2015-01-23T24:50:07")
  {:error, :invalid_hour}
  iex> UTCDateTime.from_iso8601("2015-01-23T23:61:07")
  {:error, :invalid_minute}
  iex> UTCDateTime.from_iso8601("2015-01-23T23:50:61")
  {:error, :invalid_second}
  iex> UTCDateTime.from_iso8601("2015-13-12T23:50:07")
  {:error, :invalid_month}
  iex> UTCDateTime.from_iso8601("2015-01-32T23:50:07")
  {:error, :invalid_day}
  iex> UTCDateTime.from_iso8601("2015-02-29T23:50:07")
  {:error, :invalid_day}
  ```

  ```elixir
  iex> UTCDateTime.from_iso8601("2015-01-23T23:50:07.123+02:30")
  {:ok, ~Z[2015-01-23 21:20:07.123]}
  iex> UTCDateTime.from_iso8601("2015-01-23T23:50:07.123+00:00")
  {:ok, ~Z[2015-01-23 23:50:07.123]}
  iex> UTCDateTime.from_iso8601("2015-01-23T23:50:07.123-02:30")
  {:ok, ~Z[2015-01-24 02:20:07.123]}
  ```

  ```elixir
  iex> UTCDateTime.from_iso8601("2015-01-23T23:50:07.123-00:00")
  {:error, :invalid_format}
  iex> UTCDateTime.from_iso8601("2015-01-23T23:50:07.123-00:60")
  {:error, :invalid_format}
  iex> UTCDateTime.from_iso8601("2015-01-23T23:50:07.123-24:00")
  {:error, :invalid_format}
  ```
  """
  @spec from_iso8601(String.t()) ::
          {:ok, UTCDateTime.t()}
          | {:error,
             reason ::
               :invalid_format
               | :invalid_month
               | :invalid_day
               | :invalid_hour
               | :invalid_minute
               | :invalid_second}
  def from_iso8601(datetime)

  def from_iso8601("-" <> string) do
    with {:ok, utc_datetime = %{year: y}} <- from_iso8601(string),
         do: {:ok, %{utc_datetime | year: -y}}
  end

  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  def from_iso8601(string) do
    with <<unquote(match_date), sep, unquote(match_time), rest::binary>> <- string,
         true <- unquote(guard_date) and sep in @sep_iso8601 and unquote(guard_time),
         {microsec, rest} <- __MODULE__.ISO.parse_microsecond(rest),
         {offset, ""} <- __MODULE__.ISO.parse_offset(rest) do
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
  [ISO 8601:2004](https://www.iso.org/standard/40874.html).

  ## Examples

  ```elixir
  iex> UTCDateTime.to_iso8601(~Z[2019-12-14 08:06:24.289659])
  "2019-12-14T08:06:24.289659Z"
  iex> UTCDateTime.to_iso8601(~Z[2019-12-14 08:06:24])
  "2019-12-14T08:06:24Z"
  ```
  """
  @spec to_iso8601(t) :: String.t()
  # RFC3339 is just a profile for ISO8601, so we can just re-use RFC3339
  def to_iso8601(utc_datetime), do: to_rfc3339(utc_datetime)

  ### Bangs ###

  @doc ~S"""
  Parses the extended "Date and time of day" format described by
  [RFC 3339](https://tools.ietf.org/html/rfc3339).

  Raises if the format is invalid.

  For more examples see: `from_rfc3339/1`.

  ## Examples

  ```elixir
  iex> UTCDateTime.from_rfc3339!("2015-01-23T23:50:07.123Z")
  ~Z[2015-01-23 23:50:07.123]
  iex> UTCDateTime.from_rfc3339!("2015-01-23T23:50:07,123Z")
  ~Z[2015-01-23 23:50:07.123]
  iex> UTCDateTime.from_rfc3339!("2015-01-23P23:50:07")
  ** (ArgumentError) cannot parse "2015-01-23P23:50:07" as UTC datetime, reason: :invalid_format
  ```
  """
  @spec from_rfc3339!(String.t()) :: UTCDateTime.t() | no_return
  def from_rfc3339!(datetime) do
    case from_rfc3339(datetime) do
      {:ok, value} ->
        value

      {:error, reason} ->
        raise ArgumentError,
              "cannot parse #{inspect(datetime)} as UTC datetime, reason: #{inspect(reason)}"
    end
  end

  @doc ~S"""
  Parses the extended "Date and time of day" format described by
  [ISO 8601:2004](https://www.iso.org/standard/40874.html).

  Raises if the format is invalid.

  For more examples see: `from_iso8601/1`.

  ## Examples

  ```elixir
  iex> UTCDateTime.from_iso8601!("2015-01-23T23:50:07.123Z")
  ~Z[2015-01-23 23:50:07.123]
  iex> UTCDateTime.from_iso8601!("2015-01-23T23:50:07,123Z")
  ~Z[2015-01-23 23:50:07.123]
  iex> UTCDateTime.from_iso8601!("2015-01-23P23:50:07")
  ** (ArgumentError) cannot parse "2015-01-23P23:50:07" as UTC datetime, reason: :invalid_format
  ```
  """
  @spec from_iso8601!(String.t()) :: UTCDateTime.t() | no_return
  def from_iso8601!(datetime) do
    case from_iso8601(datetime) do
      {:ok, value} ->
        value

      {:error, reason} ->
        raise ArgumentError,
              "cannot parse #{inspect(datetime)} as UTC datetime, reason: #{inspect(reason)}"
    end
  end

  ### Erlang ###

  @doc ~S"""
  Converts a `UTCDateTime` struct to an Erlang datetime tuple.

  WARNING: Loss of precision may occur, as Erlang time tuples only store
  hour/minute/second and the given `utc_datetime` could contain microsecond
  precision time data.

  ## Examples

  ```elixir
  iex> UTCDateTime.to_erl(~Z[2000-01-01 13:30:15])
  {{2000, 1, 1}, {13, 30, 15}}
  ```
  """
  @spec to_erl(UTCDateTime.t()) :: :calendar.datetime()
  def to_erl(utc_datetime)

  def to_erl(%__MODULE__{
        year: year,
        month: month,
        day: day,
        hour: hour,
        minute: minute,
        second: second
      }) do
    {{year, month, day}, {hour, minute, second}}
  end

  @doc ~S"""
  Converts a `erl_datetime` (Erlang datetime tuple) to `UTCDateTime`.

  A tuple of `microsecond` (precision) can additionally be given to
  extend the datetime.

  ## Examples

  ```elixir
  iex> UTCDateTime.from_erl({{2000, 1, 1}, {13, 30, 15}})
  {:ok, ~Z[2000-01-01 13:30:15]}

  iex> UTCDateTime.from_erl({{2000, 1, 1}, {13, 30, 15}}, {5000, 3})
  {:ok, ~Z[2000-01-01 13:30:15.005]}
  ```

  ```elixir
  iex> UTCDateTime.from_erl({{2000, 13, 1}, {13, 30, 15}})
  {:error, :invalid_month}
  iex> UTCDateTime.from_erl({{2000, 12, 32}, {13, 30, 15}})
  {:error, :invalid_day}
  iex> UTCDateTime.from_erl({{2000, 12, 31}, {25, 30, 15}})
  {:error, :invalid_hour}
  iex> UTCDateTime.from_erl({{2000, 12, 31}, {13, 61, 15}})
  {:error, :invalid_minute}
  iex> UTCDateTime.from_erl({{2000, 12, 31}, {13, 30, 61}})
  {:error, :invalid_second}
  ```
  """
  @spec from_erl(:calendar.datetime(), Calendar.microsecond()) ::
          {:ok, UTCDateTime.t()}
          | {:error,
             reason ::
               :invalid_format
               | :invalid_month
               | :invalid_day
               | :invalid_hour
               | :invalid_minute
               | :invalid_second}
  def from_erl(erl_datetime, microsecond \\ {0, 0})

  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  def from_erl({{year, month, day}, {hour, minute, second}}, microsecond = {us, p}) do
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

      us < 0 or us >= 1_000_000 or p < 0 or p > 6 ->
        {:error, :invalid_second}

      true ->
        {:ok,
         %__MODULE__{
           year: year,
           month: month,
           day: day,
           hour: hour,
           minute: minute,
           second: second,
           microsecond: microsecond
         }}
    end
  end

  @doc ~S"""
  Converts a `erl_datetime` (Erlang datetime tuple) to `UTCDateTime`.

  Raises if the datetime is invalid.

  A tuple of `microsecond` (precision) can additionally be given to
  extend the datetime.

  ## Examples

  ```elixir
  iex> UTCDateTime.from_erl!({{2000, 1, 1}, {13, 30, 15}})
  ~Z[2000-01-01 13:30:15]
  iex> UTCDateTime.from_erl!({{2000, 1, 1}, {13, 30, 15}}, {5000, 3})
  ~Z[2000-01-01 13:30:15.005]
  iex> UTCDateTime.from_erl!({{2000, 13, 1}, {13, 30, 15}})
  ** (ArgumentError) cannot convert {{2000, 13, 1}, {13, 30, 15}} to UTC datetime, reason: :invalid_month
  ```
  """
  @spec from_erl!(:calendar.datetime(), Calendar.microsecond()) :: UTCDateTime.t()
  def from_erl!(erl_datetime, microsecond \\ {0, 0}) do
    case from_erl(erl_datetime, microsecond) do
      {:ok, value} ->
        value

      {:error, reason} ->
        raise ArgumentError,
              "cannot convert #{inspect(erl_datetime)} to UTC datetime, reason: #{inspect(reason)}"
    end
  end

  ### Date and Time ###

  @doc ~S"""
  Converts a `UTCDateTime` into a `Date`.

  Because `Date` does not hold time information,
  data will be lost during the conversion.

  Because the given `utc_datetime` does not contain calendar information,
  a `calendar` can be given, but will default to `Calendar.ISO`.

  ## Examples

  ```elixir
  iex> UTCDateTime.to_date(~Z[2002-01-13 23:00:07])
  ~D[2002-01-13]
  ```
  """
  @spec to_date(UTCDateTime.t(), Calendar.calendar()) :: Date.t()
  def to_date(utc_datetime, calendar \\ Calendar.ISO)

  def to_date(%UTCDateTime{year: year, month: month, day: day}, calendar) do
    %Date{year: year, month: month, day: day, calendar: calendar}
  end

  @doc ~S"""
  Converts a `UTCDateTime` into `Time`.

  Because `Time` does not hold date information,
  data will be lost during the conversion.

  Because the given `utc_datetime` does not contain calendar information,
  a `calendar` can be given, but will default to `Calendar.ISO`.

  ## Examples

  ```elixir
  iex> UTCDateTime.to_time(~Z[2002-01-13 23:00:07])
  ~T[23:00:07]
  ```
  """
  @spec to_time(UTCDateTime.t(), Calendar.calendar()) :: Time.t()
  def to_time(utc_datetime, calendar \\ Calendar.ISO)

  def to_time(
        %UTCDateTime{hour: hour, minute: minute, second: second, microsecond: microsecond},
        calendar
      ) do
    %Time{
      hour: hour,
      minute: minute,
      second: second,
      microsecond: microsecond,
      calendar: calendar
    }
  end

  @doc ~S"""
  Converts a `Date` into `UTCDateTime`.

  Because `Date` does not hold time information,
  it is possible to supply a `Time` to set on the given `Date`.

  If no `Time` is supplied the `UTCDateTime` will default to: `00:00:00`.

  ## Examples

  ```elixir
  iex> UTCDateTime.from_date(~D[2002-01-13])
  ~Z[2002-01-13 00:00:00]

  iex> UTCDateTime.from_date(~D[2002-01-13], ~T[23:00:07])
  ~Z[2002-01-13 23:00:07]
  ```
  """
  @spec from_date(Date.t(), Time.t()) :: UTCDateTime.t()
  def from_date(date, time \\ ~T[00:00:00])

  def from_date(%Date{year: year, month: month, day: day}, %Time{
        hour: hour,
        minute: minute,
        second: second,
        microsecond: microsecond
      }) do
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

  ### From/To Epochs (Unix, NTFS) ###

  @ntfs_days :calendar.date_to_gregorian_days({1601, 1, 1})
  @unix_days :calendar.date_to_gregorian_days({1970, 1, 1})

  @doc ~S"""
  Converts the given Unix time to `UTCDateTime`.

  The integer can be given in different unit
  according to `System.convert_time_unit/3` and it will
  be converted to microseconds internally.

  ## Examples

  ```elixir
  iex> UTCDateTime.from_unix(1_464_096_368)
  {:ok, ~Z[2016-05-24 13:26:08]}

  iex> UTCDateTime.from_unix(1_432_560_368_868_569, :microsecond)
  {:ok, ~Z[2015-05-25 13:26:08.868569]}
  ```

  The unit can also be an integer as in `t:System.time_unit/0`:

  ```elixir
  iex> UTCDateTime.from_unix(143_256_036_886_856, 1024)
  {:ok, ~Z[6403-03-17 07:05:22.320312]}
  ```

  Negative Unix times are supported, up to -62167219200 seconds,
  which is equivalent to "0000-01-01T00:00:00Z" or 0 Gregorian seconds.
  """
  @spec from_unix(integer, :native | System.time_unit()) ::
          {:ok, UTCDateTime.t()} | {:error, atom}
  def from_unix(unix, unit \\ :second) do
    case ISO.from_unix(unix, unit) do
      {:ok, {year, month, day}, {hour, minute, second}, microsecond} ->
        {:ok,
         %UTCDateTime{
           year: year,
           month: month,
           day: day,
           hour: hour,
           minute: minute,
           second: second,
           microsecond: microsecond
         }}

      {:error, _} = error ->
        error
    end
  end

  @doc ~S"""
  Converts the given Unix time to `UTCDateTime`.

  The integer can be given in different unit
  according to `System.convert_time_unit/3` and it will
  be converted to microseconds internally.

  ## Examples

  ```elixir
  # An easy way to get the Unix epoch is passing 0 to this function
  iex> UTCDateTime.from_unix!(0)
  ~Z[1970-01-01 00:00:00Z]
  iex> UTCDateTime.from_unix!(1_464_096_368)
  ~Z[2016-05-24 13:26:08]
  iex> UTCDateTime.from_unix!(1_432_560_368_868_569, :microsecond)
  ~Z[2015-05-25 13:26:08.868569]
  iex> UTCDateTime.from_unix!(143_256_036_886_856, 1024)
  ~Z[6403-03-17 07:05:22.320312]
  ```

  Negative Unix times are supported, up to -62167219200 seconds,
  which is equivalent to "0000-01-01T00:00:00Z" or 0 Gregorian seconds.

  ```elixir
  iex> UTCDateTime.from_unix!(-12_063_167_219_280)
  ** (ArgumentError) invalid Unix time -12063167219280
  ```
  """
  @spec from_unix!(integer, :native | System.time_unit()) :: UTCDateTime.t() | no_return
  def from_unix!(unix, unit \\ :second) do
    case from_unix(unix, unit) do
      {:ok, datetime} -> datetime
      {:error, :invalid_unix_time} -> raise ArgumentError, "invalid Unix time #{unix}"
    end
  end

  @doc ~S"""
  Converts the given `utc_datetime` to Unix time.

  It will return the integer with the given unit,
  according to `System.convert_time_unit/3`.

  ## Examples

  ```elixir
  iex> 1_464_096_368 |> UTCDateTime.from_unix!() |> UTCDateTime.to_unix()
  1464096368
  ```

  ```elixir
  iex> UTCDateTime.to_unix(~Z[2019-12-20 23:20:52.832399])
  1576884052
  iex> UTCDateTime.to_unix(~Z[2019-12-20 23:20:52.832399], :millisecond)
  1576884052832
  iex> UTCDateTime.to_unix(~Z[2019-12-20 23:20:52.832399], :microsecond)
  1576884052832399
  ```

  ```elixir
  iex> UTCDateTime.to_unix(~Z[1219-12-20 23:20:52.832399])
  -23668677548
  ```
  """
  @spec to_unix(UTCDateTime.t(), System.time_unit()) :: integer
  def to_unix(utc_datetime, unit \\ :second)

  def to_unix(
        %__MODULE__{
          year: year,
          month: month,
          day: day,
          hour: hour,
          minute: minute,
          second: second,
          microsecond: microsecond
        },
        unit
      ) do
    {days, fraction} =
      ISO.naive_datetime_to_iso_days(year, month, day, hour, minute, second, microsecond)

    ISO.iso_days_to_unit({days - @unix_days, fraction}, unit)
  end

  @doc ~S"""
  Converts the given `utc_datetime` to the given NTFS or Windows time.

  It will return the integer with the given unit,
  according to `System.convert_time_unit/3`,
  but defaults to the stand 100 nanosecond intervals.

  For reference: [support.microsoft.com](https://support.microsoft.com/help/188768/info-working-with-the-filetime-structure)

  ## Examples

  ```elixir
  iex> UTCDateTime.to_ntfs(~Z[2019-12-20 23:20:52.832399])
  132213576528323990
  iex> UTCDateTime.to_ntfs(~Z[2019-12-20 23:20:52.832399], :millisecond)
  13221357652832
  iex> UTCDateTime.to_ntfs(~Z[2019-12-20 23:20:52.832399], :microsecond)
  13221357652832399
  ```

  ```elixir
  iex> UTCDateTime.to_ntfs(~Z[1219-12-20 23:20:52.832399])
  -120242039471676010
  ```
  """
  @spec to_ntfs(UTCDateTime.t(), System.time_unit()) :: integer
  def to_ntfs(utc_datetime, unit \\ 10_000_000)

  def to_ntfs(
        %__MODULE__{
          year: year,
          month: month,
          day: day,
          hour: hour,
          minute: minute,
          second: second,
          microsecond: microsecond
        },
        unit
      ) do
    {days, fraction} =
      ISO.naive_datetime_to_iso_days(year, month, day, hour, minute, second, microsecond)

    ISO.iso_days_to_unit({days - @ntfs_days, fraction}, unit)
  end

  @doc ~S"""
  Converts the given `utc_datetime` to the given epoch time.

  It will return the integer with the given unit,
  according to `System.convert_time_unit/3`.

  ## Examples

  ```elixir
  iex> UTCDateTime.to_epoch(~Z[2019-12-20 23:20:52], :unix)
  1576884052
  iex> UTCDateTime.to_epoch(~Z[2019-12-20 23:20:52], :ntfs)
  13221357652
  iex> UTCDateTime.to_epoch(~Z[2019-12-20 23:20:52], :go)
  63712480852
  ```

  ```elixir
  iex> UTCDateTime.to_epoch(~Z[2019-12-20 23:20:52.832399], :unix)
  1576884052
  iex> UTCDateTime.to_epoch(~Z[2019-12-20 23:20:52.832399], :unix, :millisecond)
  1576884052832
  iex> UTCDateTime.to_epoch(~Z[2019-12-20 23:20:52.832399], :unix, :microsecond)
  1576884052832399
  ```
  """
  @spec to_epoch(UTCDateTime.t(), UTCDateTime.epoch(), System.time_unit()) :: integer
  def to_epoch(utc_datetime, epoch, unit \\ :second)

  def to_epoch(
        %__MODULE__{
          year: year,
          month: month,
          day: day,
          hour: hour,
          minute: minute,
          second: second,
          microsecond: microsecond
        },
        epoch,
        unit
      ) do
    {days, fraction} =
      ISO.naive_datetime_to_iso_days(year, month, day, hour, minute, second, microsecond)

    ISO.iso_days_to_unit({days - __MODULE__.Epochs.epoch_days(epoch), fraction}, unit)
  end

  ### Truncate / Add / Diff ###

  @doc ~S"""
  Adds a specified amount of time to a `UTCDateTime`.

  Accepts an `amount_to_add` in any `unit` available from `t:System.time_unit/0`.

  Negative values will move the `utc_datetime` backwards in time.

  ## Examples

  ```elixir
  # adds seconds by default
  iex> UTCDateTime.add(~Z[2014-10-02 00:29:10], 2)
  ~Z[2014-10-02 00:29:12]
  ```

  ```elixir
  # accepts negative offsets
  iex> UTCDateTime.add(~Z[2014-10-02 00:29:10], -2)
  ~Z[2014-10-02 00:29:08]
  ```

  ```elixir
  # can work with other units
  iex> UTCDateTime.add(~Z[2014-10-02 00:29:10], 2_000, :millisecond)
  ~Z[2014-10-02 00:29:12]
  ```

  ```elixir
  # keeps the same precision
  iex> UTCDateTime.add(~Z[2014-10-02 00:29:10.021], 21, :second)
  ~Z[2014-10-02 00:29:31.021]
  ```

  ```elixir
  # changes below the precision will not be visible
  iex> hidden = UTCDateTime.add(~Z[2014-10-02 00:29:10], 21, :millisecond)
  iex> hidden.microsecond # ~Z[2014-10-02 00:29:10]
  {21000, 0}
  ```

  ```elixir
  # from Gregorian seconds
  iex> UTCDateTime.add(~Z[0000-01-01 00:00:00], 63_579_428_950)
  ~Z[2014-10-02 00:29:10]
  ```
  """
  @spec add(UTCDateTime.t(), integer, System.time_unit()) :: UTCDateTime.t()
  def add(utc_datetime, amount_to_add, unit \\ :second)

  def add(
        %__MODULE__{
          year: year,
          month: month,
          day: day,
          hour: hour,
          minute: minute,
          second: second,
          microsecond: microsecond = {_, precision}
        },
        amount_to_add,
        unit
      ) do
    ppd = System.convert_time_unit(86_400, :second, unit)

    {year, month, day, hour, minute, second, {microsecond, _}} =
      year
      |> ISO.naive_datetime_to_iso_days(month, day, hour, minute, second, microsecond)
      |> ISO.add_day_fraction_to_iso_days(amount_to_add, ppd)
      |> ISO.naive_datetime_from_iso_days()

    %__MODULE__{
      year: year,
      month: month,
      day: day,
      hour: hour,
      minute: minute,
      second: second,
      microsecond: {microsecond, precision}
    }
  end

  @doc ~S"""
  Subtracts `utc_datetime1` from `utc_datetime2`.

  The answer can be returned in any `unit` available from `t:System.time_unit/0`.

  This function returns the difference in seconds where seconds are measured
  according to `Calendar.ISO`.

  ## Examples

  ```elixir
  iex> UTCDateTime.diff(~Z[2014-10-02 00:29:12], ~Z[2014-10-02 00:29:10])
  2
  iex> UTCDateTime.diff(~Z[2014-10-02 00:29:12], ~Z[2014-10-02 00:29:10], :microsecond)
  2_000_000
  iex> UTCDateTime.diff(~Z[2014-10-02 00:29:10.042], ~Z[2014-10-02 00:29:10.021], :millisecond)
  21
  iex> UTCDateTime.diff(~Z[2014-10-02 00:29:10], ~Z[2014-10-02 00:29:12])
  -2
  iex> UTCDateTime.diff(~Z[-0001-10-02 00:29:10], ~Z[-0001-10-02 00:29:12])
  -2
  ```

  ```elixir
  # to Gregorian seconds
  iex> UTCDateTime.diff(~Z[2014-10-02 00:29:10], ~Z[0000-01-01 00:00:00])
  63579428950
  ```
  """
  @spec diff(UTCDateTime.t(), UTCDateTime.t(), System.time_unit()) :: integer
  def diff(utc_datetime1, utc_datetime2, unit \\ :second)

  def diff(
        %__MODULE__{
          year: year1,
          month: month1,
          day: day1,
          hour: hour1,
          minute: minute1,
          second: second1,
          microsecond: microsecond1
        },
        %__MODULE__{
          year: year2,
          month: month2,
          day: day2,
          hour: hour2,
          minute: minute2,
          second: second2,
          microsecond: microsecond2
        },
        unit
      ) do
    units1 =
      year1
      |> ISO.naive_datetime_to_iso_days(month1, day1, hour1, minute1, second1, microsecond1)
      |> ISO.iso_days_to_unit(unit)

    units2 =
      year2
      |> ISO.naive_datetime_to_iso_days(month2, day2, hour2, minute2, second2, microsecond2)
      |> ISO.iso_days_to_unit(unit)

    units1 - units2
  end

  @doc ~S"""
  Returns the given `utc_datetime` with the microsecond field truncated to the
  given precision (`:microsecond`, `:millisecond` or `:second`).

  The given naive datetime is returned unchanged if it already has lower precision
  than the given precision.

  ## Examples

  ```elixir
  iex> UTCDateTime.truncate(~Z[2017-11-06 00:23:51.123456], :microsecond)
  ~Z[2017-11-06 00:23:51.123456]
  iex> UTCDateTime.truncate(~Z[2017-11-06 00:23:51.123456], :millisecond)
  ~Z[2017-11-06 00:23:51.123]
  iex> UTCDateTime.truncate(~Z[2017-11-06 00:23:51.123456], :second)
  ~Z[2017-11-06 00:23:51]
  ```
  """
  @spec truncate(UTCDateTime.t(), :microsecond | :millisecond | :second) :: UTCDateTime.t()
  def truncate(utc_datetime, precision)
  def truncate(utc_datetime = %UTCDateTime{}, :microsecond), do: utc_datetime
  def truncate(utc_datetime = %UTCDateTime{}, :second), do: %{utc_datetime | microsecond: {0, 0}}

  def truncate(utc_datetime = %UTCDateTime{microsecond: {microsecond, precision}}, :millisecond) do
    %{utc_datetime | microsecond: {div(microsecond, 1000) * 1000, min(precision, 3)}}
  end

  ### Ecto Integration (Optional) ###

  require UTCDateTime.EctoTyper
  UTCDateTime.EctoTyper.type(:utc_datetime)

  defmodule USec do
    @moduledoc ~S"""
    Microsecond precision UTCDateTime Ecto type.

    For [default] second precision
    use `UTCDateTime` in stead of `UTCDateTime.USec`.
    """
    require UTCDateTime.EctoTyper
    UTCDateTime.EctoTyper.type(:utc_datetime_usec)

    @doc false
    @spec from_unix!(integer, :native | System.time_unit()) :: UTCDateTime.t() | no_return
    def from_unix!(unix, unit \\ :second), do: UTCDateTime.from_unix!(unix, unit)
  end

  ### Jason Integration (Optional) ###

  if Code.ensure_loaded?(Jason) do
    defimpl Jason.Encoder, for: UTCDateTime do
      def encode(datetime, opts) do
        Jason.Encode.string(UTCDateTime.to_rfc3339(datetime), opts)
      end
    end
  end
end
