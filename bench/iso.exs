datetime = DateTime.utc_now()
utc_datetime = UTCDateTime.from_datetime(datetime)
naive_datetime = UTCDateTime.to_naive(utc_datetime)

Benchee.run(
  %{
    "DateTime" => &DateTime.from_iso8601/1,
    "NaiveDateTime" => &NaiveDateTime.from_iso8601/1,
    "UTCDateTime" => &UTCDateTime.from_rfc3339/1
  },
  inputs: %{
    "2019-01-01t23:00:01" => "2019-01-01T23:00:01",
    "2019-01-01t23:00:01-07:00" => "2019-01-01T23:00:01-07:00"
  }
)

Benchee.run(%{
  "DateTime" => fn -> DateTime.to_iso8601(datetime) end,
  "NaiveDateTime" => fn -> NaiveDateTime.to_iso8601(naive_datetime) end,
  "UTCDateTime" => fn -> UTCDateTime.to_rfc3339(utc_datetime) end
})

Benchee.run(
  %{
    "DateTime" => &DateTime.from_iso8601/1,
    "NaiveDateTime" => &NaiveDateTime.from_iso8601/1,
    "UTCDateTime" => &UTCDateTime.from_iso8601/1
  },
  inputs: %{
    "2019-01-01t23:00:01" => "2019-01-01T23:00:01",
    "2019-01-01t23:00:01-07:00" => "2019-01-01T23:00:01-07:00"
  }
)

Benchee.run(%{
  "DateTime" => fn -> DateTime.to_iso8601(datetime) end,
  "NaiveDateTime" => fn -> NaiveDateTime.to_iso8601(naive_datetime) end,
  "UTCDateTime" => fn -> UTCDateTime.to_iso8601(utc_datetime) end
})
