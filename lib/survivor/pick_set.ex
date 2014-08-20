# Utility methods for working with a list of picks from the same
# week. The list is assumed to be a conjunction - i.e. we expect ALL
# of the picks in the list to come true. Lists are allowed to be
# internally inconsistent, in which case they have probability zero.
defmodule Survivor.PickSet do
  defstruct picks: []

  def empty() do
    %Survivor.PickSet{}
  end

  def add(%Survivor.PickSet{} = pick_set, pick) do
    new_picks = Enum.sort(Enum.uniq([pick|pick_set.picks]))
    %Survivor.PickSet{picks: new_picks}
  end

  def probability(pick_set) do
    probability_with_encounters pick_set.picks, [], []
  end

  defp probability_with_encounters(pick_list, picks_encountered, games_encountered) do
    case pick_list do
      [] ->
        1.0
      [pick|rest] ->
        encountered_pick = Enum.member?(picks_encountered, pick)
        encountered_game = Enum.member?(games_encountered, pick.game)
        case {encountered_pick, encountered_game} do
          {true, true} ->
            # We've already handled this pick so it doesn't contribute to
            # the cumulative probability again
            probability_with_encounters(rest, picks_encountered, games_encountered)
          {false, true} ->
            # Uh oh, we've already picked this game the other way. Both outcomes cannot occur
            0.0
          {false, false} ->
            # We haven't seen this game yet, so accumulate the probability
            Survivor.Pick.probability(pick) * probability_with_encounters(rest, [pick|picks_encountered], [pick.game|games_encountered])
        end
    end
  end
end

defimpl Inspect, for: Survivor.PickSet do
  def inspect(pick_set, _) do
    # TODO use algebra
    Enum.map(pick_set.picks, fn p -> inspect p end) |> Enum.join(" & ")
  end
end