defmodule Taskmanager.Repo do
  use Ecto.Repo,
    otp_app: :taskmanager,
    adapter: Ecto.Adapters.SQLite3
end
