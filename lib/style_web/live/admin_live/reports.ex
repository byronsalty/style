defmodule StyleWeb.AdminLive.Reports do
  use StyleWeb, :live_view

  alias Style.Quiz.Lead
  alias Style.Repo

  import Ecto.Query

  @impl true
  def mount(_params, _session, socket) do
    leads = load_leads()

    {:ok,
     socket
     |> assign(page_title: "Quiz Reports")
     |> assign(leads: leads)}
  end

  defp load_leads do
    Lead
    |> order_by([l], desc: l.inserted_at)
    |> preload(:quiz_responses)
    |> Repo.all()
    |> Repo.preload(quiz_responses: [:question, :answer_option])
  end

  @impl true
  def handle_event("refresh", _params, socket) do
    {:noreply, assign(socket, leads: load_leads())}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="admin-container" style="padding: 2rem; max-width: 1400px; margin: 0 auto; background: #ffffff; min-height: 100vh;">
      <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 2rem;">
        <h1 style="font-size: 2rem; font-weight: bold; color: #111827;">Quiz Signups Report</h1>
        <button phx-click="refresh" class="btn btn-secondary" style="background: #6366f1; color: white; padding: 0.5rem 1rem; border-radius: 6px; border: none; cursor: pointer; font-weight: 600;">
          Refresh
        </button>
      </div>

      <div style="background: white; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); overflow: hidden; border: 1px solid #e5e7eb;">
        <div style="overflow-x: auto;">
          <table style="width: 100%; border-collapse: collapse;">
            <thead>
              <tr style="background: #f3f4f6; border-bottom: 2px solid #e5e7eb;">
                <th style="padding: 1rem; text-align: left; font-weight: 600; color: #111827;">Email</th>
                <th style="padding: 1rem; text-align: left; font-weight: 600; color: #111827;">Learning Style</th>
                <th style="padding: 1rem; text-align: left; font-weight: 600; color: #111827;">Courses Opt-in</th>
                <th style="padding: 1rem; text-align: left; font-weight: 600; color: #111827;">All Comms Opt-in</th>
                <th style="padding: 1rem; text-align: left; font-weight: 600; color: #111827;">Completed At</th>
                <th style="padding: 1rem; text-align: left; font-weight: 600; color: #111827;">Responses</th>
              </tr>
            </thead>
            <tbody>
              <%= for lead <- @leads do %>
                <tr style="border-bottom: 1px solid #e5e7eb;">
                  <td style="padding: 1rem; color: #111827;"><%= lead.email %></td>
                  <td style="padding: 1rem;">
                    <span style="background: #dbeafe; color: #1e40af; padding: 0.25rem 0.75rem; border-radius: 9999px; font-size: 0.875rem;">
                      <%= format_learning_style(lead.learning_style_slug) %>
                    </span>
                  </td>
                  <td style="padding: 1rem;">
                    <%= if lead.opt_in_courses do %>
                      <span style="color: #059669; font-weight: 500;">✓ Yes</span>
                    <% else %>
                      <span style="color: #dc2626; font-weight: 500;">✗ No</span>
                    <% end %>
                  </td>
                  <td style="padding: 1rem;">
                    <%= if lead.opt_in_all_communications do %>
                      <span style="color: #059669; font-weight: 500;">✓ Yes</span>
                    <% else %>
                      <span style="color: #dc2626; font-weight: 500;">✗ No</span>
                    <% end %>
                  </td>
                  <td style="padding: 1rem; font-size: 0.875rem; color: #6b7280;">
                    <%= format_datetime(lead.metadata["quiz_completed_at"]) %>
                  </td>
                  <td style="padding: 1rem;">
                    <details>
                      <summary style="cursor: pointer; color: #2563eb; font-weight: 500;">
                        View Answers (<%= length(lead.quiz_responses) %>)
                      </summary>
                      <div style="margin-top: 0.5rem; padding: 0.5rem; background: #f9fafb; border-radius: 4px; color: #374151;">
                        <%= for response <- Enum.sort_by(lead.quiz_responses, & &1.question.position) do %>
                          <div style="margin-bottom: 0.5rem; font-size: 0.875rem; color: #374151;">
                            <strong style="color: #111827;">Q<%= response.question.position %>:</strong>
                            <%= response.answer_option.label %>. <%= response.answer_option.text %>
                          </div>
                        <% end %>
                      </div>
                    </details>
                  </td>
                </tr>
              <% end %>
            </tbody>
          </table>

          <%= if @leads == [] do %>
            <div style="padding: 3rem; text-align: center; color: #6b7280;">
              <p style="font-size: 1.125rem;">No signups yet</p>
              <p style="font-size: 0.875rem; margin-top: 0.5rem;">
                Quiz completions will appear here
              </p>
            </div>
          <% end %>
        </div>
      </div>

      <div style="margin-top: 2rem; padding: 1.5rem; background: #f3f4f6; border-radius: 8px; border: 1px solid #e5e7eb;">
        <h3 style="font-weight: 600; margin-bottom: 1rem; color: #111827;">Summary</h3>
        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1rem;">
          <div>
            <div style="font-size: 0.875rem; color: #6b7280;">Total Signups</div>
            <div style="font-size: 1.5rem; font-weight: bold; color: #111827;"><%= length(@leads) %></div>
          </div>
          <div>
            <div style="font-size: 0.875rem; color: #6b7280;">Courses Opt-ins</div>
            <div style="font-size: 1.5rem; font-weight: bold; color: #111827;">
              <%= Enum.count(@leads, & &1.opt_in_courses) %>
            </div>
          </div>
          <div>
            <div style="font-size: 0.875rem; color: #6b7280;">All Comms Opt-ins</div>
            <div style="font-size: 1.5rem; font-weight: bold; color: #111827;">
              <%= Enum.count(@leads, & &1.opt_in_all_communications) %>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp format_learning_style(slug) do
    slug
    |> String.replace("-", " ")
    |> String.split()
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end

  defp format_datetime(nil), do: "N/A"

  defp format_datetime(iso_string) when is_binary(iso_string) do
    case DateTime.from_iso8601(iso_string) do
      {:ok, dt, _offset} ->
        Calendar.strftime(dt, "%Y-%m-%d %I:%M %p")

      _ ->
        iso_string
    end
  end

  defp format_datetime(_), do: "N/A"
end
