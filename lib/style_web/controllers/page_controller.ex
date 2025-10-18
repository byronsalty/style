defmodule StyleWeb.PageController do
  use StyleWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
