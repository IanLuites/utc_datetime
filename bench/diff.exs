use UTCDateTime

Benchee.run(
  %{
    "DateTime" => fn unit ->
      DateTime.diff(~U[2014-10-02 00:29:12Z], ~U[2014-10-02 00:29:10Z], unit)
    end,
    "NaiveDateTime" => fn unit ->
      NaiveDateTime.diff(~N[2014-10-02 00:29:12], ~N[2014-10-02 00:29:10], unit)
    end,
    "UTCDateTime" => fn unit ->
      UTCDateTime.diff(~Z[2014-10-02 00:29:12], ~Z[2014-10-02 00:29:10], unit)
    end
  },
  inputs: %{
    "nanoseconds" => :nanosecond,
    "milliseconds" => :millisecond,
    "seconds" => :second
  }
)
