defmodule Survivor.Team do
  defstruct name: "", dvoa: nil, bit: nil
  use Bitwise

  def load_all_from_disk do
    csv = CSVLixir.read(File.read!("data/teams.csv"))
    [_|data] = csv

    all = Stream.zip(data, 1..32) |> Enum.map fn record ->
      {[name, dvoa_s], index} = record
      {dvoa, _} = Float.parse(dvoa_s)
      %Survivor.Team{name: name, dvoa: dvoa, bit: (1 <<< index)}
    end

    Enum.group_by all, fn team -> team.name end
  end

  def get(teams, name) do
    {:ok, [team|_]} = Dict.fetch(teams, name)
    team
  end
end

defimpl Inspect, for: Survivor.Team do
  def inspect(team, _) do
    team.name
  end
end