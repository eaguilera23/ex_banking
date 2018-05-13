defmodule ExBankingTest do
  use ExUnit.Case

  describe "create_user/1" do
    test "creates a new user" do
      result = ExBanking.create_user("test_user")

      assert(result == :ok)
    end

    test "returns error when user already exists" do
      ExBanking.create_user("test_user")

      result = ExBanking.create_user("test_user")
      assert(result == {:error, :user_already_exists})
    end
  end
end
