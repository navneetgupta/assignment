defmodule SamMedia.Order.Pubsub do
  alias SamMedia.Order.Projections.Order
  alias SamMedia.Repo
  alias Phoenix.PubSub

  def wait_for(schema, uuid, version) do
    case Repo.get_by(schema, uuid: uuid, version: version) do
      nil -> subscribe_and_wait(schema, uuid, version)
      projection -> {:ok, projection}
    end
  end

  def publish_changes(%{order: %Order{} = order}), do: publish(order)

  def publish_changes(%{order: {_, orders}}) when is_list(orders),
    do: Enum.each(orders, &publish/1)

  def publish_changes(_changes), do: :ok

  defp publish(%Order{uuid: uuid, version: version} = order) do
    PubSub.broadcast(SamMedia.PubSub, "Order:#{uuid}:#{version}", {Order, order})
  end

  defp subscribe_and_wait(schema, uuid, version) do
    PubSub.subscribe(SamMedia.PubSub, "Order:#{uuid}:#{version}")

    receive do
      {^schema, projection} -> {:ok, projection}
    after
      10_000 ->
        {:error, :timeout}
    end
  end
end
