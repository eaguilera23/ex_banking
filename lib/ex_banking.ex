defmodule ExBanking do
  @moduledoc """
  Documentation for ExBanking.
  """
  alias ExBanking.{User, Transaction}

  @type banking_error ::
          {:error,
           :wrong_arguments
           | :user_already_exists
           | :user_does_not_exist
           | :not_enough_money
           | :sender_does_not_exist
           | :receiver_does_not_exist
           | :too_many_requests_to_user
           | :too_many_requests_to_sender
           | :too_many_requests_to_receiver}

  @spec create_user(user :: String.t()) :: :ok | banking_error
  def create_user(user) when is_binary(user) do
    User.create_user(user)
  end

  def create_user(_), do: {:error, :wrong_arguments}

  @spec deposit(user :: String.t(), amount :: number, currency :: String.t()) ::
          {:ok, new_balance :: number} | banking_error
  def deposit(user, amount, currency) do
    case Transaction.new(:deposit, user, amount, currency) do
      %Transaction{} = transaction ->
        User.make_transaction(transaction)

      error ->
        error
    end
  end

  @spec withdraw(user :: String.t(), amount :: number, currency :: String.t()) ::
          {:ok, new_balance :: number} | banking_error
  def withdraw(user, amount, currency) do
    case Transaction.new(:withdraw, user, amount, currency) do
      %Transaction{} = transaction ->
        User.make_transaction(transaction)

      error ->
        error
    end
  end

  @spec get_balance(user :: String.t(), currency :: String.t()) ::
          {:ok, balance :: number} | banking_error
  def get_balance(user, currency) do
    case Transaction.new(:balance, user, currency) do
      %Transaction{} = transaction ->
        User.make_transaction(transaction)

      error ->
        error
    end
  end
end
