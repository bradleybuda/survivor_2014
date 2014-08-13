defmodule Survivor.Entry do
  @moduledoc """
  A single enrty in the pool, with one pick per week. Might be a
  partial entry that has not yet picked the entire season.
  """

  defstruct picks: []

  def empty() do
    %Survivor.Entry{}
  end

  def is_empty?(%Survivor.Entry{} = entry) do
    entry.picks == []
  end

  def with_pick(%Survivor.Entry{} = entry, pick) do
    %Survivor.Entry{picks: [pick|entry.picks]}
  end

  def without_first_pick(%Survivor.Entry{} = entry) do
    [pick|remaining_reversed] = Enum.reverse(entry.picks)
    {pick, %Survivor.Entry{picks: Enum.reverse(remaining_reversed)}}
  end

  def survival_probability(%Survivor.Entry{} = entry) do
    survival_probability_of_picks(entry.picks)
  end

  defp survival_probability_of_picks([]) do
    1.0
  end

  defp survival_probability_of_picks([pick|rest]) do
    Survivor.Pick.probability(pick) * survival_probability_of_picks(rest)
  end

  def is_legal(%Survivor.Entry{} = entry) do
    Dict.values(team_pick_counts(entry.picks)) |> Enum.all? fn team_pick_count ->
      case team_pick_count do
        {wins, losses} when wins > 1 or losses > 3 ->
          false
        _ ->
          true
      end
    end
  end

  defp team_pick_counts([]) do
    %{}
  end

  defp team_pick_counts([pick|rest]) do
    counts = team_pick_counts(rest)
    winner = Survivor.Pick.winner(pick)
    loser = Survivor.Pick.loser(pick)

    dict_with_winner = Dict.update counts, winner, {1, 0}, fn r ->
      {wins, losses} = r
      {wins + 1, losses}
    end

    Dict.update dict_with_winner, loser, {0, 1}, fn r ->
      {wins, losses} = r
      {wins, losses + 1}
    end
  end

  @doc """
  Returns a `Stream` that is the same `length` as `schedule`. Each
  entry is a `Stream` of all possible entries up to that week.
  """
  def all(schedule) do
    Stream.scan schedule, [empty()], fn week_schedule, entries ->
     Stream.flat_map entries, &successors(&1, week_schedule)
    end
  end

  def successors(%Survivor.Entry{} = entry, week_schedule) do
    week_schedule |>
      Stream.flat_map(&Survivor.Game.picks_for_game(&1)) |>
      Stream.map(&with_pick(entry, &1)) |>
      Stream.filter(&is_legal(&1)) |>
      Stream.filter(&(survival_probability(&1) > 0.01))
  end
end

#defimpl Enumerable, for: Survivor.Entry do
#  def count(entry) do
#    Enum.count(entry.picks)
#  end

#  def member?(entry, item) do
#    Enum.member?(entry.picks, item)
#  end

#  def reduce(entry, acc, func) do
#    Enum.reduce(entry.picks, acc, func)
#  end
#end