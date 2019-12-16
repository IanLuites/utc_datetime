datetime = DateTime.truncate(DateTime.utc_now(), :second)
utc_datetime = UTCDateTime.from_datetime(datetime)
naive_datetime = UTCDateTime.to_naive(utc_datetime)

Benchee.run(%{
  "DateTime" => fn -> Ecto.Type.dump(:utc_datetime, datetime) end,
  "NaiveDateTime" => fn -> Ecto.Type.dump(:naive_datetime, naive_datetime) end,
  "UTCDateTime" => fn -> UTCDateTime.dump(utc_datetime) end
})

Benchee.run(%{
  "DateTime" => fn -> Ecto.Type.cast(:utc_datetime, "2019-12-14T08:06:24Z") end,
  "NaiveDateTime" => fn -> Ecto.Type.cast(:naive_datetime, "2019-12-14T08:06:24Z") end,
  "UTCDateTime" => fn -> UTCDateTime.cast("2019-12-14T08:06:24Z") end
})
