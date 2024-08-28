defmodule Metaex.Instagram do
  import Metaex.Auth

  def user_info_url(access_token, ig_user_id),
    do:
      access_token_endpoint()
      |> URI.merge("/#{api_version()}/#{ig_user_id}")
      |> Map.put(
        :query,
        URI.encode_query(%{
          access_token: access_token,
          fields:
            "biography,ig_id,followers_count,follows_count,media_count,name,profile_picture_url,username,website"
        })
      )
      |> to_string

  def user_insights_url(
        access_token,
        ig_user_id,
        metric \\ "reach,impressions",
        period \\ "days_28"
      ),
      do:
        access_token_endpoint()
        |> URI.merge("/#{api_version()}/#{ig_user_id}/insights")
        |> Map.put(
          :query,
          URI.encode_query(%{
            access_token: access_token,
            metric: metric,
            period: period
          })
        )
        |> to_string

  def ig_user_tags_url(
        access_token,
        ig_user_id
      ),
      do:
        access_token_endpoint()
        |> URI.merge("/#{api_version()}/#{ig_user_id}/tags")
        |> Map.put(
          :query,
          URI.encode_query(%{
            access_token: access_token,
            fields:
              "id,username,thumbnail_url,media_url,media_type,media_product_type,like_count,ig_id,comments_count,caption"
          })
        )
        |> to_string

  def business_info_url(access_token, page_id),
    do:
      access_token_endpoint()
      |> URI.merge("/#{api_version()}/#{page_id}")
      |> Map.put(
        :query,
        URI.encode_query(%{
          access_token: access_token,
          fields:
            "instagram_business_account,link,name,username,website,general_info,followers_count,description,cover,category,id"
        })
      )
      |> to_string

  @doc """
  Returns a list of Media IDs
  """
  def ig_stories_url(access_token, ig_user_id),
    do:
      access_token_endpoint()
      |> URI.merge("/#{api_version()}/#{ig_user_id}/stories")
      |> Map.put(
        :query,
        URI.encode_query(%{
          access_token: access_token
        })
      )
      |> to_string()

  def search_ig_user_url(access_token, ig_user_id, ig_username),
    do:
      access_token_endpoint()
      |> URI.merge("/#{api_version()}/#{ig_user_id}")
      |> Map.put(
        :query,
        URI.encode_query(%{
          access_token: access_token,
          fields:
            "business_discovery.username(#{ig_username}){biography,public,ig_id,followers_count,follows_count,media_count,name,profile_picture_url,username,website}}"
        })
      )
      |> to_string()

  def feed_url(
        %{access_token: access_token, instagram_page_id: instagram_page_id} = params
      ),
      do:
        access_token_endpoint()
        |> URI.merge("/#{api_version()}/#{instagram_page_id}/media")
        |> Map.put(
          :query,
          URI.encode_query(%{
            access_token: access_token,
            fields:
              "is_comment_enabled,ig_id,permalink,shortcode,timestamp,thumbnail_url,username,caption,like_count",
            after: Map.get(params, :after),
            before: Map.get(params, :before)
          })
        )
        |> to_string()

  def media_object_url(access_token, instagram_media_id),
    do:
      access_token_endpoint()
      |> URI.merge("/#{api_version()}/#{instagram_media_id}")
      |> Map.put(
        :query,
        URI.encode_query(%{
          access_token: access_token,
          fields:
            "caption,comments_count,is_comment_enabled,like_count,media_url,media_product_type,media_type,thumbnail_url,timestamp,username"
        })
      )
      |> to_string()

  def media_object_comments_url(access_token, instagram_media_id),
    do:
      access_token_endpoint()
      |> URI.merge("/#{api_version()}/#{instagram_media_id}/comments")
      |> Map.put(
        :query,
        URI.encode_query(%{
          access_token: access_token
        })
      )
      |> to_string()

  def media_object_insights_url(
        access_token,
        instagram_media_id,
        insight_merics \\ "ig_reels_avg_watch_time,ig_reels_video_view_total_time,likes,reach,saved,shares,total_interactions"
      ),
      do:
        access_token_endpoint()
        |> URI.merge("/#{api_version()}/#{instagram_media_id}/insights")
        |> Map.put(
          :query,
          URI.encode_query(%{
            access_token: access_token,
            metric: insight_merics
          })
        )
        |> to_string()

  @doc """
  Maximum of 30 unique calls within 7 days
  """
  def hashtag_search_url(access_token, hashtag, ig_user_id),
    do:
      access_token_endpoint()
      |> URI.merge("/#{api_version()}/ig_hashtag_search")
      |> Map.put(
        :query,
        URI.encode_query(%{
          access_token: access_token,
          q: hashtag,
          user_id: ig_user_id
        })
      )
      |> to_string()

  def hashtag_recent_media_object_url(access_token, hashtag_id, ig_user_id),
    do:
      access_token_endpoint()
      |> URI.merge("/#{api_version()}/#{hashtag_id}/recent_media")
      |> Map.put(
        :query,
        URI.encode_query(%{
          access_token: access_token,
          fields:
            "caption,comments_count,id,like_count,media_type,media_url,permalink,timestamp,children",
          user_id: ig_user_id
        })
      )
      |> to_string()

  @doc """
  30 Maximum unique hashtags within a 7 day period.
  Does not return the username of the publisher
  """
  def hashtag_top_media_object_url(access_token, hashtag_id, ig_user_id),
    do:
      access_token_endpoint()
      |> URI.merge("/#{api_version()}/#{hashtag_id}/top_media")
      |> Map.put(
        :query,
        URI.encode_query(%{
          access_token: access_token,
          fields:
            "caption,comments_count,id,like_count,media_type,media_url,permalink,timestamp,children",
          user_id: ig_user_id
        })
      )
      |> to_string()

  def user_info(access_token, ig_user_id) do
    with {:ok, %Req.Response{body: response}} <-
           Req.get(user_info_url(access_token, ig_user_id)) do
      {:ok, response}
    else
      error ->
        {:error, error}
    end
  end

  def user_insights(access_token, ig_user_id) do
    with {:ok, %Req.Response{body: body}} <-
           Req.get(user_insights_url(access_token, ig_user_id)),
         %{
           "data" => [
             %{
               "name" => "reach",
               "title" => "Reach",
               "values" => reach_values
             } = _reach_details,
             %{
               "name" => "impressions",
               "title" => "Impressions",
               "values" => impression_values
             } = _impressions_details
           ]
         } = _ <- body do
      [impression_value | _] = impression_values
      [reach_value | _] = reach_values

      {:ok,
       %{
         "impressions" => Map.get(impression_value, "value"),
         "reach" => Map.get(reach_value, "value")
       }}
    else
      error ->
        {:error, error}
    end
  end

  def feed(%{access_token: access_token, instagram_page_id: instagram_page_id} = params) do
    url =
      feed_url(%{
        access_token: access_token,
        instagram_page_id: instagram_page_id,
        after: Map.get(params, :after),
        before: Map.get(params, :before)
      })

    with {:ok, %Req.Response{body: body}} <-
           Req.get(url),
         {:ok, response} <- Jason.decode(body) do
      {:ok, cursor_based_media_pagination(response, params)}
    else
      error ->
        {:error, error}
        {:ok, []}
    end
  end

  def cursor_based_media_pagination(
        %{
          "data" => []
        },
        _
      ),
      do: []

  def cursor_based_media_pagination(
        %{
          "data" => data,
          "paging" => %{"cursors" => %{"after" => next, "before" => _}}
        },
        params
      ) do
    case feed(Map.merge(params, %{after: next})) do
      {:ok, second_call} ->
        Enum.concat(data, second_call)
        |> Enum.reduce_while([], fn current_item, acc ->
          cond do
            is_map(current_item) ->
              {:cont, [current_item] ++ acc}

            is_binary(current_item) ->
              {:cont, [current_item] ++ acc}

            true ->
              {:cont, acc}
          end
        end)

      _ ->
        Enum.concat(data, [])
        |> Enum.reduce_while([], fn current_item, acc ->
          cond do
            is_map(current_item) ->
              {:cont, [current_item] ++ acc}

            is_binary(current_item) ->
              {:cont, [current_item] ++ acc}

            true ->
              {:cont, acc}
          end
        end)
    end
  end

  def cursor_based_media_pagination(
        _,
        _
      ),
      do: []
end
