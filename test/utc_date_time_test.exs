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
  end
end
