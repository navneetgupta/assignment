defmodule SamMedia.Order.OrderTest do
  use SamMedia.DataCase

  alias SamMedia.Order

  describe "organizations" do
    alias SamMedia.Order.Projections.Order, as: OrderPro
    alias SamMedia.Order.Enums.EnumsOrder

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
  end
end
