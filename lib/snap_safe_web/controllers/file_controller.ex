defmodule SnapSafeWeb.FileController do
  use SnapSafeWeb, :controller

  alias SnapSafe.Files

  action_fallback SnapSafeWeb.FallbackController

  @spec upload(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def upload(conn, %{"file" => upload}) do
    user = conn.assigns.current_user

    case Files.upload_file(user.id, upload) do
      {:ok, file} ->
        conn
        |> put_status(:created)
        |> json(%{
          message: "File uploaded successfully",
          file: %{
            id: file.id,
            filename: file.filename,
            content_type: file.content_type,
            size: file.size,
            uploaded_at: file.inserted_at
          }
        })

      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: reason})
    end
  end

  @spec index(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def index(conn, _params) do
    user = conn.assigns.current_user
    files = Files.list_user_files(user.id)

    file_list =
      Enum.map(files, fn file ->
        %{
          id: file.id,
          filename: file.filename,
          content_type: file.content_type,
          size: file.size,
          uploaded_at: file.inserted_at
        }
      end)

    conn
    |> json(%{files: file_list})
  end

  @spec show(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def show(conn, %{"id" => file_id}) do
    user = conn.assigns.current_user

    case Files.get_user_file(file_id, user.id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "File not found"})

      file ->
        case File.read(file.file_path) do
          {:ok, content} ->
            conn
            |> put_resp_content_type(file.content_type)
            |> put_resp_header("content-disposition", "attachment; filename=\"#{file.filename}\"")
            |> send_resp(200, content)

          {:error, _reason} ->
            conn
            |> put_status(:internal_server_error)
            |> json(%{error: "File could not be read"})
        end
    end
  end
end
