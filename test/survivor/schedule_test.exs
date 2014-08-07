defmodule Survivor.ScheduleTest do
  use ExUnit.Case, async: true

  test "can load schedule data" do
    schedule = Survivor.Schedule.load_from_disk()
    assert length(schedule) == (32 * 8)
    [game|_] = schedule
    assert game.week == 1
  end
end