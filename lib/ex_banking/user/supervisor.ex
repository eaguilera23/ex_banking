defmodule ExBanking.User.Supervisor do
  use Supervisor
  require Logger

  @name ExBanking.User.Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: @name)
  end

  def create_user(name) do
    begin_start(name)
    |> do_start(name)
    |> end_start()
  end

  def begin_start(name) do
    exists?(name)
    |> can_start?
  end

  def exists?(name) do
    Registry.lookup(Registry.User, name)
  end

  def can_start?([]), do: true
  def can_start?(_), do: false

  def do_start(false, _), do: {:error, :user_does_not_exists}

  def do_start(true, name) do
    Supervisor.start_child(@name, [name])
  end

  def end_start({:ok, pid}), do: :ok
  def end_start({:error, _}), do: {:error, :user_already_exists}
  def end_start(reason), do: reason

  def init(_) do
    Logger.info("Starting User Supervisor")

    children = [
      worker(ExBanking.User, [])
    ]

    opts = [strategy: :simple_one_for_one, name: StackDelivery.StackGenSupervisor]

    supervise(children, opts)
  end
end
