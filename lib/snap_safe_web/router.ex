defmodule SnapSafeWeb.Router do
  use SnapSafeWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authenticated do
    plug Guardian.Plug.Pipeline,
      module: SnapSafe.Guardian,
      error_handler: SnapSafeWeb.AuthErrorHandler

    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.EnsureAuthenticated
    plug Guardian.Plug.LoadResource
    plug SnapSafeWeb.AuthPlug
  end

  scope "/api/auth", SnapSafeWeb do
    pipe_through :api

    # Authentication routes (no authentication required)
    post "/register", AuthController, :register
    post "/login", AuthController, :login
  end

  scope "/api", SnapSafeWeb do
    pipe_through [:api, :authenticated]

    # File management routes (authentication required)
    post "/upload", FileController, :upload
    get "/files", FileController, :index
    get "/files/:id", FileController, :show
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:snap_safe, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: SnapSafeWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
