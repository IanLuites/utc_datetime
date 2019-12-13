Benchee.run(%{
  "DateTime" => &DateTime.utc_now/0,
  "NaiveDateTime" => &NaiveDateTime.utc_now/0,
  "UTCDateTime" => &UTCDateTime.utc_now/0
})
