defmodule SamMedia.Payment.Commands.InitiateRefund do
  defstruct payment_uuid: "",
            order_uuid: ""

  use ExConstructor
  use Vex.Struct

  validates(:payment_uuid, uuid: true)
  validates(:order_uuid, uuid: true)
end
