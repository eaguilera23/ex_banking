defmodule ExBanking.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_banking,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      name: "ExBanking",
      source_url: "https://github.com/lalo2302/ex_banking",
      docs: [main: "ExBanking"]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :eternal],
      mod: {ExBanking.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:moneyex, "~> 0.1.1"},
      {:excoveralls, "~> 0.8", only: :test},
      {:gen_stage, "~> 0.12"},
      {:eternal, "~> 1.2"},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false}
    ]
  end
end
