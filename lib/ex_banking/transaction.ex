defmodule ExBanking.Transaction do
  @moduledoc """
  The system manages inside a %Transaction{} struct. Inside this module, it validates
  that it is a valid transaction
  """
  alias ExBanking.{Transaction, User}
  defstruct [:type, :receiver, :sender, :amount, :currency]
  defguard are_binaries(value1, value2) when is_binary(value1) and is_binary(value2)
  defguard are_binaries(value1, value2, value3) when is_binary(value1) and is_binary(value2) and is_binary(value3)

  def new(type, user, amount, currency) when are_binaries(user, currency) do
    with {:ok, _} <- User.exists?(user),
         {:ok, correct_amount} <- format_amount(amount),
         do: %Transaction{
           type: type,
           receiver: user,
           amount: correct_amount,
           currency: currency
         }
  end
  def new(_, _, _, _), do: {:error, :wrong_arguments}

  def new(:balance, user, currency) when are_binaries(user, currency) do
    with {:ok, _} <- User.exists?(user),
         do: %Transaction{
           type: :balance,
           receiver: user,
           currency: currency
         }
  end
  def new(_, _, _), do: {:error, :wrong_arguments}

  def new(:send, from_user, to_user, amount, currency) when are_binaries(from_user, to_user, currency) do
    with {:ok, _} <- sender_exists?(from_user),
         {:ok, _} <- receiver_exists?(to_user),
         {:ok, correct_amount} <- format_amount(amount),
         do: %Transaction{
           type: :send,
           receiver: to_user,
           sender: from_user,
           currency: currency,
           amount: correct_amount
         }
  end

  def new(_, _, _, _, _), do: {:error, :wrong_arguments}

  defp format_amount(amount) when is_number(amount) and amount > 0 do
    {:ok, Money.convert_to_integer(amount)}
  end

  defp format_amount(_), do: {:error, :wrong_arguments}

  defp sender_exists?(user) do
    case User.exists?(user) do
      {:ok, _} ->
        {:ok, nil}

      {:error, _} ->
        {:error, :sender_does_not_exists}
    end
  end

  defp receiver_exists?(user) do
    case User.exists?(user) do
      {:ok, _} ->
        {:ok, nil}

      {:error, _} ->
        {:error, :receiver_does_not_exists}
    end
  end
end
