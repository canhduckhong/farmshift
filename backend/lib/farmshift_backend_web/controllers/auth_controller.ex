defmodule FarmshiftBackendWeb.AuthController do
  use FarmshiftBackendWeb, :controller

  alias FarmshiftBackend.Accounts
  alias FarmshiftBackend.Auth.Guardian
  
  # Handle CORS preflight requests
  def options(conn, _params) do
    # Get the origin from the request
    origin = List.first(Plug.Conn.get_req_header(conn, "origin")) || "*"
    
    conn
    |> put_resp_header("access-control-allow-origin", origin)
    |> put_resp_header("access-control-allow-methods", "GET, POST, PUT, DELETE, OPTIONS")
    |> put_resp_header("access-control-allow-headers", "authorization, content-type, accept, origin")
    |> put_resp_header("access-control-allow-credentials", "true")
    |> put_resp_header("access-control-max-age", "600")
    |> send_resp(204, "")
  end

  def register(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        {:ok, token, _claims} = Guardian.encode_and_sign(user)
        
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

  def login(conn, %{"email" => email, "password" => password}) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        {:ok, token, _claims} = Guardian.encode_and_sign(user)
        
        conn
        |> put_status(:ok)
        |> render("login.json", %{user: user, token: token})
        
      {:error, :invalid_credentials} ->
        conn
        |> put_status(:unauthorized)
        |> put_view(json: FarmshiftBackendWeb.ErrorJSON)
        |> render("401.json", %{message: "Invalid email or password"})
    end
  end

  def current_user(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    
    conn
    |> put_status(:ok)
    |> render("user.json", %{user: user})
  end

  def logout(conn, _params) do
    conn
    |> Guardian.Plug.sign_out()
    |> put_status(:ok)
    |> render("logout.json", %{message: "Successfully logged out"})
  end
end
