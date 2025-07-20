defmodule Poke.Repo do
  use Ecto.Repo,
    otp_app: :poke,
    adapter: Ecto.Adapters.Postgres
end
