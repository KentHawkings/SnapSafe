defmodule FileJson do
  @moduledoc """
  A module for encoding file data to JSON format.
  """

  alias SnapSafe.Files.File, as: FileSchema

  @spec show(map()) :: map()
  def show(%{file: %FileSchema{} = file}) do
    %{
      id: file.id,
      filename: file.filename,
      content_type: file.content_type,
      size: file.size,
      uploaded_at: file.inserted_at
    }
  end
end
