defmodule SnapSafe.Accounts.User do
  @moduledoc """
  The User schema for user authentication and management.

  This module defines the Ecto schema for users and handles
  password validation, hashing, and user registration.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer() | nil,
          email: String.t(),
          password: String.t() | nil,
          password_hash: String.t(),
          files: [SnapSafe.Files.File.t()] | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  schema "users" do
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string

    has_many :files, SnapSafe.Files.File

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password])
    |> validate_required([:email, :password])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> validate_length(:password, min: 6, max: 72)
    |> unique_constraint(:email)
    |> put_password_hash()
  end

  @doc false
  def registration_changeset(user, attrs) do
    user
    |> changeset(attrs)
  end

  defp put_password_hash(
         %Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset
       ) do
    change(changeset, password_hash: Bcrypt.hash_pwd_salt(password))
  end

  defp put_password_hash(changeset), do: changeset
end
