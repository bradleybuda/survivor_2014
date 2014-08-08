defmodule Survivor.Schedule do
  @doc """
  Returns a list of lists. Each item in the outer list is a week of
  games, each item in the inner list is a `Survivor.Game`.
  """
  def load_from_disk do
    csv = CSVLixir.read(File.read!("data/schedule.csv"))
    [_|data] = csv

    all_games = Enum.map data, fn record ->
      [week_s, away_team_name, home_team_name] = record
      {week, _} = Integer.parse(week_s)
      away_team = Survivor.Team.get(away_team_name)
      home_team = Survivor.Team.get(home_team_name)
      %Survivor.Game{week: week, away_team: away_team, home_team: home_team}
    end

    by_week_dict = Enum.group_by all_games, fn game -> game.week end
    Dict.values(by_week_dict)
  end
end
