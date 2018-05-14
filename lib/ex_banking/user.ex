defmodule ExBanking.User do
  use GenServer
  alias ExBanking.{Transaction, Error}

  @registry Registry.User

  ###
  ## Callbacks
  ###
  def init(_) do
    {:ok, Map.new()}
  end

  ###
  ## Public API
  ###
  def create_user(user) do
    case GenServer.start_link(__MODULE__, [], name: via_tuple(user)) do
      {:ok, _} ->
        :ok

      {:error, _} ->
        {:error, :user_already_exists}
    end
  end

  def make_transaction(%Transaction{type: :deposit, receiver: user} = transaction) do
    GenServer.call(via_tuple(user), {:deposit, transaction})
  end

  def exists?(user) do
    case Registry.lookup(@registry, user) do
      [] ->
        {:error, :user_does_not_exists}

      [{pid, _}] ->
        {:ok, pid}
    end
  end

  defp via_tuple(user) do
    {:via, Registry, {Registry.User, user}}
  end

  ###
  ## GenServer calls
  ###

  def handle_call({:deposit, %Transaction{amount: amount, currency: currency}}, _from, state) do
    {new_balance, new_state} =
      Map.get_and_update(state, currency, fn
        nil ->
          {amount, amount}

        prev_balance ->
          new = prev_balance + amount
          {new, new}
      end)

    {:reply, {:ok, new_balance}, new_state}
  end
end
