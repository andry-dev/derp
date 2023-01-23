defmodule DerpWeb.ProfileController do
  use DerpWeb, :controller

  alias Derp.Accounts
  alias Derp.Accounts.User

  def index(conn, _params) do
    user = conn.assigns.current_user
    render(conn, "index.html", user: user)
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, "show.html", user: user)
  end

end
