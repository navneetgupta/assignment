defmodule SamMedia.Order.Commands.CompleteOrder do
  alias __MODULE__

  defstruct order_uuid: "",
            payment_uuid: "",
            order_status: "",
            payment_status: ""

  use ExConstructor
  use Vex.Struct

  validates(:order_uuid, uuid: true)
  validates(:payment_uuid, uuid: true)

  def assign_order_uuid(%CompleteOrder{} = complete, order_uuid) do
    %CompleteOrder{complete | order_uuid: order_uuid}
  end

  def assign_payment_uuid(%CompleteOrder{} = complete, payment_uuid) do
    %CompleteOrder{complete | payment_uuid: payment_uuid}
  end
end
