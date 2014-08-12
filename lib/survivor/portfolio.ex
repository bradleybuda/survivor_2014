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

  # TODO this should be private
  def possible_outcomes(portfolio) do
    # Base case: no games picked, no subsequent portfolio
    empty_outcome = Dict.put(HashDict.new, [], [])
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
          x = Dict.put(d, Enum.uniq([pick|outcome]), [remaining_entry|outcome_portfolio]) # This entry picks right, stays in portfolio
          Dict.put(x, Enum.uniq([Survivor.Pick.not(pick)|outcome]), outcome_portfolio) # This entry picks wrong, drops from portfolio
        end

        possible_outcomes_recursive(remaining_portfolio, new_outcomes)
    end
  end

  def show(portfolio) do
   Enum.map(portfolio, fn e -> "[#{Survivor.Entry.show(e)}]" end) |> Enum.join(", ")
  end

  # [{a def b}], [{b def a}]
  # 100% survival probability, but at most one entry remains
  #
  # Pportfolio = Pentry1 || Pentry2 || ... || PentryN
  #
  # How is the OR operator defined?
  #
  # Exhaustive:
  # 3 week season, two games a week, four options a week, two portfolio entries
  # Season: [{a vs b}, {c vs d}], [{a vs c}, {d vs b}], [{a vs d}, {b vs c}]
  # # of strategies = 3 * (2 * 2)     = 12
  # # of portfolios = 3 * (2 * 2) * 2 = 24
  # [[A,A,A],[A,A,A]] = P(A,B) * P(A,C) * (P(A,D) or P(A,D)) = P(A,B) * P(A,C) * P(A,D)
  # [[A,A,A],[A,A,D]] = P(A,B) * P(A,C) * (P(A,D) or P(D,A)) = P(A,B) * P(A,C) * 1
  # [[A,A,A],[A,A,B]] = P(A,B) * P(A,C) * (P(A,D) or P(B,C)) = P(A,B) * P(A,C) * (1 - P(D,A)*P(C,B))

  # However the weeks are not independent and cannot simply be
  # composed with multiplication (i.e you can't pick both sides of the
  # same action every single week and get success).
  #
  # Is there any closed-form way to do this?
  #
  # Given a portfolio, each subportfolio in its power set has a
  # probability of making it to next week. Given these probabilities,
  # you can recursively compute the survival of the portfolio across
  # its subportfolios
  #
  # So if you start with a three-entry portfolio, X, Y, Z, you have to calculate the probability of each of these making it to the next week:
  # [(X,Y,Z),(X,Y),(X,Z),(Y,Z),(X),(Y),(Z),()]
  # Noting that those are not independent - if X, Y, and Z share any games in a given week, then they will have correlated survival success / failure
  #
  # Given a set of picks for a week
  #   Find all of the games mentioned by those picks
  #   For each outcome of each game
  #      Find the liklihood of that outcome
  #      Find the list of portfolios that survive under that outcome
  #      Accumulate the collective probability of that subportfolio surviving

  # Need an AND operator for picks
  # Need a NOT operator for picks
  # Need an each_subportfolio for portfolio
  # Need a probability for subportfolio method

  # Projecting a portfolio forward in time creates a tree with each
  # node a portfolio and each edge a probability that you will
  # transition from one living portfolio to another. The set of nodes
  # is the power set of the entries in the portfolio across weeks. Due
  # to conflicting picks, the transition probabilities are sometimes
  # zero (i.e. there is no way to get from portfolio X in week 2 to
  # portfolio Y in week 3).

  # Maybe the model is wrong. Curently we have a pick (the atom), an
  # entry (has many picks, one per week), and a portfolio (has many
  # entries). Instead we could invert this and have a pick (an atom),
  # a pick set (one or more picks in a given week) and a portfolio (a
  # list of pick sets, one per week). The portfolio has a maximum pick
  # set size. The confusing thing about this is that it's a little
  # harder to keep track of the pick constraints from week to week.

  # See if I can write the portfolio logic imperatively, then convert
  # to functional / recursive / mathematical definition
end