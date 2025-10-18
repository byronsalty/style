defmodule StyleWeb.Router do
  use StyleWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {StyleWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Quiz routes - Phoenix LiveView
  scope "/", StyleWeb do
    pipe_through :browser

    live "/", QuizLive.Index, :index
    live "/quiz/:session_id", QuizLive.Question, :show
    live "/result/:session_id", QuizLive.Result, :show
  end

  # Admin routes
  scope "/admin", StyleWeb do
    pipe_through :browser

    live "/reports", AdminLive.Reports, :index
  end

  # API routes (for health checks, etc.)
  scope "/api/v1", StyleWeb do
    pipe_through :api

    get "/health", QuizController, :health
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:style, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: StyleWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
