defmodule Survivor.StrategyTest do
  use ExUnit.Case, async: true

  test "an empty strategy is legal" do
    empty = Survivor.Strategy.empty()
    assert Survivor.Strategy.is_legal(empty)
  end

  test "a single-pick strategy is legal" do
    game = %Survivor.Game{home_team: Survivor.Team.get("DET"), away_team: Survivor.Team.get("CHI"), week: 1}
    pick = %Survivor.Pick{game: game, home_victory: true}
    strategy = Survivor.Strategy.with_pick(Survivor.Strategy.empty(), pick)
    assert Survivor.Strategy.is_legal(strategy)
  end

  test "legal to pick two different teams" do
    game_1 = %Survivor.Game{home_team: Survivor.Team.get("DET"), away_team: Survivor.Team.get("CHI"), week: 1}
    pick_1 = %Survivor.Pick{game: game_1, home_victory: true}
    game_2 = %Survivor.Game{home_team: Survivor.Team.get("SEA"), away_team: Survivor.Team.get("NO"), week: 2}
    pick_2 = %Survivor.Pick{game: game_2, home_victory: true}
    strategy = Survivor.Strategy.with_pick(Survivor.Strategy.with_pick(Survivor.Strategy.empty(), pick_1), pick_2)
    assert Survivor.Strategy.is_legal(strategy)
  end

  test "illegal to pick the same team twice" do
    game_1 = %Survivor.Game{home_team: Survivor.Team.get("DET"), away_team: Survivor.Team.get("CHI"), week: 1}
    pick_1 = %Survivor.Pick{game: game_1, home_victory: true}
    game_2 = %Survivor.Game{home_team: Survivor.Team.get("GB"), away_team: Survivor.Team.get("DET"), week: 2}
    pick_2 = %Survivor.Pick{game: game_2, home_victory: false}
    strategy = Survivor.Strategy.with_pick(Survivor.Strategy.with_pick(Survivor.Strategy.empty(), pick_1), pick_2)
    assert Survivor.Strategy.is_legal(strategy) == false
  end
end