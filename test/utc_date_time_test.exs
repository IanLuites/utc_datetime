defmodule UTCDateTimeTest do
  use ExUnit.Case, async: true
  use UTCDateTime
  doctest UTCDateTime

  describe "protocols" do
    test "inspect" do
      assert inspect(~Z[2019-12-14 08:06:24.289659]) == "~Z[2019-12-14 08:06:24.289659]"

      # Replace after implementing `truncate/2`.
      timestamp = %{~Z[2019-12-14 08:06:24.289659] | microsecond: {0, 0}}
      assert inspect(timestamp) == "~Z[2019-12-14 08:06:24]"
    end

    test "string" do
      assert to_string(~Z[2019-12-14 08:06:24.289659]) == "2019-12-14T08:06:24.289659Z"

      # Replace after implementing `truncate/2`.
      timestamp = %{~Z[2019-12-14 08:06:24.289659] | microsecond: {0, 0}}
      assert to_string(timestamp) == "2019-12-14T08:06:24Z"
    end
  end

  describe "Ecto" do
    test "embed_as" do
      assert UTCDateTime.embed_as(nil) == :self
      assert UTCDateTime.USec.embed_as(nil) == :self
    end

    test "equal?" do
      a = UTCDateTime.epoch(:unix)
      b = UTCDateTime.epoch(:win)

      assert UTCDateTime.equal?(a, a)
      refute UTCDateTime.equal?(a, b)

      assert UTCDateTime.USec.equal?(a, a)
      refute UTCDateTime.USec.equal?(a, b)
    end

    test "type" do
      assert UTCDateTime.type() == :utc_datetime
      assert UTCDateTime.USec.type() == :utc_datetime_usec
    end

    test "cast" do
      datetime = DateTime.truncate(DateTime.utc_now(), :second)
      utc_datetime = UTCDateTime.from_datetime(datetime)
      naive_datetime = UTCDateTime.to_naive(utc_datetime)

      assert UTCDateTime.cast(utc_datetime) == {:ok, utc_datetime}
      assert UTCDateTime.cast(datetime) == {:ok, utc_datetime}
      assert UTCDateTime.cast(naive_datetime) == {:ok, utc_datetime}
      assert UTCDateTime.cast(to_string(utc_datetime)) == {:ok, utc_datetime}
      assert UTCDateTime.cast(5) == :error
    end

    test "cast (usec)" do
      datetime = DateTime.utc_now()
      utc_datetime = UTCDateTime.from_datetime(datetime)
      naive_datetime = UTCDateTime.to_naive(utc_datetime)

      assert UTCDateTime.USec.cast(utc_datetime) == {:ok, utc_datetime}
      assert UTCDateTime.USec.cast(datetime) == {:ok, utc_datetime}
      assert UTCDateTime.USec.cast(naive_datetime) == {:ok, utc_datetime}
      assert UTCDateTime.USec.cast(to_string(utc_datetime)) == {:ok, utc_datetime}
      assert UTCDateTime.USec.cast(5) == :error
    end

    test "load" do
      datetime = DateTime.truncate(DateTime.utc_now(), :second)
      utc_datetime = UTCDateTime.from_datetime(datetime)

      assert UTCDateTime.load(datetime) == {:ok, utc_datetime}
    end

    test "load (usec)" do
      datetime = DateTime.utc_now()
      utc_datetime = UTCDateTime.from_datetime(datetime)

      assert UTCDateTime.USec.load(datetime) == {:ok, utc_datetime}
    end

    test "dump" do
      datetime = DateTime.truncate(DateTime.utc_now(), :second)
      utc_datetime = UTCDateTime.from_datetime(datetime)

      assert UTCDateTime.dump(utc_datetime) == {:ok, datetime}
      assert UTCDateTime.dump(datetime) == {:ok, datetime}
    end

    test "dump (usec)" do
      datetime = DateTime.utc_now()
      utc_datetime = UTCDateTime.from_datetime(datetime)

      assert UTCDateTime.USec.dump(utc_datetime) == {:ok, datetime}
      assert UTCDateTime.USec.dump(datetime) == {:ok, datetime}
    end
  end

  describe "Jason" do
    test "encode" do
      timestamp = UTCDateTime.utc_now()

      assert Jason.encode!(timestamp) == ~s|"#{timestamp}"|
    end
  end
end
