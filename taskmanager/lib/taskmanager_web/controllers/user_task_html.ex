defmodule TaskmanagerWeb.UserTaskHTML do
  use TaskmanagerWeb, :html

  embed_templates "user_task_html/*"



  @doc """
  Renders a user form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def user_form(assigns)

  @doc """
  Renders a task form
  """

  attr :Changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def user_task_form(assigns)

end
