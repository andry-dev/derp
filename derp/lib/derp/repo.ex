defmodule Derp.Repo do
  use Ecto.Repo,
    otp_app: :derp,
    adapter: Ecto.Adapters.Postgres
end
