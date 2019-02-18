defmodule SamMedia.Payment.Enums.EnumsPayment do
  import SamMedia.Support.EnumsHelper

  enum "payment_status" do
    %{
      SUCCESS: 1,
      DECLINED: 2,
      REFUNDED: 3,
      REFUND_PROCESSING: 4,
      PROCESSING: 5
    }
  end
end
