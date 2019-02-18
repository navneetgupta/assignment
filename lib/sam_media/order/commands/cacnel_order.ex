defmodule SamMedia.Order.Commands.CancelOrder do
  defstruct order_uuid: "",
            payment_uuid: "",
            txn_uuid: ""

  use ExConstructor
  use Vex.Struct

  validates(:order_uuid, uuid: true)
  validates(:payment_uuid, uuid: true)
  validates(:txn_uuid, uuid: true)
end
