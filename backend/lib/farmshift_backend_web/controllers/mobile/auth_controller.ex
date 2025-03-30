defmodule FarmshiftBackendWeb.Mobile.AuthController do
  use FarmshiftBackendWeb, :controller

  alias FarmshiftBackend.Accounts
  alias FarmshiftBackend.Auth.Guardian

  @doc """
  Mobile-specific registration endpoint
  """
  def register(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        # For mobile, we might want a longer expiration time for the token
        {:ok, token, _claims} = Guardian.encode_and_sign(user, %{}, ttl: {30, :day})
        
        conn
        |> put_status(:created)
        |> render("register.json", %{user: user, token: token})
        
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(json: FarmshiftBackendWeb.ErrorJSON)
        |> render("422.json", %{changeset: changeset})
    end
  end

  @doc """
  Mobile-specific login endpoint
  """
  def login(conn, %{"email" => email, "password" => password}) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        # For mobile, we might want a longer expiration time for the token
        {:ok, token, _claims} = Guardian.encode_and_sign(user, %{}, ttl: {30, :day})
        
        # Include device info in the response if provided
        device_info = Map.get(conn.params, "device_info", %{})
        
        conn
        |> put_status(:ok)
        |> render("login.json", %{user: user, token: token, device_info: device_info})
        
      {:error, :invalid_credentials} ->
        conn
        |> put_status(:unauthorized)
        |> put_view(json: FarmshiftBackendWeb.ErrorJSON)
        |> render("401.json", %{message: "Invalid email or password"})
    end
  end

  @doc """
  Get current mobile user
  """
  def current_user(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    
    conn
    |> put_status(:ok)
    |> render("user.json", %{user: user})
  end

  @doc """
  Mobile-specific logout endpoint
  """
  def logout(conn, _params) do
    token = Guardian.Plug.current_token(conn)
    
    # Revoke the token (important for mobile to prevent token reuse)
    Guardian.revoke(token)
    
    conn
    |> Guardian.Plug.sign_out()
    |> put_status(:ok)
    |> render("logout.json", %{message: "Successfully logged out"})
  end

  @doc """
  Refresh token for mobile devices
  """
  def refresh_token(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    {:ok, token, _claims} = Guardian.encode_and_sign(user, %{}, ttl: {30, :day})
    
    conn
    |> put_status(:ok)
    |> render("token.json", %{token: token})
  end

  @doc """
  Handle OPTIONS preflight requests for CORS
  """
  def options(conn, _params) do
    conn
    |> put_resp_header("Access-Control-Allow-Origin", "*")
    |> put_resp_header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
    |> put_resp_header("Access-Control-Allow-Headers", "Authorization, Content-Type, Accept, Origin")
    |> put_resp_header("Access-Control-Max-Age", "600")
    |> put_resp_header("Access-Control-Allow-Credentials", "true")
    |> send_resp(:no_content, "")
  end
end
