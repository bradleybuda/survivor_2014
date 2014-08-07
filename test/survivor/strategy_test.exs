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
end