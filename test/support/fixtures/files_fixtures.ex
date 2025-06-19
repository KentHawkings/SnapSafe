defmodule SnapSafe.FilesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SnapSafe.Files` context.
  """

  import SnapSafe.AccountsFixtures

  @doc """
  Generate a file.
  """
  def file_fixture(attrs \\ %{}) do
    user = user_fixture()

    {:ok, file} =
      attrs
      |> Enum.into(%{
        content_type: "text/plain",
        file_path: "test/file.txt",
        filename: "file.txt",
        size: 42,
        user_id: user.id
      })
      |> SnapSafe.Files.create_file()

    file
  end
end
