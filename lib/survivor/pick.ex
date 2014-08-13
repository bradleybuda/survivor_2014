defmodule Survivor.Pick do
  defstruct game: nil, home_victory: false

  def winner(pick) do
    team_with_result pick.game, pick.home_victory, :winner
  end

  def loser(pick) do
    team_with_result pick.game, pick.home_victory, :loser
  end

  defp team_with_result(game, true, :winner), do: game.home_team
  defp team_with_result(game, false, :winner), do: game.away_team
  defp team_with_result(game, true, :loser), do: game.away_team
  defp team_with_result(game, false, :loser), do: game.home_team

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
    %{pick | home_victory: !pick.home_victory}
  end
end

defimpl Inspect, for: Survivor.Pick do
  def inspect(pick, _) do
    # TODO use Inspect.Algebra
    "#{inspect Survivor.Pick.winner(pick)} def #{inspect Survivor.Pick.loser(pick)} (#{pick.game.week})"
  end
end