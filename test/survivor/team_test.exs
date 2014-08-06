defmodule Survivor.TeamTest do
  use ExUnit.Case, async: true

  test "can make a team" do
    detroit = Survivor.Team.get 'DET'
    assert detroit != nil
  end
end