defmodule Taskmanager.Schema.UserTest do
  use Taskmanager.DataCase

  alias Ecto.UUID
  alias Taskmanager.Schema.User

  @valid_attrs %{
    first_name: "Muralidharan",
    last_name: "A",
    email_id: "muralidharan@gmail.com",
    contact: 1234567890,
    uuid: UUID.bingenerate()
  }

  @invalid_attrs %{}

  describe "changeset of user" do
    test "with valid attributes" do
      changeset = User.changeset(%User{}, @valid_attrs)
      assert changeset.valid?
    end

    test "with invalid attributes" do
      changeset = User.changeset(%User{}, @invalid_attrs)
      refute changeset.valid?
    end

  end

end
