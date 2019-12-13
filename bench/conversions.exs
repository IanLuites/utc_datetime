Benchee.run(
  %{
    "DateTime" => &DateTime.from_naive(&1, "Etc/UTC"),
    "UTCDateTime" => &UTCDateTime.from_naive/1
  },
  inputs: %{
    "Now" => NaiveDateTime.utc_now(),
    "Unix Epoch" => NaiveDateTime.utc_now(),
    "Random" => ~N[0716-03-26 13:41:49Z]
  }
)

now_datetime = DateTime.utc_now()
now_utc_datetime = UTCDateTime.utc_now()

Benchee.run(%{
  "DateTime" => fn -> DateTime.to_naive(now_datetime) end,
  "UTCDateTime" => fn -> UTCDateTime.to_naive(now_utc_datetime) end
})
