defmodule Survivor.Pick do
  defstruct game: nil, home_victory: false

  def winner(pick) do
    case pick.home_victory do
      true ->
        pick.game.home_team
      false ->
        pick.game.away_team
    end
  end
end