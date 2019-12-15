now_datetime = DateTime.utc_now()
now_naive_datetime = NaiveDateTime.utc_now()
now_utc_datetime = UTCDateTime.utc_now()

Benchee.run(%{
  "DateTime" => fn -> DateTime.compare(now_datetime, now_datetime) end,
  "NaiveDateTime" => fn -> NaiveDateTime.compare(now_naive_datetime, now_naive_datetime) end,
  "UTCDateTime" => fn -> UTCDateTime.compare(now_utc_datetime, now_utc_datetime) end
})
