defmodule Survivor.PickSetTest do
  use ExUnit.Case, async: true
  import Survivor.PickSet

  test "probability that two independent picks happen together" do
    [week1|_] = Survivor.Schedule.load_from_disk(Survivor.Team.load_all_from_disk)
    [game1,game2|_] = week1
    pick1 = %Survivor.Pick{game: game1, home_victory: true}
    pick2 = %Survivor.Pick{game: game2, home_victory: false}

    pick_set = Enum.reduce [pick1, pick2], empty(), &add(&2, &1)

    p_both = Survivor.Pick.probability(pick1) * Survivor.Pick.probability(pick2)
    assert p_both == probability(pick_set)
  end

  test "probability that the same pick happens twice" do
    [week1|_] = Survivor.Schedule.load_from_disk(Survivor.Team.load_all_from_disk)
    [game1|_] = week1
    pick1 = %Survivor.Pick{game: game1, home_victory: true}
    pick2 = %Survivor.Pick{game: game1, home_victory: true}

    pick_set = Enum.reduce [pick1, pick2], empty(), &add(&2, &1)

    assert Survivor.Pick.probability(pick1) == probability(pick_set)
  end

  test "probability that opposing picks both happen" do
    [week1|_] = Survivor.Schedule.load_from_disk(Survivor.Team.load_all_from_disk)
    [game1|_] = week1
    pick1 = %Survivor.Pick{game: game1, home_victory: true}
    pick2 = Survivor.Pick.not(pick1)

    pick_set = Enum.reduce [pick1, pick2], empty, &add(&2, &1)

    assert 0.0 == probability(pick_set)
  end

  test "empty pick set has equality" do
    assert empty() == empty()
  end

  test "single-entry pick set has equality" do
    [week1|_] = Survivor.Schedule.load_from_disk(Survivor.Team.load_all_from_disk)
    [game1|_] = week1
    pick1 = %Survivor.Pick{game: game1, home_victory: true}

    assert add(empty(), pick1) == add(empty(), pick1)
  end

  test "adding a pick to a set twice doesn't break it" do
    [week1|_] = Survivor.Schedule.load_from_disk(Survivor.Team.load_all_from_disk)
    [game1|_] = week1
    pick1 = %Survivor.Pick{game: game1, home_victory: true}
    pick_set_1 = add(empty(), pick1)
    pick_set_2 = add(pick_set_1, pick1)

    assert pick_set_1 == pick_set_2
  end

  test "two-entry pick set has equality" do
    [week1|_] = Survivor.Schedule.load_from_disk(Survivor.Team.load_all_from_disk)
    [game1,game2|_] = week1
    pick1 = %Survivor.Pick{game: game1, home_victory: true}
    pick2 = %Survivor.Pick{game: game2, home_victory: false}

    pick_set_1 = Enum.reduce [pick1, pick2], empty, &add(&2, &1)
    pick_set_2 = Enum.reduce [pick1, pick2], empty, &add(&2, &1)

    assert pick_set_1 == pick_set_2
  end

  test "order of picks in set does not change its identity" do
    [week1|_] = Survivor.Schedule.load_from_disk(Survivor.Team.load_all_from_disk)
    [game1,game2|_] = week1
    pick1 = %Survivor.Pick{game: game1, home_victory: true}
    pick2 = %Survivor.Pick{game: game2, home_victory: false}

    pick_set_1 = Enum.reduce [pick1, pick2], empty, &add(&2, &1)
    pick_set_2 = Enum.reduce [pick2, pick1], empty, &add(&2, &1)

    assert pick_set_1 == pick_set_2
  end
end