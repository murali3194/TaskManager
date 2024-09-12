defmodule Taskmanager.Schema.TaskTest do
  use Taskmanager.DataCase

  alias Ecto.UUID
  alias Taskmanager.Schema.Task

  @valid_attrs %{
    title: "Add New Feature in App",
    description: "Adding pagination in Task list using elixir library",
    due_date: DateTime.now!("Etc/UTC"),
    task_status: "To Do",
    user_id: 1,
    uuid: UUID.bingenerate()
  }

  @invalid_attrs %{}

  describe "changeset of task" do
    test "with valid attributes" do
      changeset = Task.changeset(%Task{}, @valid_attrs)
      IO.inspect(changeset)
      assert changeset.valid?
    end

    test "with invalid attributes" do
      changeset = Task.changeset(%Task{}, @invalid_attrs)
      refute changeset.valid?
    end
  end



end
