defmodule UTCDateTime.MixProject do
  use Mix.Project

  @version "0.0.6"

  def project do
    [
      app: :utc_datetime,
      description: "A datetime implementation constraint to UTC.",
      version: @version,
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),

      # Testing
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      dialyzer: [ignore_warnings: ".dialyzer", plt_add_deps: true],

      # Docs
      name: "UTC DateTime",
      source_url: "https://github.com/IanLuites/utc_datetime",
      homepage_url: "https://github.com/IanLuites/utc_datetime",
      docs: [
        main: "readme",
        extras: ["README.md"],
        source_ref: "v#{@version}",
        source_url: "https://github.com/IanLuites/utc_datetime"
      ]
    ]
  end

  def package do
    [
      name: :utc_datetime,
      maintainers: ["Ian Luites"],
      licenses: ["MIT"],
      files: [
        # Elixir
        "lib/utc_datetime",
        "lib/utc_datetime.ex",
        ".formatter.exs",
        "mix.exs",
        "README*",
        "LICENSE*"
      ],
      links: %{
        "GitHub" => "https://github.com/IanLuites/utc_datetime"
      }
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:analyze, "~> 0.1.10", only: [:dev, :test], runtime: false, optional: true},
      {:benchee, "~> 1.0", only: :dev, optional: true},
      {:dialyxir, "~> 1.0.0-rc.7 ", only: :dev, runtime: false, optional: true},

      # Optional Integrations
      {:ecto, ">= 3.0.0", optional: true},
      {:jason, ">= 1.0.0", optional: true}
    ]
  end
end
