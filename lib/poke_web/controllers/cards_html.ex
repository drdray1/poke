defmodule PokeWeb.CardsHTML do
  use PokeWeb, :html

  embed_templates "cards_html/*"

  # Helper function to get the average price from card data
  def get_average_price(card) do
    tcg_price = get_tcgplayer_price(card.tcgplayer, card.rarity)
    market_price = get_cardmarket_price(card.market)

    case {tcg_price, market_price} do
      {nil, nil} -> nil
      {price, nil} -> price
      {nil, price} -> price
      {tcg, market} -> (tcg + market) / 2
    end
  end

  defp get_tcgplayer_price(nil, _rarity), do: nil

  defp get_tcgplayer_price(tcgplayer, rarity) do
    normal_price = get_in(tcgplayer, ["prices", "normal", "market"])
    holofoil_price = get_in(tcgplayer, ["prices", "holofoil", "market"])
    reverse_holo_price = get_in(tcgplayer, ["prices", "reverseHolofoil", "market"])
    unlimited_price = get_in(tcgplayer, ["prices", "unlimited", "market"])

    # Prioritize prices based on rarity and what's typically available
    case String.downcase(rarity || "") do
      rarity when rarity in ["common", "uncommon"] ->
        # For common/uncommon, prefer normal or unlimited pricing
        normal_price || unlimited_price || reverse_holo_price || holofoil_price

      rarity when rarity in ["rare", "double rare"] ->
        # For rare cards, normal pricing is still preferred but holofoil is acceptable
        normal_price || holofoil_price || reverse_holo_price || unlimited_price

      _ ->
        # For special rarities, use whatever is available, but still prefer normal
        normal_price || unlimited_price || reverse_holo_price || holofoil_price
    end
  end

  defp get_cardmarket_price(nil), do: nil

  defp get_cardmarket_price(market) do
    # Prefer the most recent/reliable price data
    get_in(market, ["prices", "avg1"]) ||
      get_in(market, ["prices", "avg7"]) ||
      get_in(market, ["prices", "avg30"]) ||
      get_in(market, ["prices", "averageSellPrice"])
  end

  def format_price(nil), do: "N/A"

  def format_price(price) when is_number(price) do
    # Add some basic validation - if price seems unreasonably high for common cards, show a warning
    cond do
      price < 0 -> "N/A"
      # Cap display at $500+ for extremely expensive cards
      price > 500 -> "$500+"
      true -> "$#{:erlang.float_to_binary(price, decimals: 2)}"
    end
  end

  def format_price(_), do: "N/A"
end
