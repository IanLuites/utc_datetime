defmodule UTCDateTime.Epochs do
  @moduledoc false
  use UTCDateTime

  @go ~Z[0001-01-01 00:00:00]
  @uuid ~Z[1582-10-15 00:00:00]
  @win ~Z[1601-01-01 00:00:00]
  @mumps ~Z[1840-12-31 00:00:00]
  @vms ~Z[1858-11-17 00:00:00]
  @ms_com ~Z[1899-12-30 00:00:00]
  @dyalog ~Z[1899-12-31 00:00:00]
  @ms_excel ~Z[1900-01-00 00:00:00]
  @posix ~Z[1970-01-01 00:00:00]

  @epochs %{
    go: @go,
    dotnet: @go,
    rexx: @go,
    rata_die: @go,
    uuid: @uuid,
    win: @win,
    win_nt: @win,
    win32: @win,
    win64: @win,
    cobol: @win,
    ntfs: @win,
    mumps: @mumps,
    vms: @vms,
    usno: @vms,
    dvb: @vms,
    mjd: @vms,
    ms_com: @ms_com,
    pascal: @ms_com,
    libre_office_calc: @ms_com,
    google_sheets: @ms_com,
    dyalog_alp: @dyalog,
    ms_c: @dyalog,
    ms_excel: @ms_excel,
    lotus: @ms_excel,
    posix: @posix,
    unix: @posix
  }

  @doc false
  @spec epoch(epoch :: atom) :: UTCDateTime.t() | no_return
  def epoch(epoch)

  Enum.each(@epochs, fn {epoch, value} ->
    def epoch(unquote(epoch)), do: unquote(Macro.escape(value))
  end)
end
