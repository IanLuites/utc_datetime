defmodule UTCDateTime do
  @moduledoc ~S"""
  A datetime implementation constraint to UTC.
  """

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
  %UTCDateTime{
    day: 24,
    hour: 13,
    microsecond: {3000, 3},
    minute: 26,
    month: 5,
    second: 8,
    year: 2016
  }
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
  Placeholder

  Convert `utc_datetime` to `RFC3339` string format.

  ## Examples

  ```elixir
  iex> UTCDateTime.to_rfc3339(~Z[2019-12-14 08:06:24.289659])
  "2019-12-14 08:06:24.289659"
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
        " ",
        pad2(hour),
        ":",
        pad2(minute),
        ":",
        pad2(second)
      ])
    else
      :erlang.iolist_to_binary([
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
        microsecond(microsecond, precision)
      ])
    end
  end
end
