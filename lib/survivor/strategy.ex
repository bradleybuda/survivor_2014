defmodule Survivor.Strategy do
  defstruct picks: []

  def empty() do
    %Survivor.Strategy{}
  end

  def with_pick(strategy, pick) do
    %Survivor.Strategy{picks: [pick|strategy.picks]}
  end

  def is_legal(strategy) do
    true
  end
end