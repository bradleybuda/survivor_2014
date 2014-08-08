defmodule Survivor.Strategy do
  # TODO just make strategy a list not a struct
  defstruct picks: []

  def empty() do
    %Survivor.Strategy{}
  end

  def with_pick(strategy, pick) do
    %Survivor.Strategy{picks: [pick|strategy.picks]}
  end

  # TODO this is probably slow, revisit
  def is_legal(strategy) do
    winners = strategy.picks |> Enum.map(&Survivor.Pick.winner(&1))
    uniq_winners = winners |> Enum.uniq()
    length(winners) == length(uniq_winners)
  end

  def successors(strategy, week_schedule) do
    week_schedule |>
      Stream.flat_map(&Survivor.Game.picks_for_game(&1)) |>
      Stream.map(&with_pick(strategy, &1)) |>
      Stream.filter(&is_legal(&1))
  end
end