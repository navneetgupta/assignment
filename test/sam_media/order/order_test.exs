defmodule SamMedia.Order.OrderTest do
  use SamMedia.DataCase

  alias SamMedia.Order

  describe "organizations" do
    alias SamMedia.Order.Projections.Order, as: OrderPro

    @valid_create_order_attr %{
      card_number: "1234123412341234",
      card_holder_name: "Navneet Kumar",
      card_expiry: "12/21",
      card_security_code: "123",
      user_mobile: "0556364603",
      user_name: "Navneet Kumar",
      amount: 100
    }

    def order_fixture(attrs \\ %{}) do
      f = attrs |> Enum.into(@valid_create_order_attr())
      {:ok, order} = f |> Order.create_order()

      order
    end

    test "list_orders/0 should list down all the orders" do
      assert [] == Order.list_orders()
    end

    test "list_orders/0 should list down all the orders 2" do
      order = order_fixture()
      list = Order.list_orders()
      assert length(list) == 1
      assert hd(list).uuid == order.uuid
    end

    test "create_order/1 creates the order for the valid inputs" do
      {:ok, order} = Order.create_order(@valid_create_order_attr)
      assert %OrderPro{} = order
    end

    test "get_order/1 should get the order for valid UUID" do
      order = order_fixture()
      order_fetced = Order.get_order!(order.uuid)
      assert %OrderPro{} = order_fetced
      assert order.uuid == order_fetced.uuid
    end
  end
end
