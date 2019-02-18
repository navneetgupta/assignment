defmodule SamMedia.Order do
  alias SamMedia.Order.Commands.{CreateOrder, InitiateOrderCancellation}
  alias SamMedia.Router
  alias SamMedia.Order.Pubsub, as: OrderPubSub
  alias SamMedia.Order.Projections.Order, as: OrderPro
  alias SamMedia.Repo

  alias SamMedia.Order.Enums.EnumsOrder

  @cancelled_status EnumsOrder.order_status()[:CANCELLED]

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

  def cancel_order(uuid) do
    IO.puts("========Order root Cancel======")
    IO.puts("=========#{uuid}")

    case(Repo.get(OrderPro, uuid)) do
      nil ->
        IO.puts("=========#{uuid} Not found")
        {:error, :order_not_found}

      %OrderPro{uuid: uuid, status: status} = order ->
        IO.puts("=========#{uuid} found")
        IO.inspect(order)

        cond do
          status === @cancelled_status ->
            {:ok, order}

          true ->
            cancel_order =
              InitiateOrderCancellation.new(%{})
              |> InitiateOrderCancellation.assign_order_uuid(uuid)

            with {:ok, _version} <- Router.dispatch(cancel_order, include_aggregate_version: true) do
              {:ok}
            else
              reply -> reply
            end
        end
    end
  end

  def get_order(uuid) do
    case(Repo.get(OrderPro, uuid)) do
      nil ->
        IO.puts("=========#{uuid} Not found")
        {:error, :order_not_found}

      %OrderPro{} = order ->
        {:ok, order}
    end
  end
end
