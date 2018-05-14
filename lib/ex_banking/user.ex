defmodule ExBanking.User do
  use GenServer
  alias ExBanking.Transaction

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

  def make_transaction(%Transaction{type: :send, sender: user} = transaction) do
    GenServer.call(via_tuple(user), {:send, transaction})
  end

  def make_transaction(%Transaction{type: type, receiver: user} = transaction) do
    GenServer.call(via_tuple(user), {type, transaction})
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

  def handle_call({:withdraw, %Transaction{amount: amount, currency: currency}}, _from, state) do
    {response, new_state} =
      Map.get_and_update(state, currency, fn
        nil ->
          {{:error, :not_enough_money}, 0}

        prev_balance when prev_balance >= amount ->
          new = prev_balance - amount
          {{:ok, new}, new}

        balance ->
          {{:error, :not_enough_money}, balance}
      end)

    {:reply, response, new_state}
  end

  def handle_call({:balance, %Transaction{currency: currency}}, _from, state) do
    balance = Map.get(state, currency, 0)

    {:reply, {:ok, balance}, state}
  end

  def handle_call({:send, %Transaction{amount: amount, currency: currency} = transaction}, _from, state) do
    {sender_balance, new_state} =
      Map.get_and_update(state, currency, fn
        nil ->
          {{:error, :not_enough_money}, 0}

        prev_balance when prev_balance >= amount ->
          new = prev_balance - amount
          {new, new}

        balance ->
          {{:error, :not_enough_money}, balance}
      end)

    case sender_balance do
      {:error, _} ->
        {:reply, sender_balance, state}

      _ ->
        deposit_transaction = %{transaction | type: :deposit}
        {:ok, receiver_balance} = make_transaction(deposit_transaction)
        {:reply, {:ok, sender_balance, receiver_balance}, new_state}
    end
  end
end
