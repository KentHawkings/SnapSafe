defmodule SnapSafeWeb.AuthJSON do
  @moduledoc """
  Serializes user data for JSON responses.
  """

  alias SnapSafe.Accounts.User

  @spec data(User.t()) :: map()
  def data(%User{} = user) do
    %{
      id: user.id,
      email: user.email
    }
  end
end
