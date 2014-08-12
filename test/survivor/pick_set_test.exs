defmodule Survivor.PickSetTest do
  use ExUnit.Case, async: true

  test "probability that two independent picks happen together" do
    [week1|_] = Survivor.Schedule.load_from_disk(Survivor.Team.load_all_from_disk)
    [game1,game2|_] = week1
    pick1 = %Survivor.Pick{game: game1, home_victory: true}
    pick2 = %Survivor.Pick{game: game2, home_victory: false}

    pick_set = Enum.reduce [pick1, pick2], Survivor.PickSet.empty, &Survivor.PickSet.add(&2, &1)

    p_both = Survivor.Pick.probability(pick1) * Survivor.Pick.probability(pick2)
    assert p_both == Survivor.PickSet.probability(pick_set)
  end

  test "probability that the same pick happens twice" do
    [week1|_] = Survivor.Schedule.load_from_disk(Survivor.Team.load_all_from_disk)
    [game1|_] = week1
    pick1 = %Survivor.Pick{game: game1, home_victory: true}
    pick2 = %Survivor.Pick{game: game1, home_victory: true}

    pick_set = Enum.reduce [pick1, pick2], Survivor.PickSet.empty, &Survivor.PickSet.add(&2, &1)

    assert Survivor.Pick.probability(pick1) == Survivor.PickSet.probability(pick_set)
  end

  test "probability that opposing picks both happen" do
    [week1|_] = Survivor.Schedule.load_from_disk(Survivor.Team.load_all_from_disk)
    [game1|_] = week1
    pick1 = %Survivor.Pick{game: game1, home_victory: true}
    pick2 = Survivor.Pick.not(pick1)

    pick_set = Enum.reduce [pick1, pick2], Survivor.PickSet.empty, &Survivor.PickSet.add(&2, &1)

    assert 0.0 == Survivor.PickSet.probability(pick_set)
  end

  test "empty pick set has equality" do
    assert Survivor.PickSet.empty() == Survivor.PickSet.empty()
  end

  test "single-entry pick set has equality" do
    [week1|_] = Survivor.Schedule.load_from_disk(Survivor.Team.load_all_from_disk)
    [game1|_] = week1
    pick1 = %Survivor.Pick{game: game1, home_victory: true}

    assert Survivor.PickSet.add(Survivor.PickSet.empty(), pick1) == Survivor.PickSet.add(Survivor.PickSet.empty(), pick1)
  end

  test "adding a pick to a set twice doesn't break it" do
    [week1|_] = Survivor.Schedule.load_from_disk(Survivor.Team.load_all_from_disk)
    [game1|_] = week1
    pick1 = %Survivor.Pick{game: game1, home_victory: true}
    pick_set_1 = Survivor.PickSet.add(Survivor.PickSet.empty(), pick1)
    pick_set_2 = Survivor.PickSet.add(pick_set_1, pick1)

    assert pick_set_1 == pick_set_2
  end

  test "two-entry pick set has equality" do
    [week1|_] = Survivor.Schedule.load_from_disk(Survivor.Team.load_all_from_disk)
    [game1,game2|_] = week1
    pick1 = %Survivor.Pick{game: game1, home_victory: true}
    pick2 = %Survivor.Pick{game: game2, home_victory: false}

    pick_set_1 = Enum.reduce [pick1, pick2], Survivor.PickSet.empty, &Survivor.PickSet.add(&2, &1)
    pick_set_2 = Enum.reduce [pick1, pick2], Survivor.PickSet.empty, &Survivor.PickSet.add(&2, &1)

    assert pick_set_1 == pick_set_2
  end

  test "order of picks in set does not change its identity" do
    [week1|_] = Survivor.Schedule.load_from_disk(Survivor.Team.load_all_from_disk)
    [game1,game2|_] = week1
    pick1 = %Survivor.Pick{game: game1, home_victory: true}
    pick2 = %Survivor.Pick{game: game2, home_victory: false}

    pick_set_1 = Enum.reduce [pick1, pick2], Survivor.PickSet.empty, &Survivor.PickSet.add(&2, &1)
    pick_set_2 = Enum.reduce [pick2, pick1], Survivor.PickSet.empty, &Survivor.PickSet.add(&2, &1)

    assert pick_set_1 == pick_set_2
  end
end