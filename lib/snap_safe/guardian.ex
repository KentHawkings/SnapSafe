defmodule SnapSafe.Guardian do
  @moduledoc """
  Guardian implementation for JWT authentication.

  This module provides token generation, validation,
  and validation for user authentication in the SnapSafe application.
  """

  use Guardian, otp_app: :snap_safe

  @spec subject_for_token(SnapSafe.Accounts.User.t(), map()) :: {:ok, String.t()}
  def subject_for_token(user, _claims) do
    {:ok, to_string(user.id)}
  end

  @spec resource_from_claims(map()) :: {:ok, SnapSafe.Accounts.User.t()} | {:error, atom()}
  def resource_from_claims(%{"sub" => id}) do
    case SnapSafe.Accounts.get_user!(id) do
      nil -> {:error, :resource_not_found}
      user -> {:ok, user}
    end
  end
end
