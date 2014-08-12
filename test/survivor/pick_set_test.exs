defmodule Survivor.PickSetTest do
  use ExUnit.Case, async: true

  test "probability that two independent picks happen together" do
    [week1|_] = Survivor.Schedule.load_from_disk(Survivor.Team.load_all_from_disk)
    [game1,game2|_] = week1
    pick1 = %Survivor.Pick{game: game1, home_victory: true}
    pick2 = %Survivor.Pick{game: game2, home_victory: false}

    p_both = Survivor.Pick.probability(pick1) * Survivor.Pick.probability(pick2)
    assert p_both == Survivor.PickSet.probability([pick1, pick2])
  end

  test "probability that the same pick happens twice" do
    [week1|_] = Survivor.Schedule.load_from_disk(Survivor.Team.load_all_from_disk)
    [game1|_] = week1
    pick1 = %Survivor.Pick{game: game1, home_victory: true}
    pick2 = %Survivor.Pick{game: game1, home_victory: true}

    assert Survivor.Pick.probability(pick1) == Survivor.PickSet.probability([pick1, pick2])
  end

  test "probability that opposing picks both happen" do
    [week1|_] = Survivor.Schedule.load_from_disk(Survivor.Team.load_all_from_disk)
    [game1|_] = week1
    pick1 = %Survivor.Pick{game: game1, home_victory: true}
    pick2 = Survivor.Pick.not(pick1)

    assert 0.0 == Survivor.PickSet.probability([pick1, pick2])
  end
end