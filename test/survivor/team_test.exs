defmodule Survivor.TeamTest do
  use ExUnit.Case, async: true

  test "can make a team" do
    detroit = Survivor.Team.get 'DET'
    assert detroit != nil
  end

  test "has a list of all teams" do
    teams = Survivor.Team.all()
    assert length(teams) == 32
  end
end