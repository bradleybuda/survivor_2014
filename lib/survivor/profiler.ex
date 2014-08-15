defmodule Survivor.Profiler do
  import ExProf.Macro

  def profile do
    profile do
      do_work
    end
    :done
  end

  def time do
    :timer.tc(Survivor.Profiler, :do_work, [])
  end

  def fprof do
    :fprof.apply fn -> do_work end, []
    :fprof.profile
    :fprof.analyse
  end

  def do_work do
    teams = Survivor.Team.load_all_from_disk
    schedule = Survivor.Schedule.load_from_disk(teams)
    all = Survivor.Entry.all(schedule)
    week_strategies = Enum.at all, 3
    listed = week_strategies |> Enum.to_list
    IO.inspect "length: #{length(listed)}"
  end
end
