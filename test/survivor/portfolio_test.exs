defmodule Survivor.PortfolioTest do
  use ExUnit.Case, async: true

  setup do
    teams = Survivor.Team.load_all_from_disk
    {:ok, schedule: Survivor.Schedule.load_from_disk(teams)}
  end

  test "create an empty portfolio" do
    Survivor.Portfolio.empty_with_entries(3)
  end

  test "a portfolio of one strategy should have one subportfolio" do
    portfolio = Survivor.Portfolio.empty_with_entries(1)
    subportfolios = Survivor.Portfolio.subportfolios(portfolio)
    assert length(subportfolios) == 1
  end

  test "a portfolio of two strategies should have three subportfolios" do
    portfolio = Survivor.Portfolio.empty_with_entries(2)
    subportfolios = Survivor.Portfolio.subportfolios(portfolio)
    assert length(subportfolios) == 3
  end

  test "a portfolio of three strategies should have seven non-empty successor subportfolios" do
    portfolio = Survivor.Portfolio.empty_with_entries(3)
    subportfolios = Survivor.Portfolio.subportfolios(portfolio)
    assert length(subportfolios) == 7
  end

  test "a single-entry portfolio has a survival probability", %{schedule: schedule} do
    all = Survivor.Entry.all(schedule) |> Enum.to_list
    [_, _, week_3_strategies|_] = all
    portfolio = week_3_strategies |> Enum.take(1)
    [entry] = portfolio

    assert Survivor.Portfolio.survival_probability(portfolio) ==
      Survivor.Entry.survival_probability(entry)
  end

  test "a two-entry portfolio has a survival probability", %{schedule: schedule} do
    all = Survivor.Entry.all(schedule) |> Enum.to_list
    [_, _, week_3_strategies|_] = all
    portfolio = week_3_strategies |> Enum.take(2)

    # TODO tighter assertion
    assert Survivor.Portfolio.survival_probability(portfolio) < 1.0
  end
end