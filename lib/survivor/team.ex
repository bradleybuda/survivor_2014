defmodule Survivor.Team do
  defstruct name: ""

  def get(name) do
    %Survivor.Team{name: name}
  end
end