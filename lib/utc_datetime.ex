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

  ## Examples

  iex> dt = %UTCDateTime{year: 2016, month: 5, day: 24,
  ...>                   hour: 13, minute: 26, second: 8,
  ...>                   microsecond: {3000, 3}}
  iex> UTCDateTime.to_naive(dt)
  ~N[2016-05-24 13:26:08.003]
  """
  @spec to_naive(NaiveDateTime.t(), Calendar.calendar()) :: t
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

  It expects the `NaiveDateTime` to be in the "Etc/UTC" time zone.

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
end
