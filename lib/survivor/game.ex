defmodule Survivor.Game do
  # TODO not sure if we need the week ordinal given the schedule context
  defstruct home_team: nil, away_team: nil, week: :no_default, home_victory_probability: :no_default

  def make_game(%Survivor.Team{} = home_team, %Survivor.Team{} = away_team, week) do
    # TODO totally invented win probability function. Replace with
    # something real.

    base_p = 0.55 # Home-field advantage
    dvoa_delta = home_team.dvoa - away_team.dvoa
    p = base_p + (dvoa_delta / 2.0)

    # HACK try to make p values comparable, some kind of
    # floating-point craziness is going on here
    rounded = round(p * 100.0) / 100.0

    %Survivor.Game{home_team: home_team, away_team: away_team, week: week, home_victory_probability: rounded}
  end

  def picks_for_game(game) do
    [false, true] |> Stream.map fn home_victory ->
      %Survivor.Pick{game: game, home_victory: home_victory}
    end
  end

  def home_victory_probability(game) do
    game.home_victory_probability
  end
end

defimpl Inspect, for: Survivor.Game do
  def inspect(game, _) do
    # TODO this should probably use Inspect.Algebra
    "#{inspect game.away_team} @ #{inspect game.home_team} (#{game.week})"
  end
end