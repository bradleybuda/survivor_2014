defmodule Survivor.Profiler do
  import ExProf.Macro

  def run do
    profile do
      teams = Survivor.Team.load_all_from_disk
      schedule = Survivor.Schedule.load_from_disk(teams)
      all = Survivor.Entry.all(schedule)
      week_strategies = Enum.at all, 3
      listed = week_strategies |> Enum.to_list
      IO.inspect "length: #{length(listed)}"
    end

    :done
  end
end
