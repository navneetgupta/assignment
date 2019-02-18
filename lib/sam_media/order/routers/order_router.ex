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

  middleware(Commanded.Middleware.Logger)
  middleware(Validate)

  dispatch(CreateOrder, to: Order, identity: :uuid)
  dispatch(CompleteOrder, to: Order, identity: :order_uuid)
  dispatch(DeliverOrder, to: Order, identity: :order_uuid)
  dispatch(InitiateOrderCancellation, to: Order, identity: :order_uuid)
  dispatch(CancelOrder, to: Order, identity: :order_uuid)
end
