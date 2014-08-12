defmodule Survivor.Portfolio do
  def empty_with_entries(entry_count) do
    case entry_count do
      0 ->
        []
      _ ->
        [Survivor.Entry.empty()|empty_with_entries(entry_count - 1)]
    end
  end

  @doc """

  The probability that a portfolio is still alive is the sum of the
  probabilities of any of its subportfolios being alive.

  """

  # TODO broken
  def survival_probability(portfolio) do
    case portfolio do
      [] ->
        0.0 # An empty portfolio is dead
      [entry] ->
        # Just one entry left, simple math
        Survivor.Entry.survival_probability(entry)
      [entry|_] ->
        # Multiple entries are alive in the portfolio
        case entry do
          [] ->
            1.0 # We've reached the "end" of this entry, so we've survived!
          _ ->
            # The entries still have picks remaining, time for the
            # complex porfolio math
            outcomes = possible_outcomes(portfolio)
            Enum.reduce Dict.keys(outcomes), 0, fn (outcome, cumulative_p) ->
              {:ok, outcome_portfolio} = Dict.fetch(outcomes, outcome)
              # TODO - short-circuit recursion if probability = 0
              cumulative_p + Survivor.PickSet.probability(outcome) * survival_probability(outcome_portfolio)
            end
        end
    end
  end

  @doc """

  Returns a dict showing all of the outcomes for the portfolio this
  week. The keys of the dict are a set of picks, all of which must
  come true for that outcome to transpire (see
  `Survivor.Pick.probability_of_all` to manipulate these keys). The
  values are the remaining portfolios that would result from this set
  of picks (with this week stripped).

  """

  # TODO make me private
  def possible_outcomes(portfolio) do
    # Base case: no games picked, no subsequent portfolio
    empty_outcome = Dict.put(HashDict.new, Survivor.PickSet.empty(), [])
    possible_outcomes_recursive(portfolio, empty_outcome)
  end

  defp possible_outcomes_recursive(portfolio, outcomes) do
    case portfolio do
      [] ->
        outcomes # Nothing remaining in the portfolio
      [entry|remaining_portfolio] ->
        # The portfolios are actually in reverse order, so go find the
        # next chronological game at the end of the list. TODO how do
        # we make this efficient? Feels broken.
        # At least should add some helper methods to entry
        [pick|remaining_reversed] = Enum.reverse(entry)
        remaining_entry = Enum.reverse(remaining_reversed)

        # Take each of the outcomes for this entry and add them to
        # each of the existing outcomes
        new_outcomes = Enum.reduce Dict.keys(outcomes), HashDict.new, fn(outcome, d) ->
          {:ok, outcome_portfolio} = Dict.fetch(outcomes, outcome)

          pick_set_with_correct_pick = Survivor.PickSet.add(outcome, pick)
          x = Dict.put(d, pick_set_with_correct_pick, [remaining_entry|outcome_portfolio]) # This entry picks right, stays in portfolio

          pick_set_with_incorrect_pick = Survivor.PickSet.add(outcome, Survivor.Pick.not(pick))
          Dict.put(x, pick_set_with_incorrect_pick, outcome_portfolio) # This entry picks wrong, drops from portfolio
        end

        possible_outcomes_recursive(remaining_portfolio, new_outcomes)
    end
  end
end
