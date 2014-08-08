defmodule Survivor.Strategy do
  def empty() do
    []
  end

  def with_pick(strategy, pick) do
    [pick|strategy]
  end

  # TODO this (and aux functions) are probably slow, revisit
  def is_legal(strategy) do
    no_repeat_winners(strategy) and no_triple_losers(strategy)
  end

  defp no_repeat_winners(strategy) do
    winners = strategy |> Enum.map(&Survivor.Pick.winner(&1))
    uniq_winners = winners |> Enum.uniq()
    length(winners) == length(uniq_winners)
  end

  defp no_triple_losers(strategy) do
    losers = strategy |> Enum.map(&Survivor.Pick.loser(&1))
    loser_groups = Enum.group_by losers, (fn l -> l end)
    Dict.values(loser_groups) |> Enum.all? (fn gp -> Enum.count(gp) <= 3 end)
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