defmodule Survivor.Team do
  defstruct name: "", dvoa: nil

  def load_all_from_disk do
    csv = CSVLixir.read(File.read!("data/teams.csv"))
    [_|data] = csv

    all = Enum.map data, fn record ->
      [name,dvoa_s] = record
      {dvoa, _} = Float.parse(dvoa_s)
      %Survivor.Team{name: name, dvoa: dvoa}
    end

    Enum.group_by all, fn team -> team.name end
  end

  def get(teams, name) do
    {:ok, [team|_]} = Dict.fetch(teams, name)
    team
  end
end