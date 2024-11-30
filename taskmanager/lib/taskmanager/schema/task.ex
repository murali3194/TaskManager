defmodule Taskmanager.Schema.Task do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:task_id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :task_id}

  schema "tasks" do
    field(:title, :string)
    field(:description, :string)
    field(:due_date, :utc_datetime)
    field(:task_status, :string)
    belongs_to(:user, Taskmanager.Schema.User)
    field(:uuid, :binary)
    timestamps([type: :utc_datetime])
  end

  def changeset(task, params \\ %{}) do
    task
    |> cast(params, [:title, :description, :due_date, :task_status, :user_id, :uuid])
    |> validate_required([:title, :description, :due_date, :task_status, :user_id, :uuid])
  end
end
