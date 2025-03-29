defmodule FarmshiftBackendWeb.Router do
  use FarmshiftBackendWeb, :router

  # Apply CORS before any other pipeline
  pipeline :cors do
    plug Corsica,
      origins: ["http://localhost:3000", "http://localhost:5173", "http://127.0.0.1:3000", "http://127.0.0.1:5173"], 
      allow_headers: ["content-type", "accept", "authorization", "origin"],
      allow_credentials: true,
      max_age: 600
  end

  pipeline :api do
    plug :accepts, ["json"]
  end
  
  pipeline :auth do
    plug :accepts, ["json"]
    # Guardian authentication pipeline
    plug Guardian.Plug.Pipeline,
      module: FarmshiftBackend.Auth.Guardian,
      error_handler: FarmshiftBackendWeb.AuthErrorHandler
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource, allow_blank: true
  end
  
  pipeline :ensure_auth do
    plug Guardian.Plug.EnsureAuthenticated
  end

  # Handle OPTIONS preflight requests for all routes
  scope "/api" do
    pipe_through [:cors]
    options "/*path", FarmshiftBackendWeb.AuthController, :options
  end

  # Public routes that don't require authentication
  scope "/api", FarmshiftBackendWeb do
    pipe_through [:cors, :api, :auth]
    
    post "/register", AuthController, :register
    post "/login", AuthController, :login
  end
  
  # Protected routes that require authentication
  scope "/api", FarmshiftBackendWeb do
    pipe_through [:cors, :api, :auth, :ensure_auth]
    
    get "/current_user", AuthController, :current_user
    post "/logout", AuthController, :logout
  end

  # Enable LiveDashboard in development
  if Application.compile_env(:farmshift_backend, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: FarmshiftBackendWeb.Telemetry
    end
  end
end
