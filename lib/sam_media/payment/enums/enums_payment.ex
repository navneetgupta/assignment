defmodule SamMedia.Order.Enums.EnumsPayment do
  import SamMedia.Support.EnumsHelper

  enum "payment_status" do
    %{
      SUCCESS: 1,
      DECLINED: 2,
      REFUNDED: 3,
      PROCESSING: 4
    }
  end
end
