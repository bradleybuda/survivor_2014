defmodule Survivor.Entry do
  @moduledoc """
  A single enrty in the pool, with one pick per week. Might be a
  partial entry that has not yet picked the entire season.
  """

  defstruct picks: [], is_legal: true, winners: HashSet.new, one_time_losers: HashSet.new, two_time_losers: HashSet.new, three_time_losers: HashSet.new

  def empty() do
    %Survivor.Entry{}
  end

  def with_pick(%Survivor.Entry{picks: picks, winners: winners, one_time_losers: one_time_losers, two_time_losers: two_time_losers, three_time_losers: three_time_losers}, %Survivor.Pick{} = pick) do
    winner = Survivor.Pick.winner pick
    new_winners = Set.put winners, winner

    loser = Survivor.Pick.loser pick

    is_one_time_loser = Set.member? one_time_losers, loser
    new_one_time_losers = Set.put one_time_losers, loser

    {is_two_time_loser, new_two_time_losers} = if is_one_time_loser do
      {Set.member?(two_time_losers, loser), Set.put(two_time_losers, loser)}
    else
      {false, two_time_losers}
    end

    {is_three_time_loser, new_three_time_losers} = if is_two_time_loser do
      {Set.member?(three_time_losers, loser), Set.put(three_time_losers, loser)}
    else
      {false, three_time_losers}
    end

    is_legal = (!Set.member?(winners, winner)) && !is_three_time_loser

    %Survivor.Entry{picks: [pick|picks], is_legal: is_legal, winners: new_winners, one_time_losers: new_one_time_losers, two_time_losers: new_two_time_losers, three_time_losers: new_three_time_losers}
  end

  def is_empty?(%Survivor.Entry{} = entry) do
    entry.picks == []
  end

  def without_first_pick(%Survivor.Entry{} = entry) do
    # TODO this reversing feels broken
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
    entry.is_legal
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
    ordered_picks_for_week = week_schedule |>
      Enum.flat_map(&Survivor.Game.picks_for_game(&1)) |>
      Enum.sort_by(&Survivor.Pick.probability(&1), &>=/2)

    # Return a lazy list since it will be large
    Stream.map(ordered_picks_for_week, &with_pick(entry, &1)) |>
      Stream.filter(&is_legal(&1)) |>
      Stream.take_while(&(survival_probability(&1) > 0.01))
  end
end
