defmodule Padding.Alternatives do
  def pad2_string(val) do
    String.pad_leading("#{val}", 2, ["0"])
  end

  def pad2_binary(val) do
    num = Integer.to_string(val)
    :binary.copy("0", max(2 - byte_size(num), 0)) <> num
  end

  def pad4_string(val) do
    String.pad_leading("#{val}", 2, ["0"])
  end

  def pad4_binary(val) do
    num = Integer.to_string(val)
    :binary.copy("0", max(4 - byte_size(num), 0)) <> num
  end
end

Benchee.run(
  %{
    "binary" => &Padding.Alternatives.pad2_binary/1,
    "string" => &Padding.Alternatives.pad2_string/1,
    "pad2/1" => &UTCDateTime.Utility.pad2/1
  },
  inputs: %{
    "0" => 0,
    "8" => 8,
    "64" => 64,
    "264" => 264
  }
)

Benchee.run(
  %{
    "binary" => &Padding.Alternatives.pad4_binary/1,
    "string" => &Padding.Alternatives.pad4_string/1,
    "pad2/1" => &UTCDateTime.Utility.pad4/1
  },
  inputs: %{
    "0" => 0,
    "8" => 8,
    "64" => 64,
    "582" => 582,
    "8734" => 8734,
    "38734" => 38734
  }
)
