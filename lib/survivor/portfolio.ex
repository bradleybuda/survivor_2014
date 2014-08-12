defmodule Survivor.Portfolio do
  def empty_with_entries(entry_count) do
    case entry_count do
      0 ->
        []
      _ ->
        [Survivor.Entry.empty()|empty_with_entries(entry_count - 1)]
    end
  end

  # TODO not sure this method is needed, might be replaced with possible_pick_sets
  def subportfolios(portfolio) do
    case portfolio do
      [entry] ->
        [[entry]]
      [entry|rest] ->
        rest_without_this_entry = subportfolios(rest)
        rest_with_this_entry = rest_without_this_entry |> Enum.map(&([entry|&1]))
        [entry] ++ rest_with_this_entry ++ rest_without_this_entry
    end
  end

  @doc """

  The probability that a portfolio is still alive is the sum of the
  probabilities of any of its subportfolios being alive.

  """

  def survival_probability(portfolio) do
    # get the picks for this week
    this_week_picks = Enum.map portfolio, fn entry ->
      [pick|_] = entry
      pick
    end

    # figure out every possible result for these picks by finding all
    # combinations of negative and positive. some of these will be
    # duplicates, and some will be p=0 (i.e. green bay wins and green
    # bay loses)
    poss = possible_pick_sets(this_week_picks)


  end

  def possible_pick_sets(picks) do
    case picks do
      [pick] ->
        [[pick], [Survivor.Pick.not(pick)]]
      [pick|rest] ->
        Enum.map(possible_pick_sets(rest), &([pick|&1])) ++
          Enum.map(possible_pick_sets(rest), &([Survivor.Pick.not(pick)|&1]))
    end
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