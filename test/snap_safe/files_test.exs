defmodule SnapSafe.FilesTest do
  use SnapSafe.DataCase

  alias SnapSafe.Files

  describe "files" do
    alias SnapSafe.Files.File

    import SnapSafe.FilesFixtures
    import SnapSafe.AccountsFixtures

    @invalid_attrs %{size: nil, filename: nil, content_type: nil, file_path: nil}

    test "list_files/0 returns all files" do
      file = file_fixture()
      assert Files.list_files() == [file]
    end

    test "get_file!/1 returns the file with given id" do
      file = file_fixture()
      assert Files.get_file!(file.id) == file
    end

    test "create_file/1 with valid data creates a file" do
      user = user_fixture()

      valid_attrs = %{
        size: 42,
        filename: "test.txt",
        content_type: "text/plain",
        file_path: "test/file.txt",
        user_id: user.id
      }

      assert {:ok, %File{} = file} = Files.create_file(valid_attrs)
      assert file.size == 42
      assert file.filename == "test.txt"
      assert file.content_type == "text/plain"
      assert file.file_path == "test/file.txt"
    end

    test "create_file/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Files.create_file(@invalid_attrs)
    end

    test "update_file/2 with valid data updates the file" do
      file = file_fixture()

      update_attrs = %{
        size: 43,
        filename: "updated_file.txt",
        content_type: "text/markdown",
        file_path: "test/updated_file.txt"
      }

      assert {:ok, %File{} = file} = Files.update_file(file, update_attrs)
      assert file.size == 43
      assert file.filename == "updated_file.txt"
      assert file.content_type == "text/markdown"
      assert file.file_path == "test/updated_file.txt"
    end

    test "update_file/2 with invalid data returns error changeset" do
      file = file_fixture()
      assert {:error, %Ecto.Changeset{}} = Files.update_file(file, @invalid_attrs)
      assert file == Files.get_file!(file.id)
    end

    test "delete_file/1 deletes the file" do
      file = file_fixture()
      assert {:ok, %File{}} = Files.delete_file(file)
      assert_raise Ecto.NoResultsError, fn -> Files.get_file!(file.id) end
    end

    test "change_file/1 returns a file changeset" do
      file = file_fixture()
      assert %Ecto.Changeset{} = Files.change_file(file)
    end
  end
end
