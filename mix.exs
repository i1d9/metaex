defmodule Metaex.MixProject do
  use Mix.Project

  def project do
    [
      app: :metaex,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description:
        "Metaex is an Elixir library that streamlines interactions with Meta's APIs (Facebook, Instagram, WhatsApp). It simplifies API requests, authentication, and error handling, making it easy to integrate Meta services into your Elixir applications.",
      name: "Metaex",
      source_url: "https://github.com/i1d9/metaex"
    ]
  end

  defp package do
    [
      maintainers: ["Ian Naylan"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/i1d9/metaex"}
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:req, "~> 0.5.0"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end
end
