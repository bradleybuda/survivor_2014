defmodule Survivor.StrategyTest do
  use ExUnit.Case, async: true

  test "an empty strategy is legal" do
    empty = Survivor.Strategy.empty()
    assert Survivor.Strategy.is_legal(empty)
  end

  test "a single-pick strategy is legal" do
    game = %Survivor.Game{home_team: %Survivor.Team{name: "DET"}, away_team: %Survivor.Team{name: "CHI"}, week: 1}
    pick = %Survivor.Pick{game: game, home_victory: true}
    strategy = Survivor.Strategy.with_pick(Survivor.Strategy.empty(), pick)
    assert Survivor.Strategy.is_legal(strategy)
  end

  test "legal to pick two different teams" do
    game_1 = %Survivor.Game{home_team: %Survivor.Team{name: "DET"}, away_team: %Survivor.Team{name: "CHI"}, week: 1}
    pick_1 = %Survivor.Pick{game: game_1, home_victory: true}
    game_2 = %Survivor.Game{home_team: %Survivor.Team{name: "SEA"}, away_team: %Survivor.Team{name: "NO"}, week: 2}
    pick_2 = %Survivor.Pick{game: game_2, home_victory: true}
    strategy = Survivor.Strategy.with_pick(Survivor.Strategy.with_pick(Survivor.Strategy.empty(), pick_1), pick_2)
    assert Survivor.Strategy.is_legal(strategy)
  end

  test "illegal to pick the same team twice" do
    game_1 = %Survivor.Game{home_team: %Survivor.Team{name: "DET"}, away_team: %Survivor.Team{name: "CHI"}, week: 1}
    pick_1 = %Survivor.Pick{game: game_1, home_victory: true}
    game_2 = %Survivor.Game{home_team: %Survivor.Team{name: "GB"}, away_team: %Survivor.Team{name: "DET"}, week: 2}
    pick_2 = %Survivor.Pick{game: game_2, home_victory: false}
    strategy = Survivor.Strategy.with_pick(Survivor.Strategy.with_pick(Survivor.Strategy.empty(), pick_1), pick_2)
    assert Survivor.Strategy.is_legal(strategy) == false
  end

  test "empty strategy has 32 successors" do
    teams = Survivor.Team.load_all_from_disk
    [week_1|_] = Survivor.Schedule.load_from_disk(teams)
    successors = Survivor.Strategy.successors(Survivor.Strategy.empty(), week_1)
    assert 32 == length(Enum.to_list(successors))
  end

  test "after first pick, only 31 successors" do
    teams = Survivor.Team.load_all_from_disk
    schedule = Survivor.Schedule.load_from_disk(teams)
    [week1, week2|_] = schedule
    [game1|_] = week1
    pick = %Survivor.Pick{game: game1, home_victory: true}
    strategy = Survivor.Strategy.with_pick(Survivor.Strategy.empty(), pick)
    successors = Survivor.Strategy.successors(strategy, week2)
    assert 31 == length(Enum.to_list(successors))
  end

  test "lazy list of all possible strategies" do
    teams = Survivor.Team.load_all_from_disk
    schedule = Survivor.Schedule.load_from_disk(teams)
    Survivor.Strategy.all(schedule)
  end
end