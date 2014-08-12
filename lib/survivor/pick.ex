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

  def probability_of_all(picks) do
    probability_of_all_with_encounters picks, [], []
  end

  defp probability_of_all_with_encounters(picks, picks_encountered, games_encountered) do
    case picks do
      [] ->
        1.0
      [pick|rest] ->
        encountered_pick = Enum.member?(picks_encountered, pick)
        encountered_game = Enum.member?(games_encountered, pick.game)
        case {encountered_pick, encountered_game} do
          {true, true} ->
            # We've already handled this pick so it doesn't contribute to
            # the cumulative probability again
            probability_of_all(rest)
          {false, true} ->
            # Uh oh, we've already picked this game the other way. Both outcomes cannot occur
            0.0
          {false, false} ->
            # We haven't seen this game yet, so accumulate the probability
            probability(pick) * probability_of_all_with_encounters(rest, [pick|picks_encountered], [pick.game|games_encountered])
        end
    end
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
    "#{Survivor.Team.show(winner(pick))} def. #{Survivor.Team.show(loser(pick))} (#{pick.game.week})"
  end
end