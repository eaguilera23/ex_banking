defmodule ExBanking.User do
  use GenServer
  alias ExBanking.Error

  @registry Registry.User

  def create_user(user) do
    case GenServer.start_link(__MODULE__, [], name: via_tuple(user)) do
      {:ok, _} ->
        :ok
      {:error, _} ->
        {:error, :user_already_exists}
    end
  end

  def init(_) do
    {:ok, Map.new()}
  end

  defp via_tuple(user) do
    {:via, Registry, {Registry.User, user}}
  end
end
