defmodule ExBanking.Transaction do
  @moduledoc """
  The system manages inside a %Transaction{} struct. Inside this module, it validates
  that it is a valid transaction
  """
  alias ExBanking.{Transaction, User}
  defstruct [:type, :receiver, :amount, :currency]

  def new(type, user, amount, currency) when is_binary(currency) do
    with {:ok, _} <- User.exists?(user),
         {:ok, correct_amount} <- format_amount(amount),
         do: %Transaction{
           type: type,
           receiver: user,
           amount: correct_amount,
           currency: currency
         }
  end

  def new(_, _, _), do: {:error, :wrong_arguments}

  # TODO: 2 DECIMALS IN NUMBERS
  defp format_amount(amount) when is_number(amount) and amount > 0 do
    {:ok, amount}
  end

  defp format_amount(_), do: {:error, :wrong_arguments}
end
