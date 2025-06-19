defmodule SnapSafe.Files.File do
  @moduledoc """
  The File schema for storing uploaded file metadata.

  This module defines the Ecto schema for files and handles
  validation for file types, sizes, and filename sanitization.
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias SnapSafe.Accounts.User

  @allowed_content_types [
    "image/jpeg",
    "image/png",
    "image/gif",
    "image/svg+xml",
    "text/plain",
    "text/markdown",
    "text/csv"
  ]

  # 2MB
  @max_file_size 2 * 1024 * 1024

  @type t :: %__MODULE__{
          id: integer() | nil,
          filename: String.t(),
          content_type: String.t(),
          size: integer(),
          file_path: String.t(),
          user_id: integer(),
          user: User.t() | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  schema "files" do
    field :size, :integer
    field :filename, :string
    field :content_type, :string
    field :file_path, :string

    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(file, attrs) do
    file
    |> cast(attrs, [:filename, :content_type, :size, :file_path, :user_id])
    |> validate_required([:filename, :content_type, :size, :file_path, :user_id])
    |> validate_content_type()
    |> validate_file_size()
    |> sanitize_filename()
  end

  defp validate_content_type(changeset) do
    validate_inclusion(changeset, :content_type, @allowed_content_types,
      message: "file type not supported"
    )
  end

  defp validate_file_size(changeset) do
    validate_number(changeset, :size,
      greater_than: 0,
      less_than_or_equal_to: @max_file_size,
      message: "file size must be less than 2MB"
    )
  end

  defp sanitize_filename(changeset) do
    case get_change(changeset, :filename) do
      nil ->
        changeset

      filename ->
        sanitized =
          filename
          |> String.replace(~r/[^a-zA-Z0-9._-]/, "_")
          |> String.replace(~r/_{2,}/, "_")

        put_change(changeset, :filename, sanitized)
    end
  end

  def allowed_content_types, do: @allowed_content_types
  def max_file_size, do: @max_file_size
end
