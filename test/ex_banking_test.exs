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

      assert(result === %{"BTC" => 2300})
    end

    test "Increases user's balance in existing currency by amount value" do
      ExBanking.create_user("deposit")

      ExBanking.deposit("deposit", 23, "BTC")
      ExBanking.deposit("deposit", 23.021, "BTC")

      result =
        Registry.lookup(Registry.User, "deposit")
        |> hd()
        |> elem(0)
        |> :sys.get_state()

      assert(result === %{"BTC" => 4602})
    end

    test "Returns new_balance of the user in given format" do
      ExBanking.create_user("deposit")

      result = ExBanking.deposit("deposit", 23.23, "BTC")

      assert(result == {:ok, 23.23})
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
      ExBanking.withdraw("withdraw", 20.43, "BTC")

      result =
        Registry.lookup(Registry.User, "withdraw")
        |> hd()
        |> elem(0)
        |> :sys.get_state()

      assert(result === %{"BTC" => 257})
    end

    test "returns new_balance of the user in given format" do
      ExBanking.create_user("deposit")

      ExBanking.deposit("deposit", 23.54, "BTC")
      result = ExBanking.withdraw("deposit", 20, "BTC")

      assert(result == {:ok, 3.54})
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

  describe "get_balance/2" do
    test "returns balance of the user in given format" do
      ExBanking.create_user("balance")
      ExBanking.deposit("balance", 23.0004, "BTC")

      result = ExBanking.get_balance("balance", "BTC")

      assert(result === {:ok, 23.0})
    end

    test "returns balance of user from not existent currency" do
      ExBanking.create_user("balance")

      result = ExBanking.get_balance("balance", "BTC")

      assert(result === {:ok, 0.0})
    end
  end

  describe "send/4" do
    test "decreases from_user's balance in given currency by amount value" do
      ExBanking.create_user("from_user")
      ExBanking.deposit("from_user", 23, "BTC")
      ExBanking.create_user("to_user")
      ExBanking.deposit("to_user", 23, "BTC")

      ExBanking.send("from_user", "to_user", 22.05, "BTC")

      result =
        Registry.lookup(Registry.User, "from_user")
        |> hd()
        |> elem(0)
        |> :sys.get_state()

      assert(result === %{"BTC" => 95})
    end

    test "increases to_user's balance in given currency by amount value" do
      ExBanking.create_user("from_user")
      ExBanking.deposit("from_user", 23, "BTC")
      ExBanking.create_user("to_user")
      ExBanking.deposit("to_user", 23, "BTC")

      ExBanking.send("from_user", "to_user", 23, "BTC")

      result =
        Registry.lookup(Registry.User, "to_user")
        |> hd()
        |> elem(0)
        |> :sys.get_state()

      assert(result === %{"BTC" => 4600})
    end

    test "returns balance of from_user and to_user in given format" do
      ExBanking.create_user("from_user")
      ExBanking.deposit("from_user", 23, "BTC")
      ExBanking.create_user("to_user")
      ExBanking.deposit("to_user", 23, "BTC")

      result = ExBanking.send("from_user", "to_user", 23, "BTC")

      assert(result == {:ok, 0, 46.00})
    end

    test "returns error when sender does not exists" do
      ExBanking.create_user("to_user")

      result = ExBanking.send("from_user", "to_user", 23, "BTC")

      assert(result == {:error, :sender_does_not_exists})
    end

    test "returns error when receiver does not exists" do
      ExBanking.create_user("from_user")
      ExBanking.deposit("from_user", 23, "BTC")

      result = ExBanking.send("from_user", "to_user", 23, "BTC")

      assert(result == {:error, :receiver_does_not_exists})
    end
  end
end
