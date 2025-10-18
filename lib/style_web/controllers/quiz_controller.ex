defmodule StyleWeb.QuizController do
  use StyleWeb, :controller

  @doc """
  Health check endpoint
  GET /api/v1/health
  """
  def health(conn, _params) do
    json(conn, %{status: "ok", timestamp: DateTime.utc_now()})
  end
end
