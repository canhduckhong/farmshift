defmodule FarmshiftBackendWeb.Plugs.CurrentUserPlug do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    # Get the current user from the Guardian resource
    current_user = Guardian.Plug.current_resource(conn)
    
    # Assign the current user to the connection
    assign(conn, :current_user, current_user)
  end
end
