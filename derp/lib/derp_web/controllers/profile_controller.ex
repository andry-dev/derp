defmodule DerpWeb.ProfileController do
  use DerpWeb, :controller

  alias Derp.Accounts
  alias Derp.Accounts.User

  def index(conn, _params) do
    user = conn.assigns.current_user

    changeset = User.custom_profile_changeset(user, %{})

    render(conn, "index.html", user: user, changeset: changeset)
  end

  def update(conn, %{"user" => user_params}) do
    user = conn.assigns.current_user

    case Accounts.update_profile_customizations(user, user_params) do
      {:ok, _user} ->
        conn
        |> redirect(to: Routes.profile_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "index.html", user: user, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, "show.html", user: user)
  end

end
