now_datetime = DateTime.utc_now()
now_naive_datetime = NaiveDateTime.utc_now()
now_utc_datetime = UTCDateTime.utc_now()

# To Naive and back
Benchee.run(
  %{
    "DateTime" => &DateTime.from_naive(&1, "Etc/UTC"),
    "UTCDateTime" => &UTCDateTime.from_naive/1
  },
  inputs: %{
    "Now" => NaiveDateTime.utc_now(),
    "Unix Epoch" => ~N[1970-01-01 00:00:00Z],
    "Random" => ~N[0716-03-26 13:41:49Z]
  }
)

Benchee.run(%{
  "DateTime" => fn -> DateTime.to_naive(now_datetime) end,
  "UTCDateTime" => fn -> UTCDateTime.to_naive(now_utc_datetime) end
})

# To DateTime and back
Benchee.run(
  %{
    "NaiveDateTime" => &DateTime.to_naive(&1),
    "UTCDateTime" => &UTCDateTime.from_datetime/1
  },
  inputs: %{
    "Now" => DateTime.utc_now(),
    "Unix Epoch" => ~U[1970-01-01 00:00:00Z],
    "Random" => ~U[0716-03-26 13:41:49Z]
  }
)

Benchee.run(%{
  "DateTime" => fn -> DateTime.from_naive(now_naive_datetime, "Etc/UTC") end,
  "UTCDateTime" => fn -> UTCDateTime.to_datetime(now_utc_datetime) end
})

# Converting NaiveDateTime <=> DateTime or using UTCDateTime inbetween
Benchee.run(
  %{
    "NaiveDateTime => DateTime" => &DateTime.from_naive(&1, "Etc/UTC"),
    "NaiveDateTime => UTCDateTime => DateTime" =>
      &UTCDateTime.to_datetime(UTCDateTime.from_naive(&1))
  },
  inputs: %{
    "Now" => NaiveDateTime.utc_now(),
    "Unix Epoch" => ~N[1970-01-01 00:00:00Z],
    "Random" => ~N[0716-03-26 13:41:49Z]
  }
)
