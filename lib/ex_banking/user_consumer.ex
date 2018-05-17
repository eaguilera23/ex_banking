defmodule ExBanking.UserConsumer do
  use GenStage
  alias ExBanking.Transaction

  @ets :vault
  def start_link(user) do
    {:ok, consumer} = GenStage.start_link(__MODULE__, user, name: via_tuple(user <> "consumer"))
    GenStage.sync_subscribe(consumer, to: via_tuple(user), max_demand: 10, min_demand: 1)
    {:ok, consumer}
  end

  def init(_) do
    {:consumer, :ok}
  end

  defp via_tuple(user) do
    {:via, Registry, {Registry.User, user}}
  end

  def handle_events([{origin, transaction}], _from, state) do
    result = dispatch_transaction(transaction)
    GenStage.reply(origin, result)
    {:noreply, [], state}
  end

  def dispatch_transaction(%Transaction{type: :deposit} = transaction) do
    deposit(transaction)
  end

  def dispatch_transaction(%Transaction{type: :withdraw} = transaction) do
    withdraw(transaction)
  end

  def dispatch_transaction(%Transaction{type: :balance} = transaction) do
    get_balance(transaction)
  end

  def dispatch_transaction(%Transaction{type: :send} = transaction) do
    send_amount(transaction)
  end

  def deposit(%Transaction{receiver: user, amount: amount, currency: currency}) do
    new_balance = :ets.update_counter(@ets, {user, currency}, amount, {{user, currency}, 0})
    {:ok, new_balance}
  end

  def withdraw(%Transaction{receiver: user, amount: amount, currency: currency}) do
    :ets.lookup(@ets, {user, currency})
    |> withdraw(amount)
  end

  def withdraw([], amount), do: {:error, :not_enough_money}

  def withdraw([{key, balance}], amount) when amount > balance, do: {:error, :not_enough_money}

  def withdraw([{key, balance}], amount) do
    new_balance = balance - amount
    :ets.insert(@ets, {key, new_balance})

    {:ok, new_balance}
  end

  def get_balance(%Transaction{receiver: user, currency: currency}) do
    :ets.lookup(@ets, {user, currency})
    |> get_balance()
  end

  def get_balance([]), do: {:ok, 0}

  def get_balance([{key, balance}]), do: {:ok, balance}

  def send_amount(%Transaction{currency: currency, sender: user} = transaction) do
    :ets.lookup(@ets, {user, currency})
    |> send_amount(transaction)
  end

  def send_amount([], _), do: {:error, :not_enough_money}

  def send_amount([{key, balance}], %Transaction{amount: amount}) when amount > balance,
    do: {:error, :not_enough_money}

  def send_amount([{key, balance}], %Transaction{amount: amount} = transaction) do
    new_balance = balance - amount
    :ets.insert(@ets, {key, new_balance})
    {:ok, receiver_balance} = ExBanking.User.make_transaction(%{transaction | type: :deposit})

    {:ok, new_balance, receiver_balance}
  end
end
