defmodule SnapSafeWeb.AuthJSON do
  @moduledoc """
  Serializes user data for JSON responses.
  """

  alias SnapSafe.Accounts.User

  @spec show(map()) :: map()
  def show(%{user: %User{} = user}) do
    %{
      id: user.id,
      email: user.email
    }
  end
end
