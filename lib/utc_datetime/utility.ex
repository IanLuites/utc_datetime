defmodule UTCDateTime.Utility do
  @moduledoc false

  @doc false
  @spec pad2(non_neg_integer) :: String.t()
  def pad2(val) when val < 10, do: "0#{val}"
  def pad2(val), do: to_string(val)

  @doc false
  @spec pad3(non_neg_integer) :: String.t()
  def pad3(val) when val < 10, do: "00#{val}"
  def pad3(val) when val < 100, do: "0#{val}"
  def pad3(val), do: to_string(val)

  @doc false
  @spec pad4(non_neg_integer) :: String.t()
  def pad4(val) when val < 10, do: "000#{val}"
  def pad4(val) when val < 100, do: "00#{val}"
  def pad4(val) when val < 1_000, do: "0#{val}"
  def pad4(val), do: to_string(val)

  @doc false
  @spec pad5(non_neg_integer) :: String.t()
  def pad5(val) when val < 10, do: "0000#{val}"
  def pad5(val) when val < 100, do: "000#{val}"
  def pad5(val) when val < 1_000, do: "00#{val}"
  def pad5(val) when val < 10_000, do: "0#{val}"
  def pad5(val), do: to_string(val)

  @doc false
  @spec pad6_us(non_neg_integer) :: String.t()
  def pad6_us(val) when val < 10, do: ".00000#{val}"
  def pad6_us(val) when val < 100, do: ".0000#{val}"
  def pad6_us(val) when val < 1_000, do: ".000#{val}"
  def pad6_us(val) when val < 10_000, do: ".00#{val}"
  def pad6_us(val) when val < 100_000, do: ".0#{val}"
  def pad6_us(val), do: "." <> to_string(val)

  @doc false
  @spec microsecond(non_neg_integer, pos_integer) :: String.t()
  def microsecond(us, precision)
  def microsecond(us, 1), do: "." <> binary_part(to_string(us), 0, 1)
  def microsecond(us, 2), do: "." <> binary_part(pad2(us), 0, 2)
  def microsecond(us, 3), do: "." <> binary_part(pad3(us), 0, 3)
  def microsecond(us, 4), do: "." <> binary_part(pad4(us), 0, 4)
  def microsecond(us, 5), do: "." <> binary_part(pad5(us), 0, 5)
  def microsecond(us, 6), do: pad6_us(us)
end
