defmodule StyleWeb.QuizSession do
  @moduledoc """
  Handles quiz session management across LiveView navigations
  """
  import Phoenix.LiveView
  import Phoenix.Component

  def on_mount(:default, _params, _session, socket) do
    # Quiz state is now managed via ETS in application.ex
    # This module is kept for backwards compatibility but doesn't need to do anything
    {:cont, socket}
  end
end
