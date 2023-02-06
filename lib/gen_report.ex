defmodule GenReport do
  alias GenReport.Parser

  @names [
    "cleiton",
    "daniele",
    "danilo",
    "diego",
    "giuliano",
    "jakeliny",
    "joseph",
    "mayk",
    "rafael",
    "vinicius"
  ]

  @months [
    "janeiro",
    "fevereiro",
    "março",
    "abril",
    "maio",
    "junho",
    "julho",
    "agosto",
    "setembro",
    "outubro",
    "novembro",
    "dezembro"
  ]

  def build(file) do
    file
    |> Parser.parse_file()
    |> Enum.reduce(acc_report(), fn line, report -> generate_report(line, report) end)
  end

  def build, do: {:error, "Insira o nome de um arquivo"}

  defp generate_report([name, hours, _day, month, year], %{
         "all_hours" => all_hours,
         "hours_per_month" => hours_per_month,
         "hours_per_year" => hours_per_year
       }) do
    all_hours = update_map(all_hours, name, all_hours[name] + hours)

    months_per_user_map =
      update_map(hours_per_month[name], month, hours_per_month[name][month] + hours)

    hours_per_month = update_map(hours_per_month, name, months_per_user_map)

    years_per_user_map =
      update_map(hours_per_year[name], year, hours_per_year[name][year] + hours)

    hours_per_year = update_map(hours_per_year, name, years_per_user_map)

    build_report(all_hours, hours_per_month, hours_per_year)
  end

  defp update_map(map, key, value), do: Map.put(map, key, value)

  defp acc_report do
    all_hours =
      @names
      |> populate_map()

    hours_per_month =
      @names
      |> populate_map(
        @months
        |> populate_map()
      )

    hours_per_year =
      @names
      |> populate_map(
        2016..2020
        |> populate_map()
      )

    build_report(all_hours, hours_per_month, hours_per_year)
  end

  defp populate_map(key, value \\ 0) do
    Enum.into(key, %{}, &{&1, value})
  end

  defp build_report(all_hours, hours_per_month, hours_per_year) do
    %{
      "all_hours" => all_hours,
      "hours_per_month" => hours_per_month,
      "hours_per_year" => hours_per_year
    }
  end
end
