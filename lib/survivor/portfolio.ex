defmodule Survivor.Portfolio do
  def empty() do
    []
  end

  def with_entry(portfolio, entry) do
    [entry|portfolio]
  end

  def all_two_entry(schedule) do
    {:ok, entries} = Survivor.Entry.all(schedule) |> Enum.to_list |> Enum.fetch(1)
    entries_list = Enum.to_list(entries)
    all_two_entry_recur(entries_list)
  end

  defp all_two_entry_recur([first,second]) do
    [[first,second]]
  end

  defp all_two_entry_recur([first|rest]) do
    with_first = Enum.map rest, fn entry -> [first,entry] end
    with_first ++ all_two_entry_recur(rest)
  end


  @doc """
  The probability that a portfolio is still alive is the sum of the
  probabilities of any of its subportfolios being alive.
  """

  def survival_probability(portfolio) do
    case portfolio do
      [] ->
        0.0 # An empty portfolio is dead
      [entry] ->
        # Just one entry left, simple math
        Survivor.Entry.survival_probability(entry)
      [entry|_] ->
        # Multiple entries are alive in the portfolio
        if Survivor.Entry.is_empty?(entry) do
          1.0 # We've reached the "end" of this entry, so we've survived!
        else
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
    empty_outcome = Dict.put(HashDict.new, Survivor.PickSet.empty(), Survivor.Portfolio.empty())
    possible_outcomes_recursive(portfolio, empty_outcome)
  end

  defp possible_outcomes_recursive(portfolio, outcomes) do
    case portfolio do
      [] ->
        outcomes # Nothing remaining in the portfolio
      [entry|remaining_portfolio] ->
        {pick,remaining_entry} = Survivor.Entry.without_first_pick(entry)

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
