defmodule YouTrackMailProxy.MixProject do
  use Mix.Project

  def project do
    [
      app: :smtp_transformer,
      version: "0.0.0",
      deps: [
        config_macro: "~> 0.1.0",
        gen_smtp: "~> 0.12.0",
        secure_compare: "~> 0.1.0"
      ]
    ]
  end
end
