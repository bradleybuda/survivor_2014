defmodule Survivor.PickTest do
  use ExUnit.Case, async: true

  setup do
    teams = Survivor.Team.load_all_from_disk
    den = Survivor.Team.get(teams, "DEN")
    ari = Survivor.Team.get(teams, "ARI")
    game = Survivor.Game.make_game(den, ari, 1)
    {:ok, den: den, ari: ari, game: game}
  end

  test "pick with a home-team winner", %{game: game, den: den} do
    pick = %Survivor.Pick{game: game, home_victory: true}
    assert Survivor.Pick.winner(pick) == den
  end

  test "pick with an away-team winner", %{game: game, ari: ari} do
    pick = %Survivor.Pick{game: game, home_victory: false}
    assert Survivor.Pick.winner(pick) == ari
  end

  test "pick has a probability", %{game: game} do
    pick_den = %Survivor.Pick{game: game, home_victory: true}
    pick_ari = %Survivor.Pick{game: game, home_victory: false}
    sum_of_probabilities = Survivor.Pick.probability(pick_den) + Survivor.Pick.probability(pick_ari)
    assert sum_of_probabilities > 0.999
    assert sum_of_probabilities < 1.001
  end

  test "pick has an inverese",  %{game: game} do
    pick_den = %Survivor.Pick{game: game, home_victory: true}
    pick_ari = Survivor.Pick.not(pick_den)
    sum_of_probabilities = Survivor.Pick.probability(pick_den) + Survivor.Pick.probability(pick_ari)
    assert sum_of_probabilities > 0.999
    assert sum_of_probabilities < 1.001
  end
end