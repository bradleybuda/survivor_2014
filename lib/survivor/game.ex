defmodule Survivor.Game do
  # TODO not sure if we need the week ordinal given the schedule context
  defstruct home_team: nil, away_team: nil, week: 0

  def picks_for_game(game) do
    [false, true] |> Stream.map fn home_victory ->
      %Survivor.Pick{game: game, home_victory: home_victory}
    end
  end

  def home_victory_probability(game) do
    # TODO totally invented win probability function. Replace with
    # something real.

    base_p = 0.55 # Home-field advantage
    dvoa_delta = game.home_team.dvoa - game.away_team.dvoa
    base_p + (dvoa_delta / 2.0)
  end

  def show(game) do
    "#{Survivor.Team.show(game.away_team)} @ #{Survivor.Team.show(game.home_team)} (#{game.week})"
  end
end