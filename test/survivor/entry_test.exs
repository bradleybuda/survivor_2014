defmodule Survivor.EntryTest do
  use ExUnit.Case, async: true
  import Survivor.Entry

  setup do
    {:ok, teams: Survivor.Team.load_all_from_disk}
  end

  test "an empty entry is legal" do
    assert is_legal(empty)
  end

  test "a single-pick entry is legal", %{teams: teams} do
    game = Survivor.Game.make_game Survivor.Team.get(teams, "DET"), Survivor.Team.get(teams, "CHI"), 1
    pick = %Survivor.Pick{game: game, home_victory: true}
    entry = with_pick(empty, pick)
    assert is_legal(entry)
  end

  test "legal to pick two different teams", %{teams: teams} do
    game_1 = Survivor.Game.make_game Survivor.Team.get(teams, "DET"), Survivor.Team.get(teams, "CHI"), 1
    pick_1 = %Survivor.Pick{game: game_1, home_victory: true}
    game_2 = Survivor.Game.make_game Survivor.Team.get(teams, "SEA"), Survivor.Team.get(teams, "NO"), 2
    pick_2 = %Survivor.Pick{game: game_2, home_victory: true}
    entry = with_pick(with_pick(empty, pick_1), pick_2)
    assert is_legal(entry)
  end

  test "illegal to pick the same team twice", %{teams: teams} do
    game_1 = Survivor.Game.make_game Survivor.Team.get(teams, "DET"), Survivor.Team.get(teams, "CHI"), 1
    pick_1 = %Survivor.Pick{game: game_1, home_victory: true}
    game_2 = Survivor.Game.make_game Survivor.Team.get(teams, "GB"), Survivor.Team.get(teams, "DET"), 2
    pick_2 = %Survivor.Pick{game: game_2, home_victory: false}
    entry = with_pick(with_pick(empty, pick_1), pick_2)
    assert is_legal(entry) == false
  end

  test "legal to pick against the same team three times", %{teams: teams} do
    game_1 = Survivor.Game.make_game Survivor.Team.get(teams, "DET"), Survivor.Team.get(teams, "SF"), 1
    pick_1 = %Survivor.Pick{game: game_1, home_victory: true}
    game_2 = Survivor.Game.make_game Survivor.Team.get(teams, "SF"), Survivor.Team.get(teams, "STL"), 2
    pick_2 = %Survivor.Pick{game: game_2, home_victory: false}
    game_3 = Survivor.Game.make_game Survivor.Team.get(teams, "SF"), Survivor.Team.get(teams, "SEA"), 3
    pick_3 = %Survivor.Pick{game: game_3, home_victory: false}

    entry = empty |>
      with_pick(pick_1) |>
      with_pick(pick_2) |>
      with_pick(pick_3)

    assert is_legal(entry)
  end

  test "illegal to pick against the same team more than 3 times", %{teams: teams} do
    game_1 = Survivor.Game.make_game Survivor.Team.get(teams, "DET"), Survivor.Team.get(teams, "SF"), 1
    pick_1 = %Survivor.Pick{game: game_1, home_victory: true}
    game_2 = Survivor.Game.make_game Survivor.Team.get(teams, "SF"), Survivor.Team.get(teams, "STL"), 2
    pick_2 = %Survivor.Pick{game: game_2, home_victory: false}
    game_3 = Survivor.Game.make_game Survivor.Team.get(teams, "SF"), Survivor.Team.get(teams, "SEA"), 3
    pick_3 = %Survivor.Pick{game: game_3, home_victory: false}
    game_4 = Survivor.Game.make_game Survivor.Team.get(teams, "PIT"), Survivor.Team.get(teams, "SF"), 4
    pick_4 = %Survivor.Pick{game: game_4, home_victory: true}

    entry = empty |>
      with_pick(pick_1) |>
      with_pick(pick_2) |>
      with_pick(pick_3) |>
      with_pick(pick_4)

    assert false == is_legal(entry)
  end

  test "empty entry has 32 successors" do
    teams = Survivor.Team.load_all_from_disk
    [week_1|_] = Survivor.Schedule.load_from_disk(teams)
    successors = successors(empty, week_1)
    assert 32 == length(Enum.to_list(successors))
  end

  test "after first pick, only 31 successors" do
    teams = Survivor.Team.load_all_from_disk
    schedule = Survivor.Schedule.load_from_disk(teams)
    [week1, week2|_] = schedule
    [game1|_] = week1
    pick = %Survivor.Pick{game: game1, home_victory: true}
    entry = with_pick(empty, pick)
    successors = successors(entry, week2)
    assert 31 == length(Enum.to_list(successors))
  end

  test "lazy list of all possible strategies" do
    teams = Survivor.Team.load_all_from_disk
    schedule = Survivor.Schedule.load_from_disk(teams)
    all(schedule)
  end

  test "empty entry has a 100% survival probability" do
    assert 1.0 == survival_probability(empty)
  end

  test "entry with one pick has that pick's survival probability" do
    teams = Survivor.Team.load_all_from_disk
    schedule = Survivor.Schedule.load_from_disk(teams)
    all = all(schedule) |> Enum.to_list
    [_, week_1_strategies|_] = all
    [entry|_] = week_1_strategies |> Enum.to_list
    assert survival_probability(entry) < 1.0
  end

  test "entry with multiple picks has union of survival probabilities" do
    teams = Survivor.Team.load_all_from_disk
    schedule = Survivor.Schedule.load_from_disk(teams)
    all = all(schedule) |> Enum.to_list
    [_, _, week_3_strategies|_] = all
    [entry] = week_3_strategies |> Enum.take(1)

    assert survival_probability(entry) < 1
  end
end