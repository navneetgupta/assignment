defmodule SamMedia.Router do
  use Commanded.Commands.CompositeRouter

  router(SamMedia.Order.Routers.OrderRouter)
  router(SamMedia.Payment.Routers.PaymentRouter)
end
