defmodule TaskmanagerWeb.UserAuth do
  use TaskmanagerWeb, :verified_routes

  import Plug.Conn

  import Phoenix.Controller

  @doc """
    Used for routes that require the user to not be authenticated.
    """
    def redirect_if_user_is_authenticated(conn, _opts) do
      if conn.private.plug_session["current_user"] do
        conn
        |> redirect(to: signed_in_path(conn))
        |> halt()
      else
        conn
      end
    end

    @doc """
    Used for routes that require the user to be authenticated.

    If you want to enforce the user email is confirmed before
    they use the application at all, here would be a good place.
    """
    def require_authenticated_user(conn, _opts) do
      if conn.private.plug_session["current_user"] do
        conn
      else
        conn
        |> put_flash(:error, "You must log in to access this page.")
        |> redirect(to: ~p"/login")
        |> halt()
      end
    end


    defp signed_in_path(_conn), do: ~p"/users"
end
