defmodule Survivor.TeamTest do
  use ExUnit.Case, async: true

  test "can make a team" do
    detroit = %Survivor.Team{name: 'DET'}
    assert detroit != nil
  end

  test "has a list of all teams" do
    teams = Survivor.Team.load_all_from_disk()
    assert length(Dict.values teams) == 32
  end

  test "can get a team from the list by name" do
    teams = Survivor.Team.load_all_from_disk()
    oakland = Survivor.Team.get(teams, "OAK")
  end
end