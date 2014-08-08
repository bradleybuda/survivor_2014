defmodule Survivor.Portfolio do
  def empty_with_entries(entry_count) do
    case entry_count do
      0 ->
        []
      _ ->
        [Survivor.Strategy.empty()|empty_with_entries(entry_count - 1)]
    end
  end

  def subportfolios(portfolio) do
    case portfolio do
      [] ->
        [[]]
      [strategy|rest] ->
        without_this_strategy = subportfolios(rest)
        with_this_strategy = without_this_strategy |> Enum.map(&([strategy|&1]))
        with_this_strategy ++ without_this_strategy
    end
  end

  # [{a def b}], [{b def a}]
  # 100% survival probability, but at most one strategy remains
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
end