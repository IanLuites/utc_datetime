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
  [match_date, guard_date, read_date] = Calendar.ISO.__match_date__()
  [match_time, guard_time, read_time] = Calendar.ISO.__match_time__()

  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
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

  ### ISO 8601 ###

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

  @sep_iso8601 [?T, ?\s, ?t]

  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  def from_iso8601(string) do
    with <<unquote(match_date), sep, unquote(match_time), rest::binary>> <- string,
         true <- unquote(guard_date) and sep in @sep_iso8601 and unquote(guard_time),
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
  def from_erl({{year, month, day}, {hour, minute, second}}, {us, p} = microsecond) do
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

  ### Ecto Integration (Optional) ###

  if Code.ensure_loaded?(Ecto.Type) do
    use Ecto.Type

    @impl Ecto.Type
    @spec embed_as(term) :: :self
    def embed_as(_), do: :self

    @impl Ecto.Type
    @spec equal?(t, t) :: boolean
    def equal?(term1, term2), do: term1 == term2

    @impl Ecto.Type
    @spec type :: :utc_datetime
    def type, do: :utc_datetime

    @impl Ecto.Type
    @spec cast(term) :: {:ok, t} | :error
    def cast(%__MODULE__{} = datetime), do: {:ok, datetime}
    def cast(%DateTime{} = datetime), do: {:ok, from_datetime(datetime)}
    def cast(%NaiveDateTime{} = datetime), do: {:ok, from_naive(datetime)}
    def cast(datetime) when is_binary(datetime), do: from_iso8601(datetime)
    def cast(_), do: :error

    @impl Ecto.Type
    @spec load(term) :: {:ok, t} | :error
    def load(data), do: {:ok, from_datetime(data)}

    @impl Ecto.Type
    @spec dump(t) :: {:ok, DateTime.t()} | :error
    def dump(%__MODULE__{} = datetime), do: {:ok, to_datetime(datetime)}
    def dump(_), do: :error
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
