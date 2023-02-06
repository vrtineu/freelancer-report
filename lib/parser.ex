defmodule GenReport.Parser do
  def parse_file(file) do
    "reports/#{file}"
    |> File.stream!()
    |> Stream.map(fn line -> parse_line(line) end)
  end

  defp parse_line(line) do
    line
    |> String.trim()
    |> String.split(",")
    |> transform_list()
  end

  defp transform_list([head | tail]) do
    [String.downcase(head) | Enum.map(tail, &String.to_integer/1)]
    |> List.update_at(3, &parse_month/1)
  end

  defp parse_month(month_number) do
    case month_number do
      1 -> "janeiro"
      2 -> "fevereiro"
      3 -> "março"
      4 -> "abril"
      5 -> "maio"
      6 -> "junho"
      7 -> "julho"
      8 -> "agosto"
      9 -> "setembro"
      10 -> "outubro"
      11 -> "novembro"
      12 -> "dezembro"
    end
  end
end
