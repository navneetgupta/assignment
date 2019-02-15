defmodule SamMedia.Order.Enums.EnumsOrder do
  import SamMedia.Support.EnumsHelper

  enum "order_status" do
    %{
      created: 1,
      confirmed: 2,
      delivered: 3,
      cancelled: 4
    }
  end

  enum "payment_status" do
    %{
      processing: 1,
      closed: 2,
      refunded: 3
    }
  end
end
