defmodule Taskmanager.Schema do

  import Ecto.Query, warn: false
  alias Ecto.UUID
  alias Taskmanager.Repo
  alias Ecto.Multi
  alias Taskmanager.Schema.Task
  alias Taskmanager.Schema.User




  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)

  end


  def list_users do
    Repo.all(User)
  end

  def get_user_by_uuid(uuid) do
    query =
      from(user in User,
        where: user.uuid == ^uuid,
        select: user
      )
    query |> Repo.one()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end


  # task functions starts from here

  def create_user_task(attrs \\ %{}) do
    %Task{}
    |> Task.changeset(attrs)
    |> Repo.insert()
  end


  def change_user_task(%Task{} = task, attrs \\ %{}) do
    Task.changeset(task, attrs)
  end

  def get_user_task(user) do
    user
    |> Repo.preload([:task])
  end

  def get_user_task_by_uuid(user_id, task_id) do
    from(
      task in Task,
      where:
        task.user_id == ^user_id and
          task.uuid == ^task_id,
      select: task
    )
    |> Repo.one()
  end

  def get_user_by_email(email) when is_binary(email) do
    query =
      from(user in User,
        where: user.email_id == ^email,
        select: user
      )
    query |> order_by(:id) |> limit(1) |> Repo.one()
  end

  def update_user_task(%Task{} = task, attrs \\ %{}) do
    task
    |> Task.changeset(attrs)
    |> Repo.update()
  end

  def delete_user_task(%Task{} = task) do
    Repo.delete(task)
  end



end
