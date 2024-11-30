defmodule TaskmanagerWeb.UserAuthTest do
  use TaskmanagerWeb.ConnCase
  alias TaskmanagerWeb.UserAuth

  alias Taskmanager.Schema
  import Taskmanager.SchemaFixtures

  describe "redirect_if_user_is_authenticated/2" do
    setup [:create_user]

    test "redirects if user is authenticated", %{conn: conn, user: user} do
      conn = conn |> init_test_session(current_user: user.email_id) |> UserAuth.redirect_if_user_is_authenticated([])
      assert conn.halted
      assert redirected_to(conn) == ~p"/users"
    end

    test "does not redirect if user is not authenticated", %{conn: conn} do
      conn = conn |> put_private(:plug_session, %{}) |> UserAuth.redirect_if_user_is_authenticated([])
      refute conn.halted
      refute conn.status
    end
  end


  describe "require_authenticated_user/2" do
    setup [:create_user]

    test "redirects if user is not authenticated", %{conn: conn} do
      conn = conn |> put_private(:plug_session, %{}) |> fetch_flash() |> UserAuth.require_authenticated_user([])
      assert conn.halted

      assert redirected_to(conn) == ~p"/login"

      assert Phoenix.Flash.get(conn.assigns.flash, :error) ==
               "You must log in to access this page."
    end


    test "does not redirect if user is authenticated", %{conn: conn, user: user} do
      conn = conn |> init_test_session(current_user: user.email_id) |> UserAuth.require_authenticated_user([])
      refute conn.halted
      refute conn.status
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
