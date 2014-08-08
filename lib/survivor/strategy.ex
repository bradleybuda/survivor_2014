defmodule Survivor.Strategy do
  def empty() do
    []
  end

  def with_pick(strategy, pick) do
    [pick|strategy]
  end

  def survival_probability(strategy) do
    case strategy do
      [] ->
        1.0
      [pick|rest] ->
        Survivor.Pick.probability(pick) * survival_probability(rest)
    end
  end

  # TODO this (and aux functions) are probably slow, revisit
  def is_legal(strategy) do
    winners_okay = Dict.values(win_counts(strategy)) |> Enum.all? &(&1 <= 1)
    losers_okay = Dict.values(loss_counts(strategy)) |> Enum.all? &(&1 <= 3)
    winners_okay and losers_okay
  end

  defp win_counts(strategy) do
    case strategy do
      [] ->
        %{}
      [pick|rest] ->
        winner = Survivor.Pick.winner(pick)
        Dict.update(win_counts(rest), winner, 1, &(&1 + 1))
    end
  end

  defp loss_counts(strategy) do
    case strategy do
      [] ->
        %{}
      [pick|rest] ->
        loser = Survivor.Pick.loser(pick)
        Dict.update(loss_counts(rest), loser, 1, &(&1 + 1))
    end
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