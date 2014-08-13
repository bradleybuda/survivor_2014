defmodule Survivor.GameTest do
  use ExUnit.Case, async: true
  import Survivor.Game

  test "make picks for a game" do
    den = %Survivor.Team{name: "DET", dvoa: 0.22}
    ari = %Survivor.Team{name: "ARI", dvoa: 0.12}
    game = make_game(den, ari, 1)

    picks = Enum.to_list picks_for_game(game)
    assert 2 == length(picks)
    [pick_a, pick_b] = picks
    assert pick_a != pick_b
  end
end