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

  def build_from_many(files) when is_list(files) do
    result =
      files
      |> Task.async_stream(&build/1)
      |> Enum.reduce(acc_report(), fn {:ok, result}, report -> merge_reports(result, report) end)

    {:ok, result}
  end

  def build_from_many, do: {:error, "Insira uma lista de arquivos"}

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

  defp merge_reports(
         %{
           "all_hours" => all_hours,
           "hours_per_month" => hours_per_month,
           "hours_per_year" => hours_per_year
         },
         %{
           "all_hours" => all_hours_acc,
           "hours_per_month" => hours_per_month_acc,
           "hours_per_year" => hours_per_year_acc
         }
       ) do
    all_hours = merge_maps(all_hours, all_hours_acc)
    hours_per_month = merge_maps(hours_per_month, hours_per_month_acc)
    hours_per_year = merge_maps(hours_per_year, hours_per_year_acc)

    build_report(all_hours, hours_per_month, hours_per_year)
  end

  defp merge_maps(map, acc_map) do
    Map.merge(map, acc_map, fn _key, value, acc_value -> sum_map_values(value, acc_value) end)
  end

  defp sum_map_values(value, acc_value) when is_map(value) and is_map(acc_value) do
    merge_maps(value, acc_value)
  end

  defp sum_map_values(value, acc_value) when is_integer(value) and is_integer(acc_value) do
    value + acc_value
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
