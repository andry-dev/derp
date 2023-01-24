defmodule DerpWeb.ItemshopController do

  use DerpWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

end
