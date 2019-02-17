defmodule SamMedia.Payment.Commands.ProcessRefund do
  alias __MODULE__

  defstruct payment_uuid: "",
            order_uuid: ""

  use ExConstructor
  use Vex.Struct

  validates(:payment_uuid, uuid: true)
  validates(:order_uuid, uuid: true)

  def assign_payment_uuid(%ProcessRefund{} = refund_process, payment_uuid) do
    %ProcessRefund{refund_process | payment_uuid: payment_uuid}
  end

  def assign_order_uuid(%ProcessRefund{} = refund_process, order_uuid) do
    %ProcessRefund{refund_process | order_uuid: order_uuid}
  end
end
