defmodule Survivor.Strategy do
  def empty() do
    []
  end

  def with_pick(strategy, pick) do
    [pick|strategy]
  end

  # TODO this is probably slow, revisit
  def is_legal(strategy) do
    winners = strategy |> Enum.map(&Survivor.Pick.winner(&1))
    uniq_winners = winners |> Enum.uniq()
    length(winners) == length(uniq_winners)
  end

  @doc """
  Returns a `Stream` that is the same `length` as `schedule`. Each
  entry is a `Stream` of all possible strategies up to that week.
  """
  def all(schedule) do
    initial_strategies = [empty()]
    Stream.scan schedule, initial_strategies, fn week_schedule, strategies ->
      strategies |> Stream.flat_map &successors(&1, week_schedule)
    end
  end

  def successors(strategy, week_schedule) do
    week_schedule |>
      Stream.flat_map(&Survivor.Game.picks_for_game(&1)) |>
      Stream.map(&with_pick(strategy, &1)) |>
      Stream.filter(&is_legal(&1))
  end
end