# Pokemon Parsing Demo

IO.puts("🎯 Pokemon Card Parsing Demo")
IO.puts("=" |> String.duplicate(50))

# Test basic functionality
stats = Poke.get_pokemon_stats()
IO.puts("📊 Pokemon Statistics:")
IO.puts("   Total Cards: #{stats.total_cards}")
IO.puts("   Unique Pokemon: #{stats.unique_pokemon}")

IO.puts("\n🎨 Rarity Distribution:")

stats.rarities
|> Enum.sort_by(fn {_rarity, count} -> -count end)
|> Enum.each(fn {rarity, count} ->
  IO.puts("   #{rarity}: #{count} cards")
end)

# Test search functionality
IO.puts("\n🔍 Search Examples:")

# Find Charizard cards
charizard_cards = Poke.find_pokemon_by_name("charizard")
IO.puts("   Charizard cards found: #{length(charizard_cards)}")

Enum.each(charizard_cards, fn card ->
  IO.puts("     ##{card.number}: #{card.name} (#{card.rarity})")
end)

# Find specific card
bulbasaur = Poke.find_pokemon_by_number("001")
IO.puts("\n🌱 Pokemon #001:")
IO.puts("   Name: #{bulbasaur.name}")
IO.puts("   Rarity: #{bulbasaur.rarity}")
IO.puts("   Title: #{bulbasaur.title}")

IO.puts("\n✅ All functions working perfectly!")
