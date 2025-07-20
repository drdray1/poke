# Test script to debug Pokemon parsing
alias Poke

# Test if file exists
IO.puts("File exists: #{File.exists?("priv/static/master_set_html.html")}")

# Test file reading
case File.read("priv/static/master_set_html.html") do
  {:ok, content} ->
    IO.puts("File read successfully, content length: #{String.length(content)}")

    # Show first 500 characters to see the structure
    IO.puts("\nFirst 500 characters of content:")
    IO.puts(String.slice(content, 0, 500))

    # Try parsing the HTML first
    parsed_html = Floki.parse_document!(content)
    IO.puts("\nHTML parsed successfully")

    # Test HTML parsing with Floki
    li_elements = Floki.find(parsed_html, "li")
    IO.puts("Found #{length(li_elements)} li elements")

    # Show first element structure
    if length(li_elements) > 0 do
      first_element = Enum.at(li_elements, 0)
      IO.puts("First li element:")
      IO.inspect(first_element, limit: :infinity)
    end

  {:error, reason} ->
    IO.puts("Failed to read file: #{reason}")
end

# Test the actual parsing function
IO.puts("\nTesting parse_pokemon_from_html():")
result = Poke.parse_pokemon_from_html()
IO.puts("Result is list: #{is_list(result)}")

if is_list(result) do
  IO.puts("Result length: #{length(result)}")

  if length(result) > 0 do
    IO.puts("First parsed Pokemon:")
    IO.inspect(Enum.at(result, 0))
  end
else
  IO.puts("Result: #{inspect(result)}")
end
