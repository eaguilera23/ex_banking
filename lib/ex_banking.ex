defmodule ExBanking do
  @moduledoc """
  Module to make a variety of transactions of a user.

  ## Every user is a pair of `GenStage`
  
  For every user created, there is a par of `GenStage` with a producer 
  and a consumer. This lets every user to handle transactions 
  independently. You can see more about this at `ExBanking.User` and
  `ExBanking.UserConsumer`.

  ## Transaction

  Inside the system the concept of `ExBanking.Transaction` exists.
  This is how the system speaks internaly, validating constraints that
  does not depend of the state. For example: *Money amount of any currency
  should not be negative.*

  ## State stored in ETS

  The information of the users is stored on a `ExBanking.User.Vault` 
  `:ets` table. It is being protected from crashing by having an `heir` 
  available at all times with the help of the `Element` library.

  ## Money
  
  Money is handled as integers internally. Being formated on at input
  and output moments. See more on `ExBanking.Format`.
  """
  alias ExBanking.{User, Transaction, Format}

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

  @type banking_response ::
        :ok
        | {:ok, new_balance :: number}
        | {:ok, from_user_balance :: number, to_user_balance :: number}

  @doc """
  - Function creates new user in the system
  - New user has zero balance of any currency
  """
  @spec create_user(user :: String.t()) :: :ok | banking_error
  def create_user(user) when is_binary(user) do
    ExBanking.User.Supervisor.create_user(user)
  end

  def create_user(_), do: {:error, :wrong_arguments}

  @doc """
  - Increases user's balance in given currency by amount value
  - Returns new_balance of the user in given format
  """
  @spec deposit(user :: String.t(), amount :: number, currency :: String.t()) ::
          {:ok, new_balance :: number} | banking_error
  def deposit(user, amount, currency) do
    case Transaction.new(:deposit, user, amount, currency) do
      %Transaction{} = transaction ->
        User.make_transaction(transaction)
        |> Format.response()

      error ->
        error
    end
  end

  @doc """
  - Decreases user's balance in given currency by amount value
  - Returns new_balance of the user in given format
  """
  @spec withdraw(user :: String.t(), amount :: number, currency :: String.t()) ::
          {:ok, new_balance :: number} | banking_error
  def withdraw(user, amount, currency) do
    case Transaction.new(:withdraw, user, amount, currency) do
      %Transaction{} = transaction ->
        User.make_transaction(transaction)
        |> Format.response()

      error ->
        error
    end
  end

  @doc """
  - Returns balance of the user in given format
  """
  @spec get_balance(user :: String.t(), currency :: String.t()) ::
          {:ok, balance :: number} | banking_error
  def get_balance(user, currency) do
    case Transaction.new(:balance, user, currency) do
      %Transaction{} = transaction ->
        User.make_transaction(transaction)
        |> Format.response()

      error ->
        error
    end
  end

  @doc """
  - Decreases from_user's balance in given currency by amount value
  - Increases to_user's balance in given currency by amount value
  - Returns balance of from_user and to_user in given format
  """
  @spec send(
          from_user :: String.t(),
          to_user :: String.t(),
          amount :: number,
          currency :: String.t()
        ) :: {:ok, from_user_balance :: number, to_user_balance :: number} | banking_error
  def send(from_user, to_user, amount, currency) do
    case Transaction.new(:send, from_user, to_user, amount, currency) do
      %Transaction{} = transaction ->
        User.make_transaction(transaction)
        |> Format.response()

      error ->
        error
    end
  end
end
