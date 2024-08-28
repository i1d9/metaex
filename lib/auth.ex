defmodule Metaex.Auth do
  @moduledoc """
  Documentation for `Metaex.Auth`.
  """

  def config() do
    Application.get_env(:metaex, __MODULE__)
  end

  def config_id(), do: config() |> Keyword.get(:config_id)

  def api_version(), do: config() |> Keyword.get(:api_version)

  def authorization_endpoint(), do: config() |> Keyword.get(:authorization_endpoint)

  def access_token_endpoint(), do: config() |> Keyword.get(:access_token_endpoint)

  def app_id(), do: config() |> Keyword.get(:app_id)

  def app_secret(), do: config() |> Keyword.get(:app_secret)

  def authorization_url(redirect_uri, state) do
    authorization_endpoint()
    |> URI.merge("/#{api_version()}/dialog/oauth")
    |> Map.put(
      :query,
      URI.encode_query(%{
        client_id: app_id(),
        redirect_uri: redirect_uri,
        state: state,
        config_id: config_id()
      })
    )
    |> to_string
  end

  def access_token_url(redirect_uri, code) do
    access_token_endpoint()
    |> URI.merge("/#{api_version()}/oauth/access_token")
    |> Map.put(
      :query,
      URI.encode_query(%{
        client_id: app_id(),
        client_secret: app_secret(),
        code: code,
        redirect_uri: redirect_uri,
        config_id: config_id()
      })
    )
    |> to_string
  end

  def long_lived_access_token_url(short_lived_access_token) do
    access_token_endpoint()
    |> URI.merge("/#{api_version()}/oauth/access_token")
    |> Map.put(
      :query,
      URI.encode_query(%{
        client_id: app_id(),
        client_secret: app_secret(),
        grant_type: :fb_exchange_token,
        fb_exchange_token: short_lived_access_token
      })
    )
    |> to_string
  end

  @doc """
  Hello world.

  ## Examples

      iex> Metaex.hello()
      :world

  """
  def long_lived_access_token(short_lived_access_token) do
    with {:ok, %Req.Response{body: body}} <-
           Req.post(long_lived_access_token_url(short_lived_access_token)),
         %{"access_token" => _access_token, "token_type" => _} = _ <- body do
      {:ok, body}
    else
      %{
        "error" => _error,
        "error_description" => _error_description,
        "error_reason" => _error_reason
      } = error ->
        {:oauth_error, error}

      error ->
        {:error, error}
    end
  end

  def access_token(redirect_uri, code) do
    with {:ok, %Req.Response{body: body}} <-
           Req.post(access_token_url(redirect_uri, code)),
         %{"access_token" => _access_token, "token_type" => _} = _ <- body do
      {:ok, body}
    else
      %{
        "error" => _error,
        "error_description" => _error_description,
        "error_reason" => _error_reason
      } = error ->
        {:oauth_error, error}

      error ->
        {:error, error}
    end
  end
end
