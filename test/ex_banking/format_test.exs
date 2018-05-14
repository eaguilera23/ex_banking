defmodule ExBanking.FormatTest do
  use ExUnit.Case
  alias ExBanking.Format

  describe "response/1" do
    test "returns money as float" do
      result = 
        {:ok, 4323}
        |> Format.response()

      assert(result == {:ok, 43.23})
    end

    test "returns 2 amounts as float" do
      result =
        {:ok, 4323, 4567}
        |> Format.response()

      assert(result == {:ok, 43.23, 45.67})
    end
  end
end
