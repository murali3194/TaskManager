# TaskManager App
 > Task management web application will allow users to create, update, delete, and list tasks.The application will support multiple users, with each user having their own set of tasks.
## Installing / Getting started

 To run this project, you will need to install the following dependencies on your system:
 * [Elixir](https://elixir-lang.org/install.html)
 * [Phoenix](https://hexdocs.pm/phoenix/installation.html)
 * [SQLite](https://www.sqlite.org/download.html)
 * [Node.js](https://nodejs.org/en)

 ### **Frontend**
 ---
  Used Tailwind Css Components using [Flowbite](https://flowbite.com/docs/getting-started/phoenix/)

  ```shell
    npm install # inside the ./assets/ folder install the Flowbite package using NPM
  ```
  For reference visit [Flowbite](https://flowbite.com/docs/getting-started/phoenix/) from your browser.

 ### **To start your Phoenix server**
 ---

  ```shell
  mix deps.get  # installs the dependencies
  mix ecto.create  # creates the database.
  mix ecto.migrate  # run the database migrations.
  mix phx.server or iex -S mix phx.server  # runs the application.
  ```

  Now you can visit [`localhost:4000/login`](http://localhost:4000/users) from your browser.
  
  ### **Tests**
  ---

  To run the tests for this project, simply run in your terminal:

  ```shell
  mix test
  ```
  