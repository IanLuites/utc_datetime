defmodule UTCDateTime.ISO do
  @moduledoc false

  # credo:disable-for-this-file

  # Copied from Elixir 1.9, since no longer in 1.10
  # Might need to look for them in a different spot.

  @doc false
  @spec __match_date__ :: [term]
  def __match_date__ do
    quote do
      [
        <<y1, y2, y3, y4, ?-, m1, m2, ?-, d1, d2>>,
        y1 >= ?0 and y1 <= ?9 and y2 >= ?0 and y2 <= ?9 and y3 >= ?0 and y3 <= ?9 and y4 >= ?0 and
          y4 <= ?9 and m1 >= ?0 and m1 <= ?9 and m2 >= ?0 and m2 <= ?9 and d1 >= ?0 and d1 <= ?9 and
          d2 >= ?0 and d2 <= ?9,
        {
          (y1 - ?0) * 1000 + (y2 - ?0) * 100 + (y3 - ?0) * 10 + (y4 - ?0),
          (m1 - ?0) * 10 + (m2 - ?0),
          (d1 - ?0) * 10 + (d2 - ?0)
        }
      ]
    end
  end

  @doc false
  @spec __match_time__ :: [term]
  def __match_time__ do
    quote do
      [
        <<h1, h2, ?:, i1, i2, ?:, s1, s2>>,
        h1 >= ?0 and h1 <= ?9 and h2 >= ?0 and h2 <= ?9 and i1 >= ?0 and i1 <= ?9 and i2 >= ?0 and
          i2 <= ?9 and s1 >= ?0 and s1 <= ?9 and s2 >= ?0 and s2 <= ?9,
        {
          (h1 - ?0) * 10 + (h2 - ?0),
          (i1 - ?0) * 10 + (i2 - ?0),
          (s1 - ?0) * 10 + (s2 - ?0)
        }
      ]
    end
  end

  @doc false
  @spec parse_microsecond(String.t()) :: {{integer, integer}, String.t()} | :error
  def parse_microsecond("." <> rest) do
    case parse_microsecond(rest, 0, "") do
      {"", 0, _} ->
        :error

      {microsecond, precision, rest} when precision in 1..6 ->
        pad = String.duplicate("0", 6 - byte_size(microsecond))
        {{String.to_integer(microsecond <> pad), precision}, rest}

      {microsecond, _precision, rest} ->
        {{String.to_integer(binary_part(microsecond, 0, 6)), 6}, rest}
    end
  end

  def parse_microsecond("," <> rest) do
    parse_microsecond("." <> rest)
  end

  def parse_microsecond(rest) do
    {{0, 0}, rest}
  end

  defp parse_microsecond(<<head, tail::binary>>, precision, acc) when head in ?0..?9,
    do: parse_microsecond(tail, precision + 1, <<acc::binary, head>>)

  defp parse_microsecond(rest, precision, acc), do: {acc, precision, rest}

  @doc false
  @spec parse_offset(String.t()) :: {integer | nil, String.t()} | :error
  def parse_offset(""), do: {nil, ""}
  def parse_offset("Z"), do: {0, ""}
  def parse_offset("-00:00"), do: :error

  def parse_offset(<<?+, hour::2-bytes, ?:, min::2-bytes, rest::binary>>),
    do: parse_offset(1, hour, min, rest)

  def parse_offset(<<?-, hour::2-bytes, ?:, min::2-bytes, rest::binary>>),
    do: parse_offset(-1, hour, min, rest)

  def parse_offset(<<?+, hour::2-bytes, min::2-bytes, rest::binary>>),
    do: parse_offset(1, hour, min, rest)

  def parse_offset(<<?-, hour::2-bytes, min::2-bytes, rest::binary>>),
    do: parse_offset(-1, hour, min, rest)

  def parse_offset(<<?+, hour::2-bytes, rest::binary>>), do: parse_offset(1, hour, "00", rest)
  def parse_offset(<<?-, hour::2-bytes, rest::binary>>), do: parse_offset(-1, hour, "00", rest)
  def parse_offset(_), do: :error

  defp parse_offset(sign, hour, min, rest) do
    with {hour, ""} when hour < 24 <- Integer.parse(hour),
         {min, ""} when min < 60 <- Integer.parse(min) do
      {(hour * 60 + min) * 60 * sign, rest}
    else
      _ -> :error
    end
  end
end
