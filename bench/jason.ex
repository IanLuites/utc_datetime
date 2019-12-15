datetime = DateTime.truncate(DateTime.utc_now(), :second)
utc_datetime = UTCDateTime.from_datetime(datetime)
naive_datetime = UTCDateTime.to_naive(utc_datetime)

Benchee.run(%{
  "DateTime" => fn -> Jason.encode(datetime) end,
  "NaiveDateTime" => fn -> Jason.encode(naive_datetime) end,
  "UTCDateTime" => fn -> Jason.encode(utc_datetime) end
})
