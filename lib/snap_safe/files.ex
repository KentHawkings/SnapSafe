defmodule SnapSafe.Files do
  @moduledoc """
  The Files context.
  """

  import Ecto.Query, warn: false
  alias SnapSafe.Repo

  alias SnapSafe.Files.File, as: FileSchema

  @doc """
  Returns the list of files.

  ## Examples

      iex> list_files()
      [%File{}, ...]

  """
  @spec list_files() :: [FileSchema.t()]
  def list_files do
    Repo.all(FileSchema)
  end

  @doc """
  Gets a single file.

  Raises `Ecto.NoResultsError` if the File does not exist.

  ## Examples

      iex> get_file!(123)
      %File{}

      iex> get_file!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_file!(integer()) :: FileSchema.t()
  def get_file!(id), do: Repo.get!(FileSchema, id)

  @doc """
  Gets a file by ID for a specific user.

  ## Examples

      iex> get_user_file(123, user_id)
      %File{}

      iex> get_user_file(456, user_id)
      nil

  """
  @spec get_user_file(integer(), integer()) :: FileSchema.t() | nil
  def get_user_file(id, user_id) do
    Repo.get_by(FileSchema, id: id, user_id: user_id)
  end

  @doc """
  Gets a file by ID for a specific user, raises if not found.

  ## Examples

      iex> get_user_file!(123, user_id)
      %File{}

      iex> get_user_file!(456, user_id)
      ** (Ecto.NoResultsError)

  """
  @spec get_user_file!(integer(), integer()) :: FileSchema.t()
  def get_user_file!(id, user_id) do
    Repo.get_by!(FileSchema, id: id, user_id: user_id)
  end

  @doc """
  Returns the list of files for a specific user.

  ## Examples

      iex> list_user_files(user_id)
      [%File{}, ...]

  """
  @spec list_user_files(integer()) :: [FileSchema.t()]
  def list_user_files(user_id) do
    from(f in FileSchema, where: f.user_id == ^user_id, order_by: [desc: f.inserted_at])
    |> Repo.all()
  end

  @doc """
  Creates a file for a specific user.

  ## Examples

      iex> create_file_for_user(user_id, %{filename: "test.txt", content_type: "text/plain"})
      {:ok, %File{}}

      iex> create_file_for_user(user_id, %{})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_file_for_user(integer(), map()) ::
          {:ok, FileSchema.t()} | {:error, Ecto.Changeset.t()}
  def create_file_for_user(user_id, attrs \\ %{}) do
    %FileSchema{}
    |> FileSchema.changeset(Map.put(attrs, :user_id, user_id))
    |> Repo.insert()
  end

  @doc """
  Uploads a file and stores it on disk.

  ## Examples

      iex> upload_file(user_id, upload_params)
      {:ok, %File{}}

      iex> upload_file(user_id, invalid_params)
      {:error, reason}

  """
  @spec upload_file(integer(), Plug.Upload.t()) :: {:ok, FileSchema.t()} | {:error, String.t()}
  def upload_file(user_id, %Plug.Upload{} = upload) do
    with :ok <- validate_upload(upload),
         {:ok, file_path} <- store_file(user_id, upload),
         {:ok, file} <- create_file_record(user_id, upload, file_path) do
      {:ok, file}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp validate_upload(%Plug.Upload{content_type: content_type, filename: filename} = upload) do
    {:ok, %File.Stat{size: file_size}} = File.stat(upload.path)

    cond do
      content_type not in FileSchema.allowed_content_types() ->
        {:error, "File type not supported"}

      file_size > FileSchema.max_file_size() ->
        {:error, "File size exceeds 2MB limit"}

      String.trim(filename) == "" ->
        {:error, "Filename cannot be empty"}

      true ->
        :ok
    end
  end

  defp store_file(user_id, %Plug.Upload{filename: filename} = upload) do
    user_dir = Path.join(["uploads", "user_#{user_id}"])
    File.mkdir_p!(user_dir)

    file_extension = Path.extname(filename)
    unique_filename = "#{System.unique_integer([:positive])}#{file_extension}"
    file_path = Path.join([user_dir, unique_filename])

    case File.cp(upload.path, file_path) do
      :ok -> {:ok, file_path}
      {:error, reason} -> {:error, "Failed to store file: #{reason}"}
    end
  end

  defp create_file_record(
         user_id,
         %Plug.Upload{filename: filename, content_type: content_type},
         file_path
       ) do
    {:ok, %File.Stat{size: file_size}} = File.stat(file_path)

    attrs = %{
      filename: filename,
      content_type: content_type,
      size: file_size,
      file_path: file_path,
      user_id: user_id
    }

    create_file_for_user(user_id, attrs)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking file changes.

  ## Examples

      iex> change_file(file)
      %Ecto.Changeset{data: %File{}}

  """
  @spec change_file(FileSchema.t(), map()) :: Ecto.Changeset.t()
  def change_file(%FileSchema{} = file, attrs \\ %{}) do
    FileSchema.changeset(file, attrs)
  end

  @doc """
  Creates a file.

  ## Examples

      iex> create_file(%{filename: "test.txt", content_type: "text/plain"})
      {:ok, %File{}}

      iex> create_file(%{})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_file(map()) :: {:ok, FileSchema.t()} | {:error, Ecto.Changeset.t()}
  def create_file(attrs \\ %{}) do
    %FileSchema{}
    |> FileSchema.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a file.

  ## Examples

      iex> update_file(file, %{filename: "new_name.txt"})
      {:ok, %File{}}

      iex> update_file(file, %{filename: nil})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_file(FileSchema.t(), map()) :: {:ok, FileSchema.t()} | {:error, Ecto.Changeset.t()}
  def update_file(%FileSchema{} = file, attrs) do
    file
    |> FileSchema.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a file.

  ## Examples

      iex> delete_file(file)
      {:ok, %File{}}

      iex> delete_file(file)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_file(FileSchema.t()) :: {:ok, FileSchema.t()} | {:error, Ecto.Changeset.t()}
  def delete_file(%FileSchema{} = file) do
    Repo.delete(file)
  end
end
