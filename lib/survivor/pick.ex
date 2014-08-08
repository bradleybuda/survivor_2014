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
end