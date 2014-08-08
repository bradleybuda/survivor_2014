defmodule Survivor.EntryTest do
  use ExUnit.Case, async: true

  test "an empty entry is legal" do
    empty = Survivor.Entry.empty()
    assert Survivor.Entry.is_legal(empty)
  end

  test "a single-pick entry is legal" do
    game = %Survivor.Game{home_team: %Survivor.Team{name: "DET"}, away_team: %Survivor.Team{name: "CHI"}, week: 1}
    pick = %Survivor.Pick{game: game, home_victory: true}
    entry = Survivor.Entry.with_pick(Survivor.Entry.empty(), pick)
    assert Survivor.Entry.is_legal(entry)
  end

  test "legal to pick two different teams" do
    game_1 = %Survivor.Game{home_team: %Survivor.Team{name: "DET"}, away_team: %Survivor.Team{name: "CHI"}, week: 1}
    pick_1 = %Survivor.Pick{game: game_1, home_victory: true}
    game_2 = %Survivor.Game{home_team: %Survivor.Team{name: "SEA"}, away_team: %Survivor.Team{name: "NO"}, week: 2}
    pick_2 = %Survivor.Pick{game: game_2, home_victory: true}
    entry = Survivor.Entry.with_pick(Survivor.Entry.with_pick(Survivor.Entry.empty(), pick_1), pick_2)
    assert Survivor.Entry.is_legal(entry)
  end

  test "illegal to pick the same team twice" do
    game_1 = %Survivor.Game{home_team: %Survivor.Team{name: "DET"}, away_team: %Survivor.Team{name: "CHI"}, week: 1}
    pick_1 = %Survivor.Pick{game: game_1, home_victory: true}
    game_2 = %Survivor.Game{home_team: %Survivor.Team{name: "GB"}, away_team: %Survivor.Team{name: "DET"}, week: 2}
    pick_2 = %Survivor.Pick{game: game_2, home_victory: false}
    entry = Survivor.Entry.with_pick(Survivor.Entry.with_pick(Survivor.Entry.empty(), pick_1), pick_2)
    assert Survivor.Entry.is_legal(entry) == false
  end

  test "illegal to pick against the same team more than 3 times" do
    game_1 = %Survivor.Game{home_team: %Survivor.Team{name: "DET"}, away_team: %Survivor.Team{name: "SF"}, week: 1}
    pick_1 = %Survivor.Pick{game: game_1, home_victory: true}
    game_2 = %Survivor.Game{home_team: %Survivor.Team{name: "SF"}, away_team: %Survivor.Team{name: "STL"}, week: 2}
    pick_2 = %Survivor.Pick{game: game_2, home_victory: false}
    game_3 = %Survivor.Game{home_team: %Survivor.Team{name: "SF"}, away_team: %Survivor.Team{name: "SEA"}, week: 3}
    pick_3 = %Survivor.Pick{game: game_3, home_victory: false}
    game_4 = %Survivor.Game{home_team: %Survivor.Team{name: "PIT"}, away_team: %Survivor.Team{name: "SF"}, week: 4}
    pick_4 = %Survivor.Pick{game: game_4, home_victory: true}

    entry = Survivor.Entry.empty |>
      Survivor.Entry.with_pick(pick_1) |>
      Survivor.Entry.with_pick(pick_2) |>
      Survivor.Entry.with_pick(pick_3) |>
      Survivor.Entry.with_pick(pick_4)

    assert false == Survivor.Entry.is_legal(entry)
  end

  test "empty entry has 32 successors" do
    teams = Survivor.Team.load_all_from_disk
    [week_1|_] = Survivor.Schedule.load_from_disk(teams)
    successors = Survivor.Entry.successors(Survivor.Entry.empty(), week_1)
    assert 32 == length(Enum.to_list(successors))
  end

  test "after first pick, only 31 successors" do
    teams = Survivor.Team.load_all_from_disk
    schedule = Survivor.Schedule.load_from_disk(teams)
    [week1, week2|_] = schedule
    [game1|_] = week1
    pick = %Survivor.Pick{game: game1, home_victory: true}
    entry = Survivor.Entry.with_pick(Survivor.Entry.empty(), pick)
    successors = Survivor.Entry.successors(entry, week2)
    assert 31 == length(Enum.to_list(successors))
  end

  test "lazy list of all possible strategies" do
    teams = Survivor.Team.load_all_from_disk
    schedule = Survivor.Schedule.load_from_disk(teams)
    Survivor.Entry.all(schedule)
  end

  test "empty entry has a 100% survival probability" do
    assert 1.0 == Survivor.Entry.survival_probability(Survivor.Entry.empty())
  end

  test "entry with one pick has that pick's survival probability" do
    teams = Survivor.Team.load_all_from_disk
    schedule = Survivor.Schedule.load_from_disk(teams)
    all = Survivor.Entry.all(schedule) |> Enum.to_list
    [_, week_1_strategies|_] = all
    [entry|_] = week_1_strategies |> Enum.to_list
    assert Survivor.Entry.survival_probability(entry) < 1.0
  end

  test "entry with multiple picks has union of survival probabilities" do
    teams = Survivor.Team.load_all_from_disk
    schedule = Survivor.Schedule.load_from_disk(teams)
    all = Survivor.Entry.all(schedule) |> Enum.to_list
    [_, _, week_3_strategies|_] = all
    [entry] = week_3_strategies |> Enum.take(1)

    assert Survivor.Entry.survival_probability(entry) < 0.5
  end
end