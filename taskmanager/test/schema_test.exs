defmodule SchemaTest do
  require Logger
  use Taskmanager.DataCase

  alias Ecto.UUID
  alias Taskmanager.Schema
  alias Taskmanager.Schema.{User, Task}
  import Taskmanager.SchemaFixtures

  describe "users" do

    @invalid_attrs %{contact: nil, email_id: nil, first_name: nil, last_name: nil}

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{
        first_name: "Muralidharan",
        last_name: "A",
        email_id: "muralidharan@gmail.com",
        contact: 1234567890,
        uuid: UUID.bingenerate()
      }

      assert {:ok, %User{} = user} = Schema.create_user(valid_attrs)
      assert user.contact == 1234567890
      assert user.email_id == "muralidharan@gmail.com"
      assert user.first_name == "Muralidharan"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Schema.create_user(@invalid_attrs)
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Schema.change_user(user)
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Schema.list_users() == [user]
    end

    test "get_user_by_uuid/1 returns the user with given id" do
      user = user_fixture()
      assert Schema.get_user_by_uuid(user.uuid) == user
    end

    test "get_user_by_email/1 returns the user with give email" do
      user = user_fixture()
      assert Schema.get_user_by_email(user.email_id) == user
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()

      update_attrs = %{
        first_name: "Muralidharan",
        last_name: "A",
        email_id: "muralidharan@gmail.com",
        contact: 1234567899,
        uuid: UUID.bingenerate()
      }

      assert {:ok, %User{} = user} = Schema.update_user(user, update_attrs)
      assert user.contact == 1234567899
      assert user.email_id == "muralidharan@gmail.com"
      assert user.first_name == "Muralidharan"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Schema.update_user(user, @invalid_attrs)
      assert user.uuid == Schema.get_user_by_uuid(user.uuid).uuid
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Schema.delete_user(user)
      assert Schema.get_user_by_uuid(user.uuid) == nil
    end

  end


  describe "tasks" do
    @invalid_attrs %{description: nil, title: nil, due_date: nil, task_status: nil, user_id: nil, uuid: nil}


    test "create_user_task/1 with valid data creates a user_task" do
      user = user_fixture()
      valid_attrs = %{
        task_id: 1,
        title: "Add New Feature in App",
        description: "Adding pagination in Task list using elixir library",
        due_date: DateTime.utc_now(),
        task_status: "To Do",
        user_id: user.id,
        uuid: UUID.bingenerate()
      }
      assert {:ok, %Task{} = task} = Schema.create_user_task(valid_attrs)
      assert task.task_status == "To Do"
      assert task.title == "Add New Feature in App"
    end

    test "create_user_task/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Schema.create_user_task(@invalid_attrs)
    end

    test "change_user_task/2 returns a task changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Schema.change_user_task(%Task{}, %{user_id: user.id})
    end

    test "get_user_task/1 returns specific task for specific user" do
      {user, task} = user_task_fixture()
      assert user_task = Schema.get_user_task(user)
      assert user_task.task == [task]
    end

    test "update_user_task/2  updates specific task for specific user" do
      {user, task} = user_task_fixture()
      assert {:ok, user_task} = Schema.update_user_task(task)
    end

    test "delete_user_task/1 delete specific task for specific user" do
      {user, task} = user_task_fixture()
      assert {:ok, task} = Schema.delete_user_task(task)
    end

  end


end
