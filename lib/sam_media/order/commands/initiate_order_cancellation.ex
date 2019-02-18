defmodule SamMedia.Order.Commands.InitiateOrderCancellation do
  alias __MODULE__

  defstruct order_uuid: ""

  use ExConstructor
  use Vex.Struct

  validates(:order_uuid, uuid: true)

  def assign_order_uuid(%InitiateOrderCancellation{} = cancel_order, order_uuid) do
    %InitiateOrderCancellation{cancel_order | order_uuid: order_uuid}
  end
end
