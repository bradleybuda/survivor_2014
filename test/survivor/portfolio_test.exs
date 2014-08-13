defmodule Survivor.PortfolioTest do
  use ExUnit.Case, async: true
  import Survivor.Portfolio

  setup do
    teams = Survivor.Team.load_all_from_disk
    {:ok, schedule: Survivor.Schedule.load_from_disk(teams)}
  end

  test "create an empty portfolio" do
    empty_with_entries(3)
  end

  test "a single-entry portfolio has a survival probability", %{schedule: schedule} do
    all = Survivor.Entry.all(schedule) |> Enum.to_list
    [_, _, week_3_strategies|_] = all
    portfolio = week_3_strategies |> Enum.take(1)
    [entry] = portfolio

    assert survival_probability(portfolio) == Survivor.Entry.survival_probability(entry)
  end

  test "an empty portfolio has zero survival probability" do
    assert 0.0 == survival_probability(empty_with_entries(0))
  end

  test "a portfolio with completed entries has 100% survival" do
    assert 1.0 == survival_probability(empty_with_entries(4))
  end

  test "a portfolio with three identical entries does not increase survival probability", %{schedule: schedule} do
    all = Survivor.Entry.all(schedule) |> Enum.to_list
    [_, _, week_3_strategies|_] = all
    [entry] = week_3_strategies |> Enum.take(1)
    portfolio = [entry, entry, entry]
    assert_in_delta survival_probability(portfolio), Survivor.Entry.survival_probability(entry), 0.001
  end

  test "a portfolio with opposing picks has 100% survival", %{schedule: schedule} do
    [[game|_]|_] = schedule
    entry_1 = Survivor.Entry.with_pick(Survivor.Entry.empty(), %Survivor.Pick{game: game, home_victory: true})
    entry_2 = Survivor.Entry.with_pick(Survivor.Entry.empty(), %Survivor.Pick{game: game, home_victory: false})
    portfolio = [entry_1, entry_2]
    assert_in_delta survival_probability(portfolio), 1.0, 0.001
  end
end