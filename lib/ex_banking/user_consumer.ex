defmodule ExBanking.UserConsumer do
  use GenStage
  alias ExBanking.Transaction
  alias ExBanking.User.Vault

  @max_demand 10

  def start_link(user) do
    {:ok, consumer} = GenStage.start_link(__MODULE__, user, name: via_tuple(user <> "consumer"))
    GenStage.sync_subscribe(consumer, to: via_tuple(user), max_demand: @max_demand, min_demand: 1)
    {:ok, consumer}
  end

  def init(_) do
    {:consumer, :ok}
  end

  defp via_tuple(user) do
    {:via, Registry, {Registry.User, user}}
  end

  def handle_events(transactions, _from, state) do
    for {origin, transaction} <- transactions do
      result = dispatch_transaction(transaction)
      GenStage.reply(origin, result)
    end

    {:noreply, [], state}
  end

  def dispatch_transaction(%Transaction{type: :deposit} = transaction) do
    Vault.deposit(transaction)
  end

  def dispatch_transaction(%Transaction{type: :withdraw} = transaction) do
    Vault.withdraw(transaction)
  end

  def dispatch_transaction(%Transaction{type: :balance} = transaction) do
    Vault.get_balance(transaction)
  end

  def dispatch_transaction(%Transaction{type: :send} = transaction) do
    Vault.send_amount(transaction)
  end
end
