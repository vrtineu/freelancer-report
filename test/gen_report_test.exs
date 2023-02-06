defmodule GenReportTest do
  use ExUnit.Case

  alias GenReport
  alias GenReport.Support.ReportFixture

  @file_name "gen_report.csv"

  describe "build/1" do
    test "When passing file name return a report" do
      response = GenReport.build(@file_name)

      assert response == ReportFixture.build()
    end

    test "When no filename was given, returns an error" do
      response = GenReport.build()

      assert response == {:error, "Insira o nome de um arquivo"}
    end
  end

  describe "build_from_many/1" do
    test "When passing a list of files it should return their sum" do
      response = GenReport.build_from_many([@file_name, @file_name])

      assert response == {:ok, ReportFixture.build_from_many()}
    end

    test "When no list was given, returns an error" do
      response = GenReport.build_from_many()

      assert response == {:error, "Insira uma lista de arquivos"}
    end
  end
end
