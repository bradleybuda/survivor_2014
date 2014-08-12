defmodule Survivor.Pick do
  defstruct game: nil, home_victory: false

  def winner(pick) do
    [winner, _] = winner_and_loser pick
    winner
  end

  def loser(pick) do
    [_, loser] = winner_and_loser pick
    loser
  end

  def probability(pick) do
    home_victory_p = Survivor.Game.home_victory_probability(pick.game)

    case pick.home_victory do
      true ->
        home_victory_p
      false ->
        1.0 - home_victory_p
    end
  end

  def not(pick) do
    %{game: pick.game, home_victory: !pick.home_victory}
  end


  defp winner_and_loser(pick) do
    game = pick.game
    teams = [game.home_team, game.away_team]
    case pick.home_victory do
      true ->
        teams
      false ->
        Enum.reverse(teams)
    end
  end

  def show(pick) do
    "#{Survivor.Team.show(winner(pick))} def #{Survivor.Team.show(loser(pick))} (#{pick.game.week})"
  end
end