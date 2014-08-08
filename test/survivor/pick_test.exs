defmodule Survivor.PickTest do
  use ExUnit.Case, async: true

  setup do
    teams = Survivor.Team.load_all_from_disk
    den = Survivor.Team.get(teams, "DEN")
    ari = Survivor.Team.get(teams, "ARI")
    game = %Survivor.Game{home_team: den, away_team: ari, week: 1}
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

  test "probability that two independent picks happen together" do
    [week1|_] = Survivor.Schedule.load_from_disk(Survivor.Team.load_all_from_disk)
    [game1,game2|_] = week1
    pick1 = %Survivor.Pick{game: game1, home_victory: true}
    pick2 = %Survivor.Pick{game: game2, home_victory: false}

    p_both = Survivor.Pick.probability(pick1) * Survivor.Pick.probability(pick2)
    assert p_both == Survivor.Pick.probability_of_all([pick1, pick2])
  end

  test "probability that the same pick happens twice" do
    [week1|_] = Survivor.Schedule.load_from_disk(Survivor.Team.load_all_from_disk)
    [game1|_] = week1
    pick1 = %Survivor.Pick{game: game1, home_victory: true}
    pick2 = %Survivor.Pick{game: game1, home_victory: true}

    assert Survivor.Pick.probability(pick1) == Survivor.Pick.probability_of_all([pick1, pick2])
  end

  test "probability that opposing picks both happen" do
    [week1|_] = Survivor.Schedule.load_from_disk(Survivor.Team.load_all_from_disk)
    [game1|_] = week1
    pick1 = %Survivor.Pick{game: game1, home_victory: true}
    pick2 = Survivor.Pick.not(pick1)

    assert 0.0 == Survivor.Pick.probability_of_all([pick1, pick2])
  end
end