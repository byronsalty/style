defmodule Style.Services.ConvertKitSubscriber do
  @moduledoc """
  Service for subscribing quiz participants to ConvertKit.

  This service is called when a user completes the quiz and provides
  their email address with consent to be added to the mailing list.
  """

  require Logger

  alias Style.Services.ConvertKitClient
  alias Style.Quiz.Lead

  @doc """
  Subscribes a lead to ConvertKit after quiz completion.

  This function will only subscribe the user if they have given consent
  (opt_in_courses or opt_in_all_communications is true).

  ## Parameters
    - lead: A %Lead{} struct with email, learning_style_slug, and consent fields

  ## Returns
    - {:ok, response} - Successfully subscribed to ConvertKit
    - {:ok, :skipped} - Skipped because user did not consent
    - {:error, reason} - Failed to subscribe

  ## Example
      iex> lead = %Lead{
      ...>   email: "user@example.com",
      ...>   learning_style_slug: "visual-learner",
      ...>   opt_in_courses: true
      ...> }
      iex> ConvertKitSubscriber.subscribe_lead(lead)
      {:ok, %{"subscriber" => %{"id" => 123}}}
  """
  def subscribe_lead(%Lead{} = lead) do
    cond do
      !has_consent?(lead) ->
        Logger.info("Skipping ConvertKit subscription for #{lead.email} - no consent given")
        {:ok, :skipped}

      !convertkit_enabled?() ->
        Logger.info("ConvertKit integration is disabled")
        {:ok, :disabled}

      true ->
        perform_subscription(lead)
    end
  end

  @doc """
  Checks if ConvertKit integration is enabled.

  ConvertKit is considered enabled if the API key is configured.
  """
  def convertkit_enabled? do
    api_key = Application.get_env(:style, :convertkit_api_key)

    !is_nil(api_key) && api_key != ""
  end

  # Private functions

  defp has_consent?(%Lead{opt_in_courses: true}), do: true
  defp has_consent?(%Lead{opt_in_all_communications: true}), do: true
  defp has_consent?(_), do: false

  defp perform_subscription(%Lead{} = lead) do
    # Extract first name if available in metadata
    first_name = get_in(lead.metadata, ["first_name"])

    # Prepare custom fields
    fields = build_custom_fields(lead)

    # Subscribe to form
    case ConvertKitClient.subscribe_to_form(lead.email, %{
           first_name: first_name,
           fields: fields
         }) do
      {:ok, response} ->
        # Optionally tag by learning style if tag mapping exists
        maybe_tag_by_learning_style(lead.email, lead.learning_style_slug)
        {:ok, response}

      {:error, reason} = error ->
        Logger.error("Failed to subscribe #{lead.email} to ConvertKit: #{inspect(reason)}")

        error
    end
  end

  defp build_custom_fields(%Lead{} = _lead) do
    %{
      "Source" => "quiz.margaretsalty.com"
    }
  end

  defp maybe_tag_by_learning_style(email, learning_style_slug) do
    # Get tag mapping from config (if configured)
    tag_mapping = Application.get_env(:style, :convertkit_learning_style_tags, %{})

    case Map.get(tag_mapping, learning_style_slug) do
      nil ->
        Logger.debug("No tag mapping found for learning style: #{learning_style_slug}")
        :ok

      tag_id ->
        Logger.info("Tagging #{email} with learning style tag: #{tag_id}")

        case ConvertKitClient.tag_subscriber(email, tag_id) do
          {:ok, _} ->
            :ok

          {:error, reason} ->
            Logger.warning("Failed to tag subscriber: #{inspect(reason)}")
            :ok
        end
    end
  end
end
