defmodule SnapSafeWeb.AuthPlug do
  @moduledoc """
  Authentication plug to ensure user is authenticated.

  This plug checks for the presence of an authenticated user
  in the connection and assigns it to conn.assigns.current_user.
  If no user is found, it returns an unauthorized response.
  """

  import Plug.Conn
  import Phoenix.Controller

  def init(opts), do: opts

  def call(conn, _opts) do
    case Guardian.Plug.current_resource(conn) do
      nil ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Authentication required"})
        |> halt()

      user ->
        assign(conn, :current_user, user)
    end
  end
end
