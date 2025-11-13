defmodule Style.Services.ConvertKitClient do
  @moduledoc """
  Client for interacting with the ConvertKit (Kit) API v4.

  Documentation: https://developers.kit.com/v4
  """

  require Logger

  @base_url "https://api.kit.com/v4"
  @timeout 10_000

  @doc """
  Subscribes a user to a ConvertKit form.

  ## Parameters
    - email: The subscriber's email address
    - first_name: (optional) The subscriber's first name
    - fields: (optional) Map of custom field keys to values

  ## Returns
    - {:ok, response} - Successfully subscribed
    - {:error, reason} - Failed to subscribe

  ## Example
      iex> ConvertKitClient.subscribe_to_form("user@example.com", %{first_name: "John", fields: %{"learning_style" => "visual-learner"}})
      {:ok, %{"subscriber" => %{"id" => 123, "email_address" => "user@example.com"}}}
  """
  def subscribe_to_form(email, opts \\ %{}) do
    api_key = get_api_key()

    if is_nil(api_key) do
      Logger.error("ConvertKit configuration missing: api_key not set")
      {:error, :config_missing}
    else
      body =
        %{
          email_address: email
        }
        |> maybe_add_field(:first_name, opts[:first_name])
        |> maybe_add_field(:fields, opts[:fields])

      url = "#{@base_url}/subscribers"
      headers = [{"X-Kit-Api-Key", api_key}]

      Logger.info("ConvertKit API Request:")
      Logger.info("  URL: #{url}")
      Logger.info("  Method: POST")
      Logger.info("  Headers: #{inspect(headers)}")
      Logger.info("  Body: #{inspect(body)}")

      case Req.post(url, json: body, headers: headers, receive_timeout: @timeout) do
        {:ok, %Req.Response{status: status, body: response_body}} when status in 200..299 ->
          Logger.info("Successfully subscribed #{email} to ConvertKit")
          {:ok, response_body}

        {:ok, %Req.Response{status: status, body: response_body}} ->
          Logger.error("ConvertKit API error: status=#{status}, body=#{inspect(response_body)}")

          {:error, {:api_error, status, response_body}}

        {:error, reason} = error ->
          Logger.error("HTTP request to ConvertKit failed: #{inspect(reason)}")
          error
      end
    end
  end

  @doc """
  Tags a subscriber with a specific tag.

  ## Parameters
    - email: The subscriber's email address
    - tag_id: The ConvertKit tag ID

  ## Returns
    - {:ok, response} - Successfully tagged
    - {:error, reason} - Failed to tag
  """
  def tag_subscriber(email, tag_id) do
    api_key = get_api_key()

    if is_nil(api_key) do
      Logger.error("ConvertKit configuration missing: api_key not set")
      {:error, :config_missing}
    else
      body = %{
        email_address: email
      }

      url = "#{@base_url}/tags/#{tag_id}/subscribers"
      headers = [{"X-Kit-Api-Key", api_key}]

      Logger.info("ConvertKit Tag API Request:")
      Logger.info("  URL: #{url}")
      Logger.info("  Method: POST")
      Logger.info("  Headers: #{inspect(headers)}")
      Logger.info("  Body: #{inspect(body)}")

      case Req.post(url, json: body, headers: headers, receive_timeout: @timeout) do
        {:ok, %Req.Response{status: status, body: response_body}} when status in 200..299 ->
          Logger.info("Successfully tagged #{email} with tag #{tag_id}")
          {:ok, response_body}

        {:ok, %Req.Response{status: status, body: response_body}} ->
          Logger.error("ConvertKit API error: status=#{status}, body=#{inspect(response_body)}")

          {:error, {:api_error, status, response_body}}

        {:error, reason} = error ->
          Logger.error("HTTP request to ConvertKit failed: #{inspect(reason)}")
          error
      end
    end
  end

  # Private functions

  defp maybe_add_field(map, _key, nil), do: map
  defp maybe_add_field(map, _key, ""), do: map
  defp maybe_add_field(map, _key, fields) when is_map(fields) and map_size(fields) == 0, do: map
  defp maybe_add_field(map, key, value), do: Map.put(map, key, value)

  defp get_api_key do
    Application.get_env(:style, :convertkit_api_key)
  end
end
