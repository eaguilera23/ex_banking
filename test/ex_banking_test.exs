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

  describe "withdraw/3" do
    test "returns error in not existing currency by amount value" do
      ExBanking.create_user("withdraw")

      result = ExBanking.withdraw("withdraw", 23, "BTC")

      assert(result == {:error, :not_enough_money})
    end

    test "decreases user's balance in existing currency by amount value" do
      ExBanking.create_user("withdraw")

      ExBanking.deposit("withdraw", 23, "BTC")
      ExBanking.withdraw("withdraw", 20, "BTC")

      result =
        Registry.lookup(Registry.User, "withdraw")
        |> hd()
        |> elem(0)
        |> :sys.get_state()

      assert(result == %{"BTC" => 3.00})
    end

    test "returns new_balance of the user in given format" do
      ExBanking.create_user("deposit")

      ExBanking.deposit("deposit", 23, "BTC")
      result = ExBanking.withdraw("deposit", 20, "BTC")

      assert(result == {:ok, 3.00})
    end

    test "returns error if user does not exists" do
      result = ExBanking.withdraw("not_existent", 23, "BTC")

      assert(result == {:error, :user_does_not_exists})
    end

    test "returns error if not enough money is in user balance" do
      ExBanking.create_user("deposit")

      ExBanking.deposit("deposit", 23, "BTC")
      result = ExBanking.withdraw("deposit", 40, "BTC")

      assert(result == {:error, :not_enough_money})
    end
  end
end
