now_datetime = DateTime.utc_now()
now_naive_datetime = NaiveDateTime.utc_now()
now_utc_datetime = UTCDateTime.utc_now()

Benchee.run(%{
  "DateTime" => fn -> inspect(now_datetime) end,
  "NaiveDateTime" => fn -> inspect(now_naive_datetime) end,
  "UTCDateTime" => fn -> inspect(now_utc_datetime) end
})
