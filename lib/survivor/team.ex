defmodule Survivor.Team do
  defstruct name: ""

  def load_all_from_disk do
    all = [
     %Survivor.Team{name: "CHI"},
     %Survivor.Team{name: "DET"},
     %Survivor.Team{name: "GB"},
     %Survivor.Team{name: "MIN"},

     %Survivor.Team{name: "ATL"},
     %Survivor.Team{name: "CAR"},
     %Survivor.Team{name: "NO"},
     %Survivor.Team{name: "TB"},

     %Survivor.Team{name: "DAL"},
     %Survivor.Team{name: "NYG"},
     %Survivor.Team{name: "PHI"},
     %Survivor.Team{name: "WAS"},

     %Survivor.Team{name: "ARI"},
     %Survivor.Team{name: "SF"},
     %Survivor.Team{name: "SEA"},
     %Survivor.Team{name: "STL"},

     %Survivor.Team{name: "BAL"},
     %Survivor.Team{name: "CIN"},
     %Survivor.Team{name: "CLE"},
     %Survivor.Team{name: "PIT"},

     %Survivor.Team{name: "HOU"},
     %Survivor.Team{name: "IND"},
     %Survivor.Team{name: "JAC"},
     %Survivor.Team{name: "TEN"},

     %Survivor.Team{name: "BUF"},
     %Survivor.Team{name: "MIA"},
     %Survivor.Team{name: "NE"},
     %Survivor.Team{name: "NYJ"},

     %Survivor.Team{name: "DEN"},
     %Survivor.Team{name: "KC"},
     %Survivor.Team{name: "OAK"},
     %Survivor.Team{name: "SD"},
    ]

    Enum.group_by all, fn team -> team.name end
  end

  def get(teams, name) do
    {:ok, [team|_]} = Dict.fetch(teams, name)
    team
  end
end