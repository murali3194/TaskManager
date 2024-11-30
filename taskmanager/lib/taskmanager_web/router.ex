defmodule TaskmanagerWeb.Router do
  use TaskmanagerWeb, :router

  import TaskmanagerWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html", "json"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TaskmanagerWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TaskmanagerWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    # Login page
    get "/login", UserTaskController, :user_login_page
    # Login user
    post "/login/user", UserTaskController, :user_login


    # Opens a new user register form.
    get "/users/new/register", UserTaskController, :new_register_user
    # # Registers a new user.
    post "/users/register", UserTaskController, :register_user


  end


  scope "/", TaskmanagerWeb do
    pipe_through [:browser, :require_authenticated_user]


    # Opens a new user form.
    get "/users/new/create", UserTaskController, :new_user
    # Creates a new user.
    post "/users", UserTaskController, :create_user
    # Retrieve all users.
    get "/users", UserTaskController, :list_users
    # Shows a user detail.
    get "/users/:id", UserTaskController, :show_user
    # Edit a user.
    get "/users/:id/edit", UserTaskController, :edit_user
    # Update a user.
    put "/users/:id", UserTaskController, :update_user
    # Delete a User
    delete "/users/:id", UserTaskController, :delete_user

    # Opens a new task form for specific user.
    get "/users/:user_id/tasks/new", UserTaskController, :open_new_task_for_specific_user
    # Create a new task for the specified user.
    post "/users/:user_id/tasks", UserTaskController, :create_new_task_for_specific_user
    # Retrieve all tasks for the specified user
    get "/users/:user_id/tasks", UserTaskController, :listall_task_for_specific_user
    # Retrieve a specific task for the specified user.
    get "/users/:user_id/tasks/:task_id", UserTaskController, :show_specific_task_for_specific_user
    # Edit a specific task for the specified user.
    get "/users/:user_id/tasks/:task_id/edit", UserTaskController, :edit_specific_task_for_specific_user
    # Update a specific task for the specified user.
    put "/users/:user_id/tasks/:task_id", UserTaskController, :update_specific_task_for_specific_user
    # Delete a specific task for the specified user.
    delete "/users/:user_id/tasks/:task_id", UserTaskController, :delete_specific_task_for_specific_user





    # get "/", PageController, :home

  end

  scope "/", TaskmanagerWeb do
    pipe_through [:browser]

    # Logout user
    get "logout/user", UserTaskController, :user_logout


  end

  # Other scopes may use custom stacks.
  # scope "/api", TaskmanagerWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:taskmanager, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: TaskmanagerWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
