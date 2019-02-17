defmodule SamMedia.Order.Pubsub do
  alias SamMedia.Order.Projections.Order, as: OrderPro
  alias SamMedia.Repo
  alias Phoenix.PubSub

  def wait_for(schema, uuid, version) do
    IO.puts("Wait For #{schema}, #{uuid}, #{version}")

    case Repo.get_by(schema, uuid: uuid, version: version) do
      nil -> subscribe_and_wait(schema, uuid, version)
      projection -> {:ok, projection}
    end
  end

  def publish_changes(%{order: %OrderPro{} = order}), do: publish(order)

  def publish_changes(%{order: {_, orders}}) when is_list(orders),
    do: Enum.each(orders, &publish/1)

  def publish_changes(_changes), do: :ok

  defp publish(%OrderPro{uuid: uuid, version: version} = order) do
    PubSub.broadcast(SamMedia.PubSub, "Order:#{uuid}:#{version}", {OrderPro, order})
  end

  defp subscribe_and_wait(schema, uuid, version) do
    IO.puts("subscribe_and_wait For #{schema}, #{uuid}, #{version}")

    PubSub.subscribe(SamMedia.PubSub, "Order:#{uuid}:#{version}")

    receive do
      {^schema, projection} -> {:ok, projection}
    after
      10_000 ->
        {:error, :timeout}
    end
  end
end
