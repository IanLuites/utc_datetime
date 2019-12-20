now_datetime = DateTime.utc_now()
now_naive_datetime = NaiveDateTime.utc_now()
now_utc_datetime = UTCDateTime.utc_now()

Benchee.run(
  %{
    "DateTime" => fn {amount, unit} -> DateTime.add(now_datetime, amount, unit) end,
    "NaiveDateTime" => fn {amount, unit} ->
      NaiveDateTime.add(now_naive_datetime, amount, unit)
    end,
    "UTCDateTime" => fn {amount, unit} -> UTCDateTime.add(now_utc_datetime, amount, unit) end
  },
  inputs: %{
    "nanosecond" => {8392, :nanosecond},
    "millisecond" => {8392, :millisecond},
    "seconds" => {8392, :second}
  }
)
