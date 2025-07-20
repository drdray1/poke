defmodule Poke.Scraper do
  def fetch_all_cards do
    fetch_scarlet_violet_cards()
  end

  def fetch_151_cards do
    IO.puts("Fetching cards from 151 set...")
    fetch_set_cards("sv3pt5")
  end

  defp fetch_scarlet_violet_cards do
    IO.puts("Fetching Scarlet & Violet cards from pokemontcg.io API...")

    # Include 151 set (sv3pt5) along with the base set
    sv_sets = ["sv1", "sv3pt5"]

    all_cards =
      sv_sets
      |> Enum.flat_map(&fetch_set_cards/1)
      |> Enum.uniq_by(& &1.id)

    IO.puts("Fetched #{length(all_cards)} unique Scarlet & Violet cards")
    all_cards
  end

  defp fetch_set_cards(set_id) do
    IO.puts("Fetching cards from set: #{set_id}")
    fetch_page_cards(set_id, 1, [])
  end

  defp fetch_page_cards(set_id, page, acc) do
    query = %{
      q: "set.id:#{set_id}",
      page: page,
      pageSize: 250
    }

    case Poke.Client.get("/cards", query: query) do
      {:ok, %Tesla.Env{status: 200, body: body}} ->
        # Body is already decoded by Tesla.Middleware.JSON
        case body do
          %{"data" => cards, "totalCount" => total_count} ->
            parsed_cards = Enum.map(cards, &parse_card/1)
            new_acc = acc ++ parsed_cards

            # Check if we need to fetch more pages
            if length(new_acc) < total_count do
              fetch_page_cards(set_id, page + 1, new_acc)
            else
              new_acc
            end

          _ ->
            IO.warn("Unexpected response format for set #{set_id}")
            acc
        end

      {:ok, %Tesla.Env{status: status}} ->
        IO.warn("Unexpected status for set #{set_id}: #{status}")
        acc

      {:error, reason} ->
        IO.warn("HTTP error for set #{set_id}: #{inspect(reason)}")
        acc
    end
  end

  defp parse_card(card_data) do
    %{
      id: card_data["id"],
      name: card_data["name"],
      hp: card_data["hp"],
      types: card_data["types"] || [],
      supertype: card_data["supertype"],
      subtypes: card_data["subtypes"] || [],
      rarity: card_data["rarity"],
      set: %{
        id: get_in(card_data, ["set", "id"]),
        name: get_in(card_data, ["set", "name"]),
        series: get_in(card_data, ["set", "series"])
      },
      number: card_data["number"],
      artist: card_data["artist"],
      images: card_data["images"],
      market: card_data["cardmarket"],
      tcgplayer: card_data["tcgplayer"]
    }
  end
end
