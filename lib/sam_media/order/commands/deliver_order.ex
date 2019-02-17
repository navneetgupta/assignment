defmodule SamMedia.Order.Commands.DeliverOrder do
  alias __MODULE__

  defstruct order_uuid: ""

  use ExConstructor
  use Vex.Struct

  validates(:order_uuid, uuid: true)

  def assign_order_uuid(%DeliverOrder{} = deliver_order, order_uuid) do
    %DeliverOrder{deliver_order | order_uuid: order_uuid}
  end
end
