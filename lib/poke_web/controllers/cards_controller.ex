defmodule PokeWeb.CardsController do
  use PokeWeb, :controller

  def index_151(conn, _params) do
    cards = Poke.Scraper.fetch_151_cards()
    render(conn, :index_151, cards: cards, page_title: "Pokemon 151 Set")
  end

  def index_all(conn, _params) do
    cards = Poke.Scraper.fetch_all_cards()
    render(conn, :index_all, cards: cards, page_title: "All Pokemon Cards")
  end
end
