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

  describe "deposit/3" do
    test "Increases user's balance in not existing currency by amount value" do
      ExBanking.create_user("deposit")

      ExBanking.deposit("deposit", 23, "BTC")

      result =
        Registry.lookup(Registry.User, "deposit")
        |> hd()
        |> elem(0)
        |> :sys.get_state()

      assert(result == %{"BTC" => 23.00})
    end

    test "Increases user's balance in existing currency by amount value" do
      ExBanking.create_user("deposit")

      ExBanking.deposit("deposit", 23, "BTC")
      ExBanking.deposit("deposit", 23, "BTC")

      result =
        Registry.lookup(Registry.User, "deposit")
        |> hd()
        |> elem(0)
        |> :sys.get_state()

      assert(result == %{"BTC" => 46.00})
    end

    test "Returns new_balance of the user in given format" do
      ExBanking.create_user("deposit")

      result = ExBanking.deposit("deposit", 23, "BTC")

      assert(result == {:ok, 23.00})
    end

    test "Returns error if user does not exists" do
      result = ExBanking.deposit("deposit", 23, "BTC")

      assert(result == {:error, :user_does_not_exists})
    end
  end
end
