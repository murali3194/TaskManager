defmodule Taskmanager.Schema.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field(:first_name, :string)
    field(:last_name, :string)
    field(:email_id, :string)
    field(:contact, :integer)
    field(:uuid, :binary)
    has_many(:task, Taskmanager.Schema.Task)
    timestamps([type: :utc_datetime])
  end

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [:first_name, :last_name, :email_id, :contact, :uuid])
    |> validate_required([:first_name, :last_name, :email_id, :contact, :uuid])
  end

end
