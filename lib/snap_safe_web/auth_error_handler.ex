defmodule SnapSafeWeb.AuthErrorHandler do
  @moduledoc """
  Error handler for Guardian authentication failures.

  This module handles authentication errors from Guardian
  and returns appropriate JSON responses.
  """

  import Plug.Conn

  def auth_error(conn, {type, _reason}, _opts) do
    body = Jason.encode!(%{error: to_string(type)})

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(401, body)
  end
end
