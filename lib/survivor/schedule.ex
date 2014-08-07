defmodule Survivor.Schedule do
  def load_from_disk do
    csv = CSVLixir.read(File.read!("data/schedule.csv"))
    [_|data] = csv

    Enum.map data, fn record ->
      [week_s, away_team_name, home_team_name] = record
      {week, _} = Integer.parse(week_s)
      away_team = Survivor.Team.get(away_team_name)
      home_team = Survivor.Team.get(home_team_name)
      %Survivor.Game{week: week, away_team: away_team, home_team: home_team}
    end
  end
end
