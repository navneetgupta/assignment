defmodule SamMedia.Order.Routers.OrderRouter do
  use Commanded.Commands.Router

  alias SamMedia.Order.Aggregates.Order

  alias SamMedia.Order.Commands.{
    CreateOrder,
    CompleteOrder,
    DeliverOrder,
    InitiateOrderCancellation,
    CancelOrder
  }

  alias SamMedia.Support.Validators.Validate
  alias SamMedia.Order.Aggregates.Lifespan.OrderLifespan

  middleware(Commanded.Middleware.Logger)
  middleware(Validate)

  dispatch(CreateOrder, lifespan: OrderLifespan, to: Order, identity: :uuid)
  dispatch(CompleteOrder, lifespan: OrderLifespan, to: Order, identity: :order_uuid)
  dispatch(DeliverOrder, lifespan: OrderLifespan, to: Order, identity: :order_uuid)
  dispatch(InitiateOrderCancellation, lifespan: OrderLifespan, to: Order, identity: :order_uuid)
  dispatch(CancelOrder, lifespan: OrderLifespan, to: Order, identity: :order_uuid)
end
