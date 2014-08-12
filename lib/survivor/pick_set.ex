defmodule Survivor.PickSet do
  # Utility methods for working with a list of picks from the same
  # week. The list is assumed to be a conjunction - i.e. we expect ALL
  # of the picks in the list to come true. Lists are allowed to be
  # internally inconsistent, in which case they have probability zero.

  def probability(pick_set) do
    probability_with_encounters pick_set, [], []
  end

  defp probability_with_encounters(pick_set, picks_encountered, games_encountered) do
    case pick_set do
      [] ->
        1.0
      [pick|rest] ->
        encountered_pick = Enum.member?(picks_encountered, pick)
        encountered_game = Enum.member?(games_encountered, pick.game)
        case {encountered_pick, encountered_game} do
          {true, true} ->
            # We've already handled this pick so it doesn't contribute to
            # the cumulative probability again
            probability(rest)
          {false, true} ->
            # Uh oh, we've already picked this game the other way. Both outcomes cannot occur
            0.0
          {false, false} ->
            # We haven't seen this game yet, so accumulate the probability
            Survivor.Pick.probability(pick) * probability_with_encounters(rest, [pick|picks_encountered], [pick.game|games_encountered])
        end
    end
  end

  def show(pick_set) do
    Enum.map(pick_set, &Survivor.Pick.show(&1)) |> Enum.join(" & ")
  end
end