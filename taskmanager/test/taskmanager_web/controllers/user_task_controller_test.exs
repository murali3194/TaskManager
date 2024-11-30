defmodule TaskmanagerWeb.UsertaskControllerTest do
  use TaskmanagerWeb.ConnCase

  alias Taskmanager.Schema
  import Taskmanager.SchemaFixtures
  alias Ecto.UUID

  @create_user_attrs %{first_name: "some first_name", last_name: "some last_name", email_id: "some@example.com", contact: 42}
  @update_user_attrs %{first_name: "some updated first_name", last_name: "some updated last name", email_id: "someupdated@example.com", contact: 43}
  @invalid_user_attrs %{first_name: nil, last_name: nil, email_id: nil, contact: nil}

  @create_task_attrs %{task_status: "To Do", description: "some description", title: "some title", due_date: ~U[2024-09-12 19:36:00Z]}
  @update_task_attrs %{task_status: "In Progress", description: "some updated description", title: "some updated title", due_date: ~U[2024-09-13 19:36:00Z]}
  @invalid_task_attrs %{task_status: nil, description: nil, title: nil, due_date: nil}

  setup %{conn: conn} do
    user = user_fixture()
    conn =
      conn
      |> init_test_session(current_user: user.email_id)

    %{conn: conn}
  end

  describe "user_login_page" do
    test "renders login page", %{conn: conn} do
      conn = conn |> delete_session(:current_user) |> get(~p"/login")
      assert html_response(conn, 200) =~ "Log in to account"
    end
  end

  describe "user_login" do
    setup [:create_user]
    test "logs the user in", %{conn: conn, user: user} do
      conn = conn |> delete_session(:current_user) |> post(~p"/login/user", %{
        "user" => %{"email_id" => user.email_id}
      })
      assert get_session(conn, :current_user)
      assert redirected_to(conn) == ~p"/users"
    end

    test "emits error message with invalid credentials", %{conn: conn, user: user} do
      conn = conn |> delete_session(:current_user) |> post(~p"/login/user", %{
        "user" => %{"email_id" => "Invalid email"}
      })
      response = html_response(conn, 200)
      assert response =~ "Log in"
      assert response =~ "Invalid email"
    end
  end

  describe "register_user" do
    setup [:create_user]
    test "creates account and logs the user in", %{conn: conn, user: user} do
      conn = conn |> delete_session(:current_user) |>  post(~p"/users/register", user: @create_user_attrs)
      assert get_session(conn, :current_user)
      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/users/#{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = conn |> delete_session(:current_user) |>  post(~p"/users/register", user: @invalid_user_attrs)
      assert html_response(conn, 200) =~ "Register User"
    end

  end

  describe "new_register_user" do
    test "renders register form", %{conn: conn} do
      conn = conn |> delete_session(:current_user) |> get(~p"/users/new/register")
      assert html_response(conn, 200) =~ "Register User"
    end
  end


  describe "index" do
    test "lists all users", %{conn: conn} do
      conn = get(conn, ~p"/users")
      assert html_response(conn, 200) =~ "Listing Users"
    end
  end

  describe "new user" do
    test "renders user form", %{conn: conn} do
      conn = get(conn, ~p"/users/new/create")
      assert html_response(conn, 200) =~ "New User"
    end
  end

  describe "create user" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/users", user: @create_user_attrs)
      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/users/#{id}"

      conn = get(conn, ~p"/users/#{id}")
      assert html_response(conn, 200) =~ "User"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/users", user: @invalid_user_attrs)
      assert html_response(conn, 200) =~ "New User"
    end
  end

  describe "edit user" do
    setup [:create_user]

    test "renders form for editing chosen user", %{conn: conn, user: user} do
      user = %{user | id: UUID.load!(user.uuid)}
      assert get_session(conn, :current_user)
      conn = get(conn, ~p"/users/#{user.id}/edit")
      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  describe "update user" do
    setup [:create_user]

    test "redirects when data is valid", %{conn: conn, user: user} do
      user = %{user | id: UUID.load!(user.uuid)}
      conn = put(conn, ~p"/users/#{user.id}", user: @update_user_attrs)
      assert redirected_to(conn) == ~p"/users/#{user.id}"
      conn = get(conn, ~p"/users/#{user.id}")
      assert html_response(conn, 200) =~ "some updated first_name"
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      user = %{user | id: UUID.load!(user.uuid)}
      conn = put(conn, ~p"/users/#{user.id}", user: @invalid_user_attrs)
      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  describe "delete user" do
    setup [:create_user]

    test "deletes chosen user", %{conn: conn, user: user} do
      user = %{user | id: UUID.load!(user.uuid)}
      conn = delete(conn, ~p"/users/#{user.id}")
      assert redirected_to(conn) == ~p"/login"
    end
  end

  describe "list user task" do
    setup [:create_user_task]
    test "lists all user tasks", %{conn: conn, task_user: task_user, task: task} do
      task_user = %{task_user | id: UUID.load!(task_user.uuid)}
      conn = get(conn, ~p"/users/#{task_user.id}/tasks")
      assert html_response(conn, 200) =~ "This is a task record from your database"
    end
  end

  describe "new task for user" do
    setup [:create_user_task]

    test "renders form", %{conn: conn, task_user: task_user, task: task} do
      task_user = %{task_user | id: UUID.load!(task_user.uuid)}
      conn = get(conn, ~p"/users/#{task_user.id}/tasks/new")
      assert html_response(conn, 200) =~ "New Task"
    end
  end

  describe "create task for user" do
    setup [:create_user_task]
    test "redirects to show when data is valid", %{conn: conn, task_user: task_user, task: task} do
      task_user = %{task_user | id: UUID.load!(task_user.uuid)}
      conn = post(conn, ~p"/users/#{task_user.id}/tasks", task: @create_task_attrs)
      assert %{user_id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/users/#{id}/tasks"

      conn = get(conn, ~p"/users/#{id}/tasks")
      assert html_response(conn, 200) =~ "Task"
    end

    test "renders errors when data is invalid", %{conn: conn, task_user: task_user, task: task} do
      task_user = %{task_user | id: UUID.load!(task_user.uuid)}
      conn = post(conn, ~p"/users/#{task_user.id}/tasks", task: @invalid_task_attrs)
      assert html_response(conn, 200) =~ "New Task"
    end
  end

  describe "edit specific user task" do
    setup [:create_user_task]

    test "renders form for editing chosen user", %{conn: conn, task_user: task_user, task: task} do
      task_user = %{task_user | id: UUID.load!(task_user.uuid)}
      task = %{task | task_id: UUID.load!(task.uuid)}
      conn = get(conn, ~p"/users/#{task_user.id}/tasks/#{task.task_id}/edit")
      assert html_response(conn, 200) =~ "Edit Task"
    end
  end

  describe "update specific user task" do
    setup [:create_user_task]

    test "redirects when data is valid", %{conn: conn, task_user: task_user, task: task} do
      task_user = %{task_user | id: UUID.load!(task_user.uuid)}
      task = %{task | task_id: UUID.load!(task.uuid)}
      conn = put(conn, ~p"/users/#{task_user.id}/tasks/#{task.task_id}", task: @update_task_attrs)
      assert redirected_to(conn) == ~p"/users/#{task_user.id}/tasks"
      conn = get(conn, ~p"/users/#{task_user.id}/tasks/#{task.task_id}")
      assert html_response(conn, 200) =~ "some updated description"
    end

    test "renders errors when data is invalid", %{conn: conn, task_user: task_user, task: task} do
      task_user = %{task_user | id: UUID.load!(task_user.uuid)}
      task = %{task | task_id: UUID.load!(task.uuid)}
      conn = put(conn, ~p"/users/#{task_user.id}/tasks/#{task.task_id}", task: @invalid_task_attrs)
      assert html_response(conn, 200) =~ "Edit Task"
    end
  end

  describe "delete specific user task" do
    setup [:create_user_task]

    test "deletes chosen task", %{conn: conn, task_user: task_user, task: task} do
      task_user = %{task_user | id: UUID.load!(task_user.uuid)}
      task = %{task | task_id: UUID.load!(task.uuid)}
      conn = delete(conn, ~p"/users/#{task_user.id}/tasks/#{task.task_id}")
      assert redirected_to(conn) == ~p"/users/#{task_user.id}/tasks"
    end
  end

  describe "user_logout" do
    setup [:create_user]
    test "logs the user out", %{conn: conn, user: user} do
      conn = conn |> get(~p"/logout/user")
      assert redirected_to(conn) == ~p"/login"
      refute get_session(conn, :current_user)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Logged out successfully"
    end
  end

  defp create_user(_) do
    user = user_fixture()
    %{user: user}
  end

  defp create_user_task(_) do
    {task_user, task} = user_task_fixture()
    %{task_user: task_user, task: task}
  end

end
