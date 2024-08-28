defmodule Metaex.Facebook do
  import Metaex.Auth

  def current_profile_url(access_token, fields \\ "id,name"),
    do:
      access_token_endpoint()
      |> URI.merge("/#{api_version()}/me")
      |> Map.put(
        :query,
        URI.encode_query(%{
          access_token: access_token,
          fields: fields
        })
      )
      |> to_string

  def pages_url(
        access_token,
        fields \\ "bio,description,followers_count,id,link,name,picture,connected_instagram_account"
      ),
      do:
        access_token_endpoint()
        |> URI.merge("/#{api_version()}/me/accounts")
        |> Map.put(
          :query,
          URI.encode_query(%{
            access_token: access_token,
            fields: fields
          })
        )
        |> to_string

  def page_posts_url(%{access_token: access_token, page_id: page_id} = params),
    do:
      access_token_endpoint()
      |> URI.merge("/#{api_version()}/#{page_id}/feed")
      |> Map.put(
        :query,
        URI.encode_query(%{
          fields:
            "attachments{media,media_type,title,url},id,created_time,properties,is_expired,is_hidden,is_popular,is_published,message,permalink_url,shares,updated_time,full_picture",
          access_token: access_token,
          after: Map.get(params, :after),
          before: Map.get(params, :before)
        })
      )
      |> to_string

  def page_posts_url(%{access_token: access_token, page_id: page_id, next: next}),
    do:
      access_token_endpoint()
      |> URI.merge("/#{api_version()}/#{page_id}/feed")
      |> Map.put(
        :query,
        URI.encode_query(%{
          access_token: access_token,
          after: next
        })
      )
      |> to_string

  def post_details_url(%{access_token: access_token, post_id: post_id}),
    do:
      access_token_endpoint()
      |> URI.merge("/#{api_version()}/#{post_id}")
      |> Map.put(
        :query,
        URI.encode_query(%{
          access_token: access_token,
          fields:
            "id,created_time,properties,is_expired,is_hidden,is_popular,is_published,message,permalink_url,shares,updated_time,full_picture"
        })
      )
      |> to_string

  def post_insights_url(
        access_token,
        post_id,
        metric \\ "post_engaged_users,post_impressions,post_reactions_like_total"
      ),
      do:
        access_token_endpoint()
        |> URI.merge("/#{api_version()}/#{post_id}/insights")
        |> Map.put(
          :query,
          URI.encode_query(%{
            access_token: access_token,
            metric: metric
          })
        )
        |> to_string

  def page_insights_url(
        access_token,
        post_id,
        period \\ "days_28",
        metric \\ "page_post_engagements,page_consumptions_unique, page_negative_feedback"
      ),
      do:
        access_token_endpoint()
        |> URI.merge("/#{api_version()}/#{post_id}/insights")
        |> Map.put(
          :query,
          URI.encode_query(%{
            access_token: access_token,
            period: period,
            metric: metric
          })
        )
        |> to_string

  def pages( access_token) do
    with {:ok, %Req.Response{body: body}} <-
           Req.get(pages_url(access_token)) do
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

  def current_profile( access_token) do
    with {:ok, %Req.Response{body: response}} <-
           Req.get(current_profile_url(access_token)),
         %{"id" => _id} = _ <- response do
      {:ok, response}
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

  def page_insights(access_token, post_id) do
    with {:ok, %Req.Response{body: response}} <-
           Req.get(
             page_insights_url(
               access_token,
               post_id
             )
           ),
         %{
           "data" => data,
           "paging" => %{"next" => _next, "previous" => _previous}
         } <- response do
      {:ok,
       Enum.reduce(data, %{}, fn %{"name" => name, "values" => [%{"value" => value} | _]}, acc ->
         Map.put(acc, name, value)
       end)}
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

  def post_insights(access_token, post_id) do
    with {:ok, %Req.Response{body: response}} <-
           Req.get(
             post_insights_url(
               access_token,
               post_id
             )
           ),
         %{
           "data" => data,
           "paging" => %{"next" => _next, "previous" => _previous}
         } <- response do
      {:ok,
       Enum.reduce(data, %{}, fn %{"name" => name, "values" => [%{"value" => value}]}, acc ->
         Map.put(acc, name, value)
       end)}
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

  def post_details(access_token, post_id) do
    with {:ok, %Req.Response{body: response}} <-
           Req.get(
             post_details_url(%{
               access_token: access_token,
               post_id: post_id
             })
           ) do
      {:ok, response}
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

  def page_posts(%{access_token: access_token, page_id: page_id} = params) do
    url =
      page_posts_url(%{
        access_token: access_token,
        page_id: page_id,
        after: Map.get(params, :after),
        before: Map.get(params, :before)
      })

    with {:ok, %Req.Response{body: body}} <-
           Req.get(url),
         {:ok, response} <- Jason.decode(body) do
      {:ok, cursor_based_pagination(response, params)}
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

  def cursor_based_pagination(
        %{
          "data" => []
        },
        _
      ),
      do: []

  def cursor_based_pagination(
        %{
          "data" => data,
          "paging" => %{"cursors" => %{"after" => next, "before" => _}}
        },
        params
      ) do
    case page_posts(Map.merge(params, %{after: next})) do
      {:ok, second_call} ->
        Enum.concat(data, second_call)

      _ ->
        Enum.concat(data, [])
    end
  end
end
