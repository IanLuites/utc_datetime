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
end
