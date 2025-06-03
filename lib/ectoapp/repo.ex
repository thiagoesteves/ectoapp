defmodule Ectoapp.Repo do
  use Ecto.Repo,
    otp_app: :ectoapp,
    adapter: Ecto.Adapters.Postgres
end
