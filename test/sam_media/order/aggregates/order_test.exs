defmodule SamMedia.Order.Aggregates.OrderTest do
  use SamMedia.AggregateCase, aggregate: SamMedia.Order.Aggregates.Order

  alias SamMedia.Order.Events.{
    OrderCreated,
    OrderCancellationInitiated,
    OrderCancelled,
    OrderCompleted,
    OrderDelivered
  }

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

    @tag :unit
    test "should fail when amount is zero" do
      uuid = UUID.uuid4()

      assert_error([build(:create_order, uuid: uuid, amount: 0)], {:error, :invalid_order_amount})
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
          order_status: EnumsOrder.order_status()[:CONFIRMED]
        ),
        [
          %OrderCompleted{
            order_uuid: order.uuid,
            payment_uuid: uuid,
            order_status: EnumsOrder.order_status()[:CONFIRMED],
            payment_status: ""
          }
        ]
      )
    end

    @tag :unit
    test "should fail when order doesn't exist", %{order: order} do
      uuid = UUID.uuid4()

      assert_error(
        [
          build(:complete_order,
            order_uuid: order.uuid,
            payment_uuid: uuid,
            order_status: EnumsOrder.order_status()[:CONFIRMED]
          )
        ],
        {:error, :invalid_order}
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
          order_status: EnumsOrder.order_status()[:CANCELLED]
        ),
        [
          %OrderCompleted{
            order_uuid: order.uuid,
            payment_uuid: uuid,
            order_status: EnumsOrder.order_status()[:CANCELLED],
            payment_status: ""
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

    @tag :unit
    test "should fail when Order does not exist", %{order: order} do
      assert_error(
        [
          build(:deliver_order,
            order_uuid: order.uuid
          )
        ],
        {:error, :invalid_order}
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

  describe "Initiate Order cancellation for non-existing order" do
    setup [
      :create_order,
      :complete_cancelled_order
    ]

    @tag :unit
    test "should fail when Order doesn't exits", %{order: order} do
      assert_error(
        [
          build(:initate_cancel_order,
            order_uuid: order.uuid
          )
        ],
        {:error, :invalid_order}
      )
    end
  end

  describe "Initiate processing Order cancellation" do
    setup [:create_order]

    @tag :unit
    test "should fail when Order payment is processing", %{order: order} do
      assert_error(
        order,
        [
          build(:initate_cancel_order,
            order_uuid: order.uuid
          )
        ],
        {:error, :txn_in_process_retry_after_some_time}
      )
    end
  end

  describe "Initiate already cancel initiated Order cancellation" do
    setup [:create_order, :complete_confirm_order, :deliver_order, :initiate_order_cancellation]

    @tag :unit
    test "should fail when Order payment is processing", %{order: order} do
      assert_error(
        order,
        [
          build(:initate_cancel_order,
            order_uuid: order.uuid
          )
        ],
        {:error, :cancellation_already_requested}
      )
    end
  end

  describe "Initiate refunded Order cancellation" do
    setup [:create_order, :complete_confirm_order, :initiate_order_cancellation, :cancel_order]

    @tag :unit
    test "should fail when Order payment is processing", %{order: order} do
      assert_error(
        order,
        [
          build(:initate_cancel_order,
            order_uuid: order.uuid
          )
        ],
        {:error, :cancellation_already_processed}
      )
    end
  end

  describe "Initiate failed Payment Order cancellation" do
    setup [:create_order, :complete_cancelled_order]

    @tag :unit
    test "should fail when Order payment is processing", %{order: order} do
      assert_error(
        order,
        [
          build(:initate_cancel_order,
            order_uuid: order.uuid
          )
        ],
        {:error, :order_cancelled_due_to_payment_failure}
      )
    end
  end

  describe "Initiate Shipped Order cancellation" do
    setup [:create_order, :complete_confirm_order]

    @tag :unit
    test "should fail when Order payment is processing", %{order: order} do
      assert_error(
        order,
        [
          build(:initate_cancel_order,
            order_uuid: order.uuid
          )
        ],
        {:error, :shippment_out_for_delivery_try_after_some_time}
      )
    end
  end

  describe "Initiate Order cancellation" do
    setup [:create_order, :complete_confirm_order, :deliver_order]

    @tag :unit
    test "should succedd when valid input", %{order: order} do
      assert_events(
        order,
        build(:initate_cancel_order,
          order_uuid: order.uuid
        ),
        [
          %OrderCancellationInitiated{
            order_uuid: order.uuid,
            payment_uuid: order.payment_uuid
          }
        ]
      )
    end
  end

  describe "Cancel Order" do
    setup [:create_order, :complete_confirm_order, :deliver_order, :initiate_order_cancellation]

    @tag :unit
    test "should succedd when valid input", %{order: order} do
      uuid = UUID.uuid4()

      assert_events(
        order,
        build(:cancel_order,
          order_uuid: order.uuid,
          payment_uuid: order.payment_uuid,
          txn_uuid: uuid
        ),
        [
          %OrderCancelled{
            order_uuid: order.uuid,
            refund_txn_id: uuid
          }
        ]
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

    {order_new, _events, _error} =
      execute(
        List.wrap(
          build(:complete_order,
            order_uuid: order.uuid,
            payment_uuid: uuid,
            order_status: EnumsOrder.order_status()[:CONFIRMED],
            payment_status: EnumsOrder.payment_status()[:success]
          )
        ),
        order
      )

    [
      order: order_new
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
            order_status: EnumsOrder.order_status()[:CANCELLED],
            payment_status: EnumsOrder.payment_status()[:declined]
          )
        ),
        order
      )

    [
      order: order
    ]
  end

  defp initiate_order_cancellation(%{order: order}) do
    {order, _events, _error} =
      execute(
        List.wrap(
          build(:initate_cancel_order,
            order_uuid: order.uuid
          )
        ),
        order
      )

    [
      order: order
    ]
  end

  defp cancel_order(%{order: order}) do
    uuid = UUID.uuid4()

    {order, _events, _error} =
      execute(
        List.wrap(
          build(:cancel_order,
            order_uuid: order.uuid,
            payment_uuid: order.payment_uuid,
            txn_uuid: uuid
          )
        ),
        order
      )

    [
      order: order
    ]
  end

  defp deliver_order(%{order: order}) do
    {order, _events, _error} =
      execute(
        List.wrap(
          build(:deliver_order,
            order_uuid: order.uuid
          )
        ),
        order
      )

    [
      order: order
    ]
  end
end
