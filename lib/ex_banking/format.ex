defmodule ExBanking.Format do
  @moduledoc """
  Shows the amounts of money as floats with 2 decimals
  """

  @doc """
  Returns money as float
  """
  @spec response({:ok, integer()}) :: tuple()
  def response({:ok, amount}), do: {:ok, Money.to_float(amount)}

  def response({:ok, sender_amount, receiver_amount}) do
    {:ok, Money.to_float(sender_amount), Money.to_float(receiver_amount)}
  end

  def response({:error, _} = error), do: error
end
