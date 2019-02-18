defmodule SamMedia.Order.Enums.EnumsOrder do
  import SamMedia.Support.EnumsHelper

  enum "order_status" do
    %{
      CREATED: 1,
      CONFIRMED: 2,
      DELIVERED: 3,
      CANCELLED: 4,
      CANCELLATION_INITIATED: 5,
      CANCELLING: 6
    }
  end

  enum "payment_status" do
    %{
      processing: 1,
      success: 2,
      declined: 3,
      refunded: 4,
      refunding: 5
    }
  end
end
