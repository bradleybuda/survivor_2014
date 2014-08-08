defmodule Survivor.PortfolioTest do
  use ExUnit.Case, async: true

  test "create an empty portfolio" do
    Survivor.Portfolio.empty_with_entries(3)
  end

  test "a portfolio of three strategies should have eight subportfolios" do
    portfolio = Survivor.Portfolio.empty_with_entries(3)
    subportfolios = Survivor.Portfolio.subportfolios(portfolio)
    assert length(subportfolios) == 8
  end
end