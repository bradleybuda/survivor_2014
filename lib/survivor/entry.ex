defmodule Survivor.Entry do
  def empty() do
    []
  end

  def with_pick(entry, pick) do
    [pick|entry]
  end

  def survival_probability(entry) do
    case entry do
      [] ->
        1.0
      [pick|rest] ->
        Survivor.Pick.probability(pick) * survival_probability(rest)
    end
  end

  def is_legal(entry) do
    Dict.values(team_pick_counts(entry)) |> Enum.all? fn team_pick_count ->
      case team_pick_count do
        {wins, losses} when wins > 1 or losses > 3 ->
          false
        _ ->
          true
      end
    end
  end

  defp team_pick_counts(entry) do
    case entry do
      [] ->
        %{}
      [pick|rest] ->
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

  def successors(entry, week_schedule) do
    week_schedule |>
      Stream.flat_map(&Survivor.Game.picks_for_game(&1)) |>
      Stream.map(&with_pick(entry, &1)) |>
      Stream.filter(&is_legal(&1)) |>
      Stream.filter(&(survival_probability(&1) > 0.01))
  end

  def show(entry) do
    Survivor.PickSet.show(entry) # TODO better impl
  end
end