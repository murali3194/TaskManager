defmodule Taskmanager.Utils do
  alias Ecto.UUID

  def is_valid_uuid?(uuid) do
    with {:ok, _} <- UUID.cast(uuid) do
      true
    else
      :error ->
        false
    end
  end
end
