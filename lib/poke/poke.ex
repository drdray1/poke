defmodule Poke.Client do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://api.pokemontcg.io/v2"

  plug Tesla.Middleware.Headers, [
    {"X-Api-Key", System.get_env("POKEMON_TCG_API_KEY") || ""},
    {"User-Agent", "Elixir Pokemon TCG Client"}
  ]

  plug Tesla.Middleware.JSON
  plug Tesla.Middleware.FollowRedirects
  plug Tesla.Middleware.Logger
end
