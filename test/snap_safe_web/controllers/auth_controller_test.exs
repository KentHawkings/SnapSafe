defmodule SnapSafeWeb.AuthControllerTest do
  use SnapSafeWeb.ConnCase, async: true
  alias SnapSafe.Accounts

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "register/2" do
    test "creates user and returns JWT token on successful registration", %{conn: conn} do
      user_params = %{
        "email" => "test@example.com",
        "password" => "password123",
        "name" => "Test User"
      }

      conn = post(conn, ~p"/api/auth/register", user: user_params)

      assert %{"id" => id, "email" => "test@example.com"} = json_response(conn, 201)
      assert ["Bearer " <> _token] = get_resp_header(conn, "authorization")
      assert is_integer(id)
    end

    test "returns error on invalid user params", %{conn: conn} do
      invalid_params = %{
        "email" => "invalid-email",
        "password" => "123"
      }

      conn = post(conn, ~p"/api/auth/register", user: invalid_params)

      assert %{"error" => "Registration failed", "details" => details} = json_response(conn, 422)
      assert is_map(details)
    end

    test "returns error when email already exists", %{conn: conn} do
      # Create a user first
      existing_user_params = %{
        email: "existing@example.com",
        password: "password123",
        name: "Existing User"
      }

      {:ok, _user} = Accounts.register_user(existing_user_params)

      # Try to register with same email
      duplicate_params = %{
        "email" => "existing@example.com",
        "password" => "newpassword123",
        "name" => "New User"
      }

      conn = post(conn, ~p"/api/auth/register", user: duplicate_params)

      assert %{"error" => "Registration failed", "details" => details} = json_response(conn, 422)
      assert Map.has_key?(details, "email")
    end
  end

  describe "login/2" do
    setup do
      user_params = %{
        email: "login@example.com",
        password: "password123",
        name: "Login User"
      }

      {:ok, user} = Accounts.register_user(user_params)
      {:ok, user: user}
    end

    test "returns JWT token on successful login", %{conn: conn} do
      login_params = %{
        "email" => "login@example.com",
        "password" => "password123"
      }

      conn = post(conn, ~p"/api/auth/login", login_params)

      assert %{"id" => id, "email" => "login@example.com"} = json_response(conn, 200)
      assert ["Bearer " <> _token] = get_resp_header(conn, "authorization")
      assert is_integer(id)
    end

    test "returns error on invalid email", %{conn: conn} do
      login_params = %{
        "email" => "nonexistent@example.com",
        "password" => "password123"
      }

      conn = post(conn, ~p"/api/auth/login", login_params)

      assert %{"error" => "Invalid email or password"} = json_response(conn, 401)
      assert get_resp_header(conn, "authorization") == []
    end

    test "returns error on invalid password", %{conn: conn} do
      login_params = %{
        "email" => "login@example.com",
        "password" => "wrongpassword"
      }

      conn = post(conn, ~p"/api/auth/login", login_params)

      assert %{"error" => "Invalid email or password"} = json_response(conn, 401)
      assert get_resp_header(conn, "authorization") == []
    end

    test "returns error when email is missing", %{conn: conn} do
      login_params = %{
        "password" => "password123"
      }

      conn = post(conn, ~p"/api/auth/login", login_params)

      assert response(conn, 400)
    end

    test "returns error when password is missing", %{conn: conn} do
      login_params = %{
        "email" => "login@example.com"
      }

      conn = post(conn, ~p"/api/auth/login", login_params)

      assert response(conn, 400)
    end
  end
end
