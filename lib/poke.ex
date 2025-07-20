defmodule Poke do
  @moduledoc """
  Poke keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  @doc """
  Parses the master set HTML file and returns a list of Pokemon cards.

  Returns a list of maps, where each map contains:
  - `:number` - The card number (string)
  - `:name` - The Pokemon name (string)
  - `:rarity` - The card rarity (string)
  - `:card_id` - The unique card ID (string)
  - `:url` - The relative URL to the card page (string)
  - `:title` - The full card title (string)

  ## Examples

      iex> Poke.parse_pokemon_from_html()
      [
        %{
          number: "001",
          name: "Bulbasaur",
          rarity: "Common",
          card_id: "48519",
          url: "/Scarlet-Violet-151-Expansion/Bulbasaur-Card-1",
          title: "Bulbasaur - Scarlet & Violet - 151 #1"
        },
        ...
      ]
  """
  def parse_pokemon_from_html(file_path \\ "priv/static/master_set_html.html") do
    case read_html_file(file_path) do
      {:ok, content} ->
        content
        |> Floki.parse_document!()
        |> Floki.find("li")
        |> Enum.map(&parse_pokemon_card/1)
        |> Enum.reject(&is_nil/1)
        |> Enum.sort_by(& &1.number)

      {:error, reason} ->
        {:error, "Failed to read HTML file: #{reason}"}
    end
  end

  @doc """
  Returns a list of all Pokemon names from the parsed HTML.

  ## Examples

      iex> Poke.get_pokemon_names()
      ["Bulbasaur", "Ivysaur", "Venusaur ex", ...]
  """
  def get_pokemon_names(file_path \\ "priv/static/master_set_html.html") do
    case parse_pokemon_from_html(file_path) do
      {:error, _} = error ->
        error

      pokemon_list ->
        pokemon_list
        |> Enum.map(& &1.name)
        |> Enum.uniq()
    end
  end

  @doc """
  Returns Pokemon grouped by rarity.

  ## Examples

      iex> Poke.get_pokemon_by_rarity()
      %{
        "Common" => [%{name: "Bulbasaur", ...}, ...],
        "Uncommon" => [%{name: "Ivysaur", ...}, ...],
        "Double Rare" => [%{name: "Venusaur ex", ...}, ...]
      }
  """
  def get_pokemon_by_rarity(file_path \\ "priv/static/master_set_html.html") do
    case parse_pokemon_from_html(file_path) do
      {:error, _} = error ->
        error

      pokemon_list ->
        Enum.group_by(pokemon_list, & &1.rarity)
    end
  end

  @doc """
  Finds a Pokemon by its number.

  ## Examples

      iex> Poke.find_pokemon_by_number("001")
      %{number: "001", name: "Bulbasaur", ...}

      iex> Poke.find_pokemon_by_number("999")
      nil
  """
  def find_pokemon_by_number(number, file_path \\ "priv/static/master_set_html.html") do
    case parse_pokemon_from_html(file_path) do
      {:error, _} = error ->
        error

      pokemon_list ->
        Enum.find(pokemon_list, &(&1.number == number))
    end
  end

  @doc """
  Finds Pokemon by name (case-insensitive partial match).

  ## Examples

      iex> Poke.find_pokemon_by_name("bulbasaur")
      [%{name: "Bulbasaur", ...}]

      iex> Poke.find_pokemon_by_name("char")
      [%{name: "Charmander", ...}, %{name: "Charmeleon", ...}, %{name: "Charizard ex", ...}]
  """
  def find_pokemon_by_name(search_name, file_path \\ "priv/static/master_set_html.html") do
    case parse_pokemon_from_html(file_path) do
      {:error, _} = error ->
        error

      pokemon_list ->
        search_lower = String.downcase(search_name)

        Enum.filter(pokemon_list, fn pokemon ->
          String.contains?(String.downcase(pokemon.name), search_lower)
        end)
    end
  end

  @doc """
  Returns Pokemon statistics from the parsed HTML.

  ## Examples

      iex> Poke.get_pokemon_stats()
      %{
        total_cards: 207,
        unique_pokemon: 167,
        rarities: %{"Common" => 67, "Uncommon" => 61, ...}
      }
  """
  def get_pokemon_stats(file_path \\ "priv/static/master_set_html.html") do
    case parse_pokemon_from_html(file_path) do
      {:error, _} = error ->
        error

      pokemon_list ->
        rarity_counts =
          pokemon_list
          |> Enum.group_by(& &1.rarity)
          |> Map.new(fn {rarity, cards} -> {rarity, length(cards)} end)

        unique_names =
          pokemon_list
          |> Enum.map(& &1.name)
          |> Enum.uniq()

        %{
          total_cards: length(pokemon_list),
          unique_pokemon: length(unique_names),
          rarities: rarity_counts
        }
    end
  end

  @doc """
  Exports Pokemon data to a CSV file that can be imported into Notion.

  Creates a CSV with the following columns:
  - Number: Card number (e.g., "001")
  - Name: Pokemon name (e.g., "Bulbasaur")
  - Rarity: Card rarity (e.g., "Common")
  - Card ID: Unique card identifier
  - URL: Relative URL to card page
  - Title: Full card title
  - Set: Always "Scarlet & Violet - 151" (extracted from title)
  - Owned: Empty column for tracking collection status

  ## Examples

      iex> Poke.export_to_csv()
      {:ok, "Pokemon data exported to pokemon_cards.csv (207 cards)"}

      iex> Poke.export_to_csv("my_pokemon.csv")
      {:ok, "Pokemon data exported to my_pokemon.csv (207 cards)"}
  """
  def export_to_csv(
        output_file \\ "pokemon_cards.csv",
        source_file \\ "priv/static/master_set_html.html"
      ) do
    case parse_pokemon_from_html(source_file) do
      {:error, _} = error ->
        error

      pokemon_list ->
        csv_content = generate_csv_content(pokemon_list)

        case File.write(output_file, csv_content) do
          :ok ->
            {:ok, "Pokemon data exported to #{output_file} (#{length(pokemon_list)} cards)"}

          {:error, reason} ->
            {:error, "Failed to write CSV file: #{reason}"}
        end
    end
  end

  @doc """
  Exports Pokemon data to CSV and returns the CSV content as a string without writing to file.

  ## Examples

      iex> csv_content = Poke.to_csv()
      iex> String.starts_with?(csv_content, "Number,Name,Rarity")
      true
  """
  def to_csv(source_file \\ "priv/static/master_set_html.html") do
    case parse_pokemon_from_html(source_file) do
      {:error, _} = error -> error
      pokemon_list -> generate_csv_content(pokemon_list)
    end
  end

  # Private functions

  defp generate_csv_content(pokemon_list) do
    header = "Number,Name,Rarity,Card ID,URL,Title,Set,Owned\n"

    rows =
      pokemon_list
      |> Enum.map(&pokemon_to_csv_row/1)
      |> Enum.join("\n")

    header <> rows <> "\n"
  end

  defp pokemon_to_csv_row(pokemon) do
    # Extract set name from title (e.g., "Bulbasaur - Scarlet & Violet - 151 #1")
    set_name = extract_set_name(pokemon.title)

    # Escape CSV values (handle commas and quotes)
    [
      pokemon.number,
      escape_csv_value(pokemon.name),
      escape_csv_value(pokemon.rarity),
      pokemon.card_id || "",
      escape_csv_value(pokemon.url || ""),
      escape_csv_value(pokemon.title || ""),
      escape_csv_value(set_name),
      # Empty "Owned" column for user to fill
      ""
    ]
    |> Enum.join(",")
  end

  defp extract_set_name(title) when is_binary(title) do
    # Extract "Scarlet & Violet - 151" from title like "Bulbasaur - Scarlet & Violet - 151 #1"
    case String.split(title, " - ") do
      [_name, set_part | _rest] when set_part != "" ->
        # Remove the card number part (e.g., "151 #1" -> "151")  
        set_part
        |> String.split(" #")
        |> List.first()
        |> then(fn set -> "Scarlet & Violet - #{set}" end)

      _ ->
        # Default fallback
        "Scarlet & Violet - 151"
    end
  end

  defp extract_set_name(_), do: "Scarlet & Violet - 151"

  defp escape_csv_value(value) when is_binary(value) do
    # If value contains comma, newline, or quote, wrap in quotes and escape internal quotes
    if String.contains?(value, [",", "\n", "\r", "\""]) do
      escaped_value = String.replace(value, "\"", "\"\"")
      "\"#{escaped_value}\""
    else
      value
    end
  end

  defp escape_csv_value(value), do: to_string(value)

  defp read_html_file(file_path) do
    case File.read(file_path) do
      {:ok, content} -> {:ok, content}
      {:error, reason} -> {:error, reason}
    end
  end

  defp parse_pokemon_card({_tag, attributes, children}) do
    with {:ok, rarity} <- extract_rarity(attributes),
         {:ok, number} <- extract_number(children),
         {:ok, card_data} <- extract_card_data(children) do
      %{
        number: number,
        name: card_data.name,
        rarity: rarity,
        card_id: card_data.card_id,
        url: card_data.url,
        title: card_data.title
      }
    else
      _ -> nil
    end
  end

  defp parse_pokemon_card(_), do: nil

  defp extract_rarity(attributes) do
    case List.keyfind(attributes, "class", 0) do
      {"class", class_string} ->
        rarity =
          class_string
          |> String.split()
          |> Enum.reject(&(&1 == ""))
          |> List.first()

        {:ok, rarity}

      _ ->
        {:error, :no_class}
    end
  end

  defp extract_number(children) do
    case find_span_with_class(children, "number") do
      {_tag, _attrs, [number_text]} when is_binary(number_text) ->
        {:ok, String.trim(number_text)}

      _ ->
        {:error, :no_number}
    end
  end

  defp extract_card_data(children) do
    case find_span_with_class(children, "name") do
      {_tag, _attrs, name_children} ->
        case find_link_in_children(name_children) do
          {"a", link_attrs, [name]} when is_binary(name) ->
            card_id = extract_card_id(link_attrs)
            url = extract_url(link_attrs)
            title = extract_title(link_attrs)

            {:ok,
             %{
               name: String.trim(name),
               card_id: card_id,
               url: url,
               title: title
             }}

          _ ->
            {:error, :no_link}
        end

      _ ->
        {:error, :no_name_span}
    end
  end

  defp find_span_with_class(children, target_class) do
    Enum.find(children, fn
      {"span", attrs, _} ->
        case List.keyfind(attrs, "class", 0) do
          {"class", class} -> class == target_class
          _ -> false
        end

      _ ->
        false
    end)
  end

  defp find_link_in_children(children) do
    Enum.find(children, fn
      {"a", _, _} -> true
      _ -> false
    end)
  end

  defp extract_card_id(link_attrs) do
    case List.keyfind(link_attrs, "name", 0) do
      {"name", name_value} ->
        name_value
        |> String.replace("card", "")

      _ ->
        nil
    end
  end

  defp extract_url(link_attrs) do
    case List.keyfind(link_attrs, "href", 0) do
      {"href", url} -> url
      _ -> nil
    end
  end

  defp extract_title(link_attrs) do
    case List.keyfind(link_attrs, "title", 0) do
      {"title", title} ->
        title
        |> String.replace("&amp;", "&")
        |> String.replace("♀", "♀")

      _ ->
        nil
    end
  end
end
