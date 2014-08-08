defmodule Survivor.Game do
  # TODO not sure if we need the week ordinal given the schedule context
  defstruct home_team: nil, away_team: nil, week: 0

  def picks_for_game(game) do
    [false, true] |> Stream.map fn home_victory ->
      %Survivor.Pick{game: game, home_victory: home_victory}
    end
  end
end