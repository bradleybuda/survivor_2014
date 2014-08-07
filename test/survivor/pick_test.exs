defmodule Survivor.PickTest do
  use ExUnit.Case, async: true

  test 'pick with a home-team winner' do
    den = Survivor.Team.get("DET")
    ari = Survivor.Team.get("ARI")
    game = %Survivor.Game{home_team: den, away_team: ari, week: 1}
    pick = %Survivor.Pick{game: game, home_victory: true}
    assert Survivor.Pick.winner(pick) == den
  end

  test 'pick with an away-team winner' do
    den = Survivor.Team.get("DET")
    ari = Survivor.Team.get("ARI")
    game = %Survivor.Game{home_team: den, away_team: ari, week: 1}
    pick = %Survivor.Pick{game: game, home_victory: false}
    assert Survivor.Pick.winner(pick) == ari
  end
end