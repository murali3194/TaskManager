defmodule TaskmanagerWeb.UserTaskController do
  use TaskmanagerWeb, :controller
  require Logger

  alias Ecto.UUID
  alias Taskmanager.Schema
  alias Taskmanager.Schema.User
  alias Taskmanager.Schema.Task
  alias Taskmanager.Utils



  def user_login_page(conn, _params) do
    try do
      Logger.debug("[UserTaskController] Login Page")
      render(conn, :login, error_message: nil)
    rescue
      e in RuntimeError -> e.message
    end
  end

  def user_login(conn, %{"user" => user_params}) do
    %{"email_id" => email} = user_params
    with nil <- Schema.get_user_by_email(email) do
        Logger.warning("[UserTaskController] Invalid Email")
        conn
        |> render(:login, error_message: "Invalid Email please register the user")
    else
      user ->
        Logger.debug("[UserTaskController] User Logged In")
        conn
        |> put_session(:current_user, user.email_id)
        |> put_flash(:info, "Logged in successfully")
        |> redirect(to: ~p"/users")
    end
  end


  def new_register_user(conn, params) do
      changeset = Schema.change_user(%User{})
      useraction = "register"
      Logger.debug("[UserTaskController] Register User Form")
      render(conn, :new, changeset: changeset, useraction: useraction)
  end

  def register_user(conn, %{"user" => user_params}) do
    case Schema.create_user(Map.put(user_params, "uuid", UUID.bingenerate())) do
      {:ok, user} ->
        user = update_user_id(user)
        Logger.debug("[UserTaskController] Logs in Registered User")
        conn
        |> put_session(:current_user, user.email_id)
        |> put_flash(:info, "User #{user.first_name} Registered successfully.")
        |> redirect(to: ~p"/users/#{user}")
      {:error, changeset} ->
        Logger.error(changeset.errors)
        useraction = "register"
        conn
        |> put_status(:bad_request)
        render(conn, :new, changeset: changeset, useraction: useraction)
    end
  end

  def new_user(conn, params) do
    changeset = Schema.change_user(%User{})
    useraction = "create"
    Logger.debug("[UserTaskController] New User Form")
    render(conn, :new, changeset: changeset, useraction: useraction)

  end


  defp update_user_id(user), do: Map.replace(user, :id, UUID.load!(user.uuid))

  @spec create_user(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def create_user(conn, %{"user" => user_params}) do
    case Schema.create_user(Map.put(user_params, "uuid", UUID.bingenerate())) do
      {:ok, user} ->
        user = update_user_id(user)
        Logger.debug("[UserTaskController] User Created")
        conn
        |> put_flash(:info, "User #{user.first_name} created successfully.")
        |> redirect(to: ~p"/users/#{user}")
      {:error, changeset} ->
        useraction = "create"
        Logger.error(changeset.errors)
        conn
        |> put_status(:bad_request)
        render(conn, :new, changeset: changeset, useraction: useraction)
    end
  end

  def get_user(id) do
    with true <- Utils.is_valid_uuid?(id) do
      IO.puts "came inside the user with id: #{id}"
      id = UUID.dump!(id)
      with nil <- Schema.get_user_by_uuid(id) do
        Logger.warn("[UserTaskController] User doesn't exist")
        nil
      else
        user ->
          Logger.debug("[UserTaskCotroller] Fetched the User")
          user
      end
    else
      false ->
        Logger.warn("[UserTaskController]  Invalid User Id")
        :error
    end
  end

  @spec show_user(Plug.Conn.t(), map) :: Plug.Conn.t()
  def show_user(conn, %{"id" => id}) do
    case get_user(id) do
      nil ->
        conn
        |> put_flash(:error, "User doesn't exist.")
        |> redirect(to: ~p"/users")

      :error ->
        conn
        |> put_flash(:error, "User doesn't exist.")
        |> redirect(to: ~p"/users")

      user ->
        with nil <- Schema.get_user_task(user) do
          Logger.warn("[UserTaskController] User Task doesn't exist")
          conn
          |> put_flash(:error, "User Task doesn't exist")
          |> redirect(to: ~p"/users")
        else
          user_task ->
            usertasks = extract_user_details(user_task)
            usertasks = update_uuid_for_user_task(usertasks)
            usertasks = Enum.sort_by(usertasks, &(&1.due_date), DateTime)
            user = extract_user_details(user)
            Logger.debug("[UserTaskController] Shows User Info with Task")
            conn
            |> put_status(:ok)
            |> render(:show, user: user, usertasks: usertasks)
        end
    end
  end




  @spec list_users(Plug.Conn.t(), any) :: Plug.Conn.t()
  def list_users(conn, _params) do
    users =  Schema.list_users()
    users = extract_all_user_details(users)
    users = Enum.sort_by(users, &(&1.inserted_at), {:desc, DateTime})
    Logger.debug("[UserTaskController] Listall Users")
    conn
    |> put_status(:ok)
    |> render(:index, users: users)
  end

  defp extract_all_user_details(users) do
    Enum.map(users, fn user ->
      %{user | id: UUID.load!(user.uuid)}
    end)
  end

  defp extract_user_details(users) do
    %{users | id: UUID.load!(users.uuid)}
  end


  def edit_user(conn, %{"id" => id}) do
    case get_user(id) do
      nil ->
        conn
        |> put_flash(:error, "User doesn't exist.")
        |> redirect(to: ~p"/users")

      :error ->
        conn
        |> put_flash(:error, "Invalid User Id.")
        |> redirect(to: ~p"/users")
      user ->
        case Schema.change_user(user) do
          changeset ->
            user = extract_user_details(user)
            useraction = "edit"
            Logger.debug("[UserTaskController] Opened User Edit Form")
            conn
            |> render(:edit, user: user, changeset: changeset, useraction: useraction)

          {:error, %Ecto.Changeset{} = changeset} ->
            Logger.error("[UserTaskController] #{changeset.errors}")
            user = extract_user_details(user)
            conn
            |> put_flash(:error, "Unable to Edit User.")
            |> redirect(to: ~p"/users/#{user}")
        end
    end
  end

  @spec update_user(Plug.Conn.t(), nil | maybe_improper_list | map) :: Plug.Conn.t()
  def update_user(conn, %{"id" => id, "user" => user_params} = params) do
    case get_user(id) do
      nil ->
        conn
        |> put_flash(:error, "User doesn't exist.")
        |> redirect(to: ~p"/users")

      :error ->
        conn
        |> put_flash(:error, "Invalid User Id.")
        |> redirect(to: ~p"/users")
      user ->
        case Schema.update_user(user, user_params) do
          {:ok, user} ->
            user = update_user_id(user)
            Logger.debug("[UserTaskController] User Updated")
            conn
            |> put_flash(:info, "User #{user.first_name} updated successfully.")
            |> redirect(to: ~p"/users/#{user}")


          {:error, %Ecto.Changeset{} = changeset} ->
            user = extract_user_details(user)
            useraction = "edit"
            Logger.error(changeset.errors)
            conn
            |> put_flash(:error, "Enter valid User details.")
            |> render(:edit, user: user, changeset: changeset, useraction: useraction)
        end
    end
  end

  @spec delete_user(Plug.Conn.t(), map) :: Plug.Conn.t()
  def delete_user(conn, %{"id" => id}) do
    case get_user(id) do
      nil ->
        conn
        |> put_flash(:error, "User doesn't exist.")
        |> redirect(to: ~p"/users")

      :error ->
        conn
        |> put_flash(:error, "Invalid User Id.")
        |> redirect(to: ~p"/users")

      user ->
        case Schema.delete_user(user) do
          {:ok, user} ->
            user = update_user_id(user)
            email = get_session(conn, :current_user)
            case user.email_id == email do
              true ->
                    Logger.debug("[UserTaskController] User Deleted and Logged out")
                    conn
                    |> put_flash(:info, "User #{user.first_name} deleted successfully.")
                    |> delete_session(:current_user)
                    |> put_flash(:info, "Logged out successfully")
                    |> redirect(to: "/login")
              false ->
                    Logger.debug("[UserTaskController] User Deleted")
                    conn
                    |> put_flash(:info, "User #{user.first_name} deleted successfully.")
                    |> redirect(to: ~p"/users")
            end
          {:error, changeset} ->
            Logger.error(changeset.errors)
            conn
            |> put_flash(:error, "Unable to Delete User.")
            |> redirect(to: ~p"/users")
        end
    end
  end

  # Task functions starts from here

  def open_new_task_for_specific_user(conn, %{"user_id" => user_id} = params) do
    case get_user(user_id) do
      nil ->
        conn
        |> put_flash(:error, "User doesn't exist.")
        |> redirect(to: ~p"/users")

      :error ->
        conn
        |> put_flash(:error, "Invalid User Id.")
        |> redirect(to: ~p"/users")
      user ->
        user = update_user_id(user)
        changeset = Schema.change_user_task(%Task{}, params)
        Logger.debug("[UserTaskController] Opened New Task Form")
        render(conn, :newtask, changeset: changeset, user: user, taskaction: "create")
    end
  end

  defp update_user_task_id(task), do: Map.replace(task, :task_id, UUID.load!(task.uuid))

  def create_new_task_for_specific_user(conn, %{"user_id" => user_id, "task" => task} = params) do
    case get_user(user_id) do
      nil ->
        conn
        |> put_flash(:error, "User doesn't exist.")
        |> redirect(to: ~p"/users")
      :error ->
        conn
        |> put_flash(:error, "Invalid User Id.")
        |> redirect(to: ~p"/users")
      user ->
        task = Map.put(task, "user_id", user.id)
        task = Map.put(task, "uuid", UUID.bingenerate())
        case Schema.create_user_task(task) do
          {:ok, task} ->
            task = update_user_task_id(task)
            user = update_user_id(user)
            Logger.debug("[UserTaskController] Task Created")
            conn
            |> put_flash(:info, "Task #{task.title} created successfully.")
            |> redirect(to: ~p"/users/#{user}/tasks")
          {:error, changeset} ->
            Logger.error(changeset.errors)
            user = update_user_id(user)
            render(conn, :newtask, changeset: changeset, user: user, taskaction: "create")

        end
    end
  end

  def listall_task_for_specific_user(conn, %{"user_id" => user_id} = params) do
    case get_user(user_id) do
      nil ->
        conn
        |> put_flash(:error, "User doesn't exist.")
        |> redirect(to: ~p"/users")

      :error ->
        conn
        |> put_flash(:error, "Invalid User Id.")
        |> redirect(to: ~p"/users")
      user ->
        user_task = Schema.get_user_task(user)
        usertasks = update_user_id(user_task)
        usertasks = update_uuid_for_user_task(usertasks)
        usertasks = Enum.sort_by(usertasks, &(&1.due_date), DateTime)
        user = update_user_id(user)
        Logger.debug("[UserTaskController] Listall Task For Specific User")
        conn
        |> render(:show, user: user, usertasks: usertasks)
    end

  end

  defp update_task_uuid_details(task, user_uuid) do
    %{task | task_id: UUID.load!(task.uuid), user_id: user_uuid}
  end

  def update_uuid_for_user_task(usertask) do
    user_uuid = usertask.id
    tasks = usertask.task
    Enum.map(tasks, fn task ->
      update_task_uuid_details(task, user_uuid)
    end)
  end

  def show_specific_task_for_specific_user(conn, %{"user_id" => user_id, "task_id" => task_id}) do
    case get_user(user_id) do
      nil ->
        conn
        |> put_flash(:error, "User doesn't exist.")
        |> redirect(to: ~p"/users")

      :error ->
        conn
        |> put_flash(:error, "Invalid Id.")
        |> redirect(to: ~p"/users")
      user ->
        userid = user.id
        case fetch_task_by_uuid(userid, task_id) do
          nil ->
            conn
            |> put_flash(:error, "Task doesn't exist.")
            |> redirect(to: ~p"/users/#{user_id}")
        :error ->
          conn
          |> put_flash(:error, "Invalid Task Id.")
          |> redirect(to: ~p"/users/#{user_id}")

        task ->
             task
             task = %{task | task_id: UUID.load!(task.uuid), user_id: UUID.load!(user.uuid)}
             Logger.debug("[UserTaskController] Shows Specific Task Info")
             conn
             |> put_status(:ok)
             |> render(:showtask, task: task)
        end
    end
  end

  defp fetch_task_by_uuid(user_id, task_id) do
    with true <- Utils.is_valid_uuid?(task_id) do
      with nil <- Schema.get_user_task_by_uuid(user_id, UUID.dump!(task_id)) do
        nil
      else
        task ->
          task
      end
    else
      false ->
        nil
    end
  end

  def edit_specific_task_for_specific_user(conn, %{"user_id" => user_id, "task_id" => task_id}) do
    case get_user(user_id) do
      nil ->
        conn
        |> put_flash(:error, "User doesn't exist.")
        |> redirect(to: ~p"/users")

      :error ->
        conn
        |> put_flash(:error, "Invalid User Id.")
        |> redirect(to: ~p"/users")
      user ->
         userid = user.id
        case fetch_task_by_uuid(userid, task_id) do
          nil ->
            conn
            |> put_flash(:error, "Task doesn't exist.")
            |> redirect(to: ~p"/users/#{user_id}")
        :error ->
          conn
          |> put_flash(:error, "Invalid Task Id.")
          |> redirect(to: ~p"/users/#{user_id}")

        task ->
              task
              user = update_user_id(user)
              changeset = Schema.change_user_task(task, %{})
              task = %{task | task_id: UUID.load!(task.uuid), user_id: UUID.load!(user.uuid)}
              Logger.debug("[UserTaskController] Opened Task Edit Form")
              render(conn, :edittask, changeset: changeset, task: task, user: user, taskaction: "edit")
        end
    end
  end

  def update_specific_task_for_specific_user(conn, %{"user_id" => user_id, "task_id" => task_id, "task" => task_params} = params) do
    case get_user(user_id) do
      nil ->
        conn
        |> put_flash(:error, "User doesn't exist.")
        |> redirect(to: ~p"/users")

      :error ->
        conn
        |> put_flash(:error, "Invalid User Id.")
        |> redirect(to: ~p"/users")
      user ->
        userid = user.id
        case fetch_task_by_uuid(userid, task_id) do
          nil ->
            conn
            |> put_flash(:error, "Task doesn't exist.")
            |> redirect(to: ~p"/users/#{user_id}")
        :error ->
          conn
          |> put_flash(:error, "Invalid Task Id.")
          |> redirect(to: ~p"/users/#{user_id}")
          usertask ->
            case Schema.update_user_task(usertask, task_params) do
              {:ok, task} ->
                          task = %{task | task_id: UUID.load!(task.uuid), user_id: UUID.load!(user.uuid)}
                          Logger.debug("[UserTaskController] Task Updated")
                          conn
                          |> put_flash(:info, "Task #{task.title} updated successfully.")
                          |> redirect(to: ~p"/users/#{task.user_id}/tasks")

              {:error, changeset} ->
                Logger.error(changeset.errors)
                task = %{usertask | task_id: UUID.load!(usertask.uuid), user_id: UUID.load!(user.uuid)}
                user = update_user_id(user)
                render(conn, :edittask, changeset: changeset, task: task, user: user, taskaction: "edit")
              end
        end
    end
  end

  def delete_specific_task_for_specific_user(conn, %{"user_id" => user_id, "task_id" => task_id} = params) do
    case get_user(user_id) do
      nil ->
        conn
        |> put_flash(:error, "User doesn't exist.")
        |> redirect(to: ~p"/users")

      :error ->
        conn
        |> put_flash(:error, "Invalid User Id.")
        |> redirect(to: ~p"/users")
      user ->
        userid = user.id
        case fetch_task_by_uuid(userid, task_id) do
          nil ->
            conn
            |> put_flash(:error, "Task doesn't exist.")
            |> redirect(to: ~p"/users/#{user_id}")
        :error ->
          conn
          |> put_flash(:error, "Invalid Task Id.")
          |> redirect(to: ~p"/users/#{user_id}")

        usertask ->
            usertask
            case Schema.delete_user_task(usertask) do
              {:ok, task} ->
                task = %{task | task_id: UUID.load!(task.uuid), user_id: UUID.load!(user.uuid)}
                Logger.debug("[UserTaskController] Task Deleted")
                conn
                |> put_flash(:info, "Task #{task.title} deleted successfully.")
                |> redirect(to: ~p"/users/#{task.user_id}/tasks")

              {:error, changeset} ->
                Logger.error(changeset.errors)
                user = update_user_id(user)
                conn
                |> put_flash(:info, "Unable to Delete Task.")
                |> redirect(to: ~p"/users/#{user.id}/tasks")
            end
        end
    end
  end

  def user_logout(conn, _params) do
    Logger.debug("[UserTaskController] User Logged out")
    conn
    |> delete_session(:current_user)
    |> put_flash(:info, "Logged out successfully")
    |> redirect(to: "/login")
  end


end
