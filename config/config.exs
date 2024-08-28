import Config

config :metaex, Metaex.Auth,
  config_id: "",
  api_version: "",
  authorization_endpoint: "",
  access_token_endpoint: "",
  app_id: "",
  app_secret: ""

import_config "#{config_env()}.exs"
