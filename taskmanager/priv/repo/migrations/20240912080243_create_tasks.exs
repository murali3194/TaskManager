defmodule Taskmanager.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add(:title, :string)
      add(:description, :text)
      add(:due_date, :utc_datetime)
      add(:task_status, :string, size: 60)
      add(:user_id, references(:users, on_delete: :delete_all), null: false)
      add(:uuid, :uuid)

      timestamps([type: :utc_datetime])
    end

    create(unique_index(:tasks, [:uuid]))
  end
end
