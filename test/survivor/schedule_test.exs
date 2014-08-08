defmodule Survivor.ScheduleTest do
  use ExUnit.Case, async: true

  test "can load schedule data" do
    schedule = Survivor.Schedule.load_from_disk(Survivor.Team.load_all_from_disk)
    assert length(schedule) == (17)
    [week1|_] = schedule
    assert length(week1) == 16
  end
end