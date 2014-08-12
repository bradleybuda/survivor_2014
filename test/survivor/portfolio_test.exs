defmodule Survivor.PortfolioTest do
  use ExUnit.Case, async: true

  setup do
    teams = Survivor.Team.load_all_from_disk
    {:ok, schedule: Survivor.Schedule.load_from_disk(teams)}
  end

  test "create an empty portfolio" do
    Survivor.Portfolio.empty_with_entries(3)
  end

  test "a single-entry portfolio has a survival probability", %{schedule: schedule} do
    all = Survivor.Entry.all(schedule) |> Enum.to_list
    [_, _, week_3_strategies|_] = all
    portfolio = week_3_strategies |> Enum.take(1)
    [entry] = portfolio

    assert Survivor.Portfolio.survival_probability(portfolio) ==
      Survivor.Entry.survival_probability(entry)
  end

  test "an empty portfolio has zero survival probability" do
    assert 0.0 == Survivor.Portfolio.survival_probability(Survivor.Portfolio.empty_with_entries(0))
  end

  test "a portfolio with completed entries has 100% survival" do
    assert 1.0 == Survivor.Portfolio.survival_probability(Survivor.Portfolio.empty_with_entries(4))
  end

  test "a portfolio with three identical entries does not increase survival probability", %{schedule: schedule} do
    all = Survivor.Entry.all(schedule) |> Enum.to_list
    [_, _, week_3_strategies|_] = all
    [entry] = week_3_strategies |> Enum.take(1)
    portfolio = [entry, entry, entry]
    assert_in_delta Survivor.Portfolio.survival_probability(portfolio), Survivor.Entry.survival_probability(entry), 0.001
  end

  test "a portfolio with opposing picks has 100% survival", %{schedule: schedule} do
    [[game|_]|_] = schedule
    portfolio = [[%Survivor.Pick{game: game, home_victory: true}], [%Survivor.Pick{game: game, home_victory: false}]]
    IO.inspect portfolio
    assert_in_delta Survivor.Portfolio.survival_probability(portfolio), 1.0, 0.001
  end
end