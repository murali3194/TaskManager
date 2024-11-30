defmodule Taskmanager.SchemaFixtures do

  alias Ecto.UUID

  @doc """
  Generate a user.
  """

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into( %{
        first_name: "Muralidharan",
        last_name: "A",
        email_id: "muralidharan@gmail.com",
        contact: 1234567890,
        uuid: UUID.bingenerate()
      })
      |> Taskmanager.Schema.create_user()

      user
  end


  def user_task_fixture(attrs \\ %{}) do
    user = user_fixture()
    {:ok, task} =
      attrs
      |> Enum.into(%{
          task_id: 1,
          title: "Add New Feature in App",
          description: "Adding pagination in Task list using elixir library",
          due_date: DateTime.now!("Etc/UTC"),
          task_status: "To Do",
          user_id: user.id,
          uuid: UUID.bingenerate()
      })
      |> Taskmanager.Schema.create_user_task()

      {user, task}
  end



end
