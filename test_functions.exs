# Test the Pokemon parsing functions
alias Poke

IO.puts("=== Testing Pokemon Parsing Functions ===\n")

# Test basic parsing
pokemon_list = Poke.parse_pokemon_from_html()
IO.puts("Total Pokemon parsed: #{length(pokemon_list)}")

# Test get_pokemon_names
names = Poke.get_pokemon_names()
IO.puts("Total unique Pokemon names: #{length(names)}")
IO.puts("First 10 Pokemon names: #{Enum.take(names, 10) |> Enum.join(", ")}")

# Test find_pokemon_by_number
bulbasaur = Poke.find_pokemon_by_number("001")
IO.puts("\nPokemon #001:")
IO.inspect(bulbasaur)

# Test find_pokemon_by_name
char_pokemon = Poke.find_pokemon_by_name("char")
IO.puts("\nPokemon with 'char' in name:")

Enum.each(char_pokemon, fn pokemon ->
  IO.puts("  #{pokemon.number}: #{pokemon.name} (#{pokemon.rarity})")
end)

# Test get_pokemon_by_rarity
by_rarity = Poke.get_pokemon_by_rarity()
IO.puts("\nPokemon by rarity:")

Enum.each(by_rarity, fn {rarity, pokemon_list} ->
  IO.puts("  #{rarity}: #{length(pokemon_list)} cards")
end)

IO.puts("\n=== All tests completed successfully! ===")
