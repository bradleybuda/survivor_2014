defmodule Survivor.Strategy do
  # TODO just make strategy a list not a struct
  defstruct picks: []

  def empty() do
    %Survivor.Strategy{}
  end

  def with_pick(strategy, pick) do
    %Survivor.Strategy{picks: [pick|strategy.picks]}
  end

  # TODO revisit perf for this
  def is_legal(strategy) do
    winners = strategy.picks |> Enum.map(&Survivor.Pick.winner(&1))
    uniq_winners = winners |> Enum.uniq()
    length(winners) == length(uniq_winners)
  end

  def successors(strategy) do
    Survivor.Team.all() |> Enum.map(&with_pick(strategy, &1))
  end
end