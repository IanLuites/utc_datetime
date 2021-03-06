defmodule UTCDateTime.EctoTyper do
  @moduledoc false

  @doc false
  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  defmacro type(base) do
    if Code.ensure_loaded?(Ecto.Type) do
      quote do
        @behaviour Ecto.Type

        @impl Ecto.Type
        @spec embed_as(term) :: :self
        def embed_as(_), do: :self

        @impl Ecto.Type
        @spec equal?(UTCDateTime.t(), UTCDateTime.t()) :: boolean
        def equal?(term1, term2), do: term1 == term2

        @impl Ecto.Type
        @spec type :: atom
        def type, do: unquote(base)

        @impl Ecto.Type
        @spec cast(term) :: {:ok, UTCDateTime.t()} | :error
        def cast(datetime = %UTCDateTime{}), do: {:ok, datetime}
        def cast(datetime = %DateTime{}), do: {:ok, UTCDateTime.from_datetime(datetime)}
        def cast(datetime = %NaiveDateTime{}), do: {:ok, UTCDateTime.from_naive(datetime)}
        def cast(datetime) when is_binary(datetime), do: UTCDateTime.from_iso8601(datetime)
        def cast(_), do: :error

        @impl Ecto.Type
        @spec load(term) :: {:ok, UTCDateTime.t()} | :error
        def load(data), do: cast(data)

        @impl Ecto.Type
        @spec dump(UTCDateTime.t()) :: {:ok, DateTime.t()} | :error
        def dump(datetime = %UTCDateTime{}), do: {:ok, UTCDateTime.to_datetime(datetime)}
        def dump(datetime = %DateTime{}), do: {:ok, datetime}
        def dump(_), do: :error
      end
    end
  end
end
