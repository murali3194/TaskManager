defmodule Taskmanager.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add(:first_name, :string, size: 100)
      add(:last_name, :string, size: 100)
      add(:email_id, :string)
      add(:contact, :bigint)
      add(:uuid, :uuid)

      timestamps([type: :utc_datetime])
    end

    create(unique_index(:users, [:uuid]))

  end
end
