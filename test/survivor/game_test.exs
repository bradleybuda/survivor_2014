defmodule Survivor.GameTest do
  use ExUnit.Case, async: true

  test "make picks for a game" do
    den = Survivor.Team.get("DET")
    ari = Survivor.Team.get("ARI")
    game = %Survivor.Game{home_team: den, away_team: ari, week: 1}

    picks = Enum.to_list Survivor.Game.picks_for_game(game)
    assert 2 == length(picks)
    [pick_a, pick_b] = picks
    assert pick_a != pick_b
  end
end