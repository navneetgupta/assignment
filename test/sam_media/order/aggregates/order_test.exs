defmodule SamMedia.Order.Aggregates.OrderTest do
  use SamMedia.AggregateCase, aggregate: SamMedia.Order.Aggregates.Order

  alias SamMedia.Order.Events.{OrderCreated, OrderCancelled, OrderCompleted, OrderDelivered}
  alias SamMedia.Order.Enums.EnumsOrder

  describe "create Order" do
    @tag :unit
    test "should succeed when valid" do
      uuid = UUID.uuid4()

      assert_events(build(:create_order, uuid: uuid), [
        %OrderCreated{
          order_uuid: uuid,
          card_number: "1234123412341234",
          card_holder_name: "Navneet Kumar",
          card_expiry: "12/21",
          card_security_code: "123",
          order_amount: 100,
          user_mobile: "1212121212",
          user_name: "Navneet Gupta"
        }
      ])
    end
  end

  describe "complete Order" do
    setup [
      :create_order
    ]

    @tag :unit
    test "should succeed when valid", %{order: order} do
      uuid = UUID.uuid4()

      assert_events(
        order,
        build(:complete_order,
          order_uuid: order.uuid,
          payment_uuid: uuid,
          status: EnumsOrder.order_status()[:CONFIRMED]
        ),
        [
          %OrderCompleted{
            order_uuid: order.uuid,
            payment_uuid: uuid,
            status: EnumsOrder.order_status()[:CONFIRMED]
          }
        ]
      )
    end

    @tag :unit
    test "should fail when invalid", %{order: order} do
      uuid = UUID.uuid4()

      assert_events(
        order,
        build(:complete_order,
          order_uuid: order.uuid,
          payment_uuid: uuid,
          status: EnumsOrder.order_status()[:CANCELLED]
        ),
        [
          %OrderCompleted{
            order_uuid: order.uuid,
            payment_uuid: uuid,
            status: EnumsOrder.order_status()[:CANCELLED]
          }
        ]
      )
    end
  end

  describe "Deliver Order" do
    setup [
      :create_order,
      :complete_confirm_order
    ]

    @tag :unit
    test "should succeed when Order is Confirmed", %{order: order} do
      assert_events(
        order,
        build(:deliver_order,
          order_uuid: order.uuid
        ),
        [
          %OrderDelivered{
            order_uuid: order.uuid
          }
        ]
      )
    end
  end

  describe "Deliver Order for Cancelled Order" do
    setup [
      :create_order,
      :complete_cancelled_order
    ]

    @tag :unit
    test "should fail when Order is Cancelled", %{order: order} do
      assert_error(
        order,
        [
          build(:deliver_order,
            order_uuid: order.uuid
          )
        ],
        {:error, :order_not_confirmed}
      )
    end
  end

  defp create_order(_ctx) do
    uuid = UUID.uuid4()

    {order, _events, _error} = execute(List.wrap(build(:create_order, uuid: uuid)))

    [
      order: order
    ]
  end

  defp complete_confirm_order(%{order: order}) do
    uuid = UUID.uuid4()

    {order, _events, _error} =
      execute(
        List.wrap(
          build(:complete_order,
            order_uuid: order.uuid,
            payment_uuid: uuid,
            status: EnumsOrder.order_status()[:CONFIRMED]
          )
        )
      )

    [
      order: order
    ]
  end

  defp complete_cancelled_order(%{order: order}) do
    uuid = UUID.uuid4()

    {order, _events, _error} =
      execute(
        List.wrap(
          build(:complete_order,
            order_uuid: order.uuid,
            payment_uuid: uuid,
            status: EnumsOrder.order_status()[:CANCELLED]
          )
        )
      )

    [
      order: order
    ]
  end
end
