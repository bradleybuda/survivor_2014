defmodule Survivor.Strategy do
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
end