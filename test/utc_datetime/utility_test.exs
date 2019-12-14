defmodule UTCDateTime.UtilityTest do
  use ExUnit.Case, async: true
  import UTCDateTime.Utility

  test "pad2/1" do
    assert String.length(pad2(Enum.random(0..9))) == 2
    assert String.length(pad2(Enum.random(10..99))) == 2
  end

  test "pad3/1" do
    assert String.length(pad3(Enum.random(0..9))) == 3
    assert String.length(pad3(Enum.random(10..99))) == 3
    assert String.length(pad3(Enum.random(100..999))) == 3
  end

  test "pad4/1" do
    assert String.length(pad4(Enum.random(0..9))) == 4
    assert String.length(pad4(Enum.random(10..99))) == 4
    assert String.length(pad4(Enum.random(100..999))) == 4
    assert String.length(pad4(Enum.random(1_000..9_999))) == 4
  end

  test "pad5/1" do
    assert String.length(pad5(Enum.random(0..9))) == 5
    assert String.length(pad5(Enum.random(10..99))) == 5
    assert String.length(pad5(Enum.random(100..999))) == 5
    assert String.length(pad5(Enum.random(1_000..9_999))) == 5
    assert String.length(pad5(Enum.random(10_000..99_999))) == 5
  end

  test "pad6_us/1" do
    # Lengths 7 (+1) because of the included "."
    assert String.length(pad6_us(Enum.random(0..9))) == 7
    assert String.length(pad6_us(Enum.random(10..99))) == 7
    assert String.length(pad6_us(Enum.random(100..999))) == 7
    assert String.length(pad6_us(Enum.random(1_000..9_999))) == 7
    assert String.length(pad6_us(Enum.random(10_000..99_999))) == 7
    assert String.length(pad6_us(Enum.random(100_000..999_999))) == 7
  end

  describe "microsecond/2" do
    # Lengths +1 because of the included "."
    Enum.each(1..6, fn p ->
      test "precision: #{p}" do
        p = unquote(p)
        assert String.length(microsecond(Enum.random(0..9), p)) == p + 1
        assert String.length(microsecond(Enum.random(10..99), p)) == p + 1
        assert String.length(microsecond(Enum.random(100..999), p)) == p + 1
        assert String.length(microsecond(Enum.random(1_000..9_999), p)) == p + 1
        assert String.length(microsecond(Enum.random(10_000..99_999), p)) == p + 1
        assert String.length(microsecond(Enum.random(100_000..999_999), p)) == p + 1
      end
    end)
  end
end
