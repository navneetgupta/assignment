defmodule SamMedia.Order.Aggregates.Lifespan.OrderLifespan do
  @behaviour Commanded.Aggregates.AggregateLifespan

  alias SamMedia.Order.Commands.{
    CreateOrder,
    DeliverOrder,
    CancelOrder
  }

  alias SamMedia.Order.Events.{
    OrderCreated,
    OrderCancelled,
    OrderDelivered
  }

  def after_event(%OrderCreated{}), do: :infinity
  def after_event(%OrderDelivered{}), do: :stop
  def after_event(%OrderCancelled{}), do: :stop
  def after_event(_event), do: 100_000

  def after_command(%CreateOrder{}), do: :infinity
  def after_command(%CancelOrder{}), do: :stop
  def after_command(%DeliverOrder{}), do: :stop
  def after_command(_command), do: 100_000

  def after_error(:invalid_order), do: :stop
  def after_error(_error), do: :infinity
end
