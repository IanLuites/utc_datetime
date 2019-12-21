now_datetime = DateTime.utc_now()
now_naive_datetime = NaiveDateTime.utc_now()
now_utc_datetime = UTCDateTime.utc_now()

Benchee.run(%{
  "DateTime" => fn -> DateTime.to_unix(now_datetime) end,
  "NaiveDateTime" => fn -> NaiveDateTime.diff(now_naive_datetime, ~N[1970-01-01 00:00:00]) end,
  "UTCDateTime" => fn -> UTCDateTime.to_unix(now_utc_datetime) end
})

Benchee.run(%{
  "DateTime" => fn -> DateTime.from_unix!(1_464_096_368) end,
  "NaiveDateTime" => fn -> NaiveDateTime.add(~N[1970-01-01 00:00:00], 1_464_096_368) end,
  "UTCDateTime" => fn -> UTCDateTime.from_unix!(1_464_096_368) end
})
