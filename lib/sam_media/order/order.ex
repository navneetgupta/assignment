defmodule SamMedia.Order do
  alias SamMedia.Order.Commands.{CreateOrder, CancelOrder}
  alias SamMedia.Router
  alias SamMedia.Order.Pubsub, as: OrderPubSub
  alias SamMedia.Order.Projections.Order, as: OrderPro
  alias SamMedia.Repo

  def create_order(attrs \\ %{}) do
    uuid = UUID.uuid4()

    create_order =
      attrs
      |> CreateOrder.new()
      |> CreateOrder.assign_uuid(uuid)

    with {:ok, version} <- Router.dispatch(create_order, include_aggregate_version: true) do
      OrderPubSub.wait_for(OrderPro, uuid, version)
    else
      reply -> reply
    end
  end

  def list_orders do
    Repo.all(OrderPro)
  end

  def get_order!(uuid), do: Repo.get!(OrderPro, uuid)
end
