now_datetime = DateTime.utc_now()
now_naive_datetime = NaiveDateTime.utc_now()
now_utc_datetime = UTCDateTime.utc_now()

Benchee.run(%{
  "DateTime" => fn -> inspect(now_datetime) end,
  "NaiveDateTime" => fn -> inspect(now_naive_datetime) end,
  "UTCDateTime" => fn -> inspect(now_utc_datetime) end
})

Benchee.run(%{
  "DateTime" => fn -> to_string(now_datetime) end,
  "NaiveDateTime" => fn -> to_string(now_naive_datetime) end,
  "UTCDateTime" => fn -> to_string(now_utc_datetime) end
})

Benchee.run(%{
  "DateTime" => fn -> DateTime.to_string(now_datetime) end,
  "NaiveDateTime" => fn -> NaiveDateTime.to_string(now_naive_datetime) end,
  "UTCDateTime" => fn -> UTCDateTime.to_string(now_utc_datetime) end
})
