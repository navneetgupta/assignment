defmodule SamMedia.Payment.Aggregates.PaymentTest do
  use SamMedia.AggregateCase, aggregate: SamMedia.Payment.Aggregates.Payment

  alias SamMedia.Payment.Events.{
    PaymentIntitated,
    PaymentCompleted,
    RefundInitiated,
    RefundProcessed
  }

  alias SamMedia.Payment.Enums.EnumsPayment

  @status_success EnumsPayment.payment_status()[:SUCCESS]

  describe "initiate payment" do
    @tag :unit
    test "should succeed when valid" do
      uuid = UUID.uuid4()
      order_uuid = UUID.uuid4()

      assert_events(build(:initiate_payment, uuid: uuid, order_uuid: order_uuid), [
        %PaymentIntitated{
          payment_uuid: uuid,
          amount: 100,
          card_number: "1234123412341234",
          card_security_code: "123",
          card_holder_name: "Navneet Kumar",
          card_expiry: "12/21",
          order_uuid: order_uuid
        }
      ])
    end
  end

  describe "Complete payment" do
    setup [
      :initiate_payment
    ]

    @tag :unit
    test "should succeed when valid", %{payment: payment} do
      txn_uuid = UUID.uuid4()

      assert_events(
        payment,
        build(:complete_payment,
          payment_uuid: payment.uuid,
          txn_uuid: txn_uuid,
          status: @status_success
        ),
        [
          %PaymentCompleted{
            payment_uuid: payment.uuid,
            txn_uuid: txn_uuid,
            status: @status_success,
            order_amount: payment.amount,
            order_uuid: payment.order_uuid
          }
        ]
      )
    end
  end

  describe "Initiate Refund For Non-existent payment" do
    setup [
      :initiate_payment
    ]

    @tag :unit
    test "should fail", %{payment: payment} do
      assert_error(
        [
          build(:initiate_refund,
            payment_uuid: payment.uuid,
            order_uuid: payment.order_uuid
          )
        ],
        {:error, :payment_dtls_not_found}
      )
    end
  end

  describe "Initiate Refund For Already Refund initiated order" do
    setup [
      :initiate_payment,
      :complete_payment,
      :initiate_refund
    ]

    @tag :unit
    test "should fail", %{payment: payment} do
      assert_error(
        payment,
        [
          build(:initiate_refund,
            payment_uuid: payment.uuid,
            order_uuid: payment.order_uuid
          )
        ],
        {:error, :refund_already_in_process}
      )
    end
  end

  describe "Initiate Refund For Invalid orderid order" do
    setup [
      :initiate_payment,
      :complete_payment
    ]

    @tag :unit
    test "should fail", %{payment: payment} do
      uuid = UUID.uuid4()

      assert_error(
        payment,
        [
          build(:initiate_refund,
            payment_uuid: payment.uuid,
            order_uuid: uuid
          )
        ],
        {:error, :invalid_order_for_refund}
      )
    end
  end

  describe "Initiate Refund" do
    setup [
      :initiate_payment,
      :complete_payment
    ]

    @tag :unit
    test "should succeed for valid order", %{payment: payment} do
      assert_events(
        payment,
        [
          build(:initiate_refund,
            payment_uuid: payment.uuid,
            order_uuid: payment.order_uuid
          )
        ],
        [
          %RefundInitiated{
            order_uuid: payment.order_uuid,
            payment_uuid: payment.uuid
          }
        ]
      )
    end
  end

  describe "Process Refund For Non-existent payment" do
    setup [
      :initiate_payment,
      :complete_payment,
      :initiate_refund
    ]

    @tag :unit
    test "should fail", %{payment: payment} do
      uuid = UUID.uuid4()

      assert_error(
        [
          build(:process_refund,
            payment_uuid: payment.uuid,
            order_uuid: payment.order_uuid,
            txn_uuid: uuid
          )
        ],
        {:error, :invalid_payment}
      )
    end
  end

  describe "Process Refund " do
    setup [
      :initiate_payment,
      :complete_payment,
      :initiate_refund
    ]

    @tag :unit
    test "should succeed for valid order", %{payment: payment} do
      uuid = UUID.uuid4()

      assert_events(
        payment,
        [
          build(:process_refund,
            payment_uuid: payment.uuid,
            order_uuid: payment.order_uuid,
            txn_uuid: uuid
          )
        ],
        [
          %RefundProcessed{
            order_uuid: payment.order_uuid,
            payment_uuid: payment.uuid,
            txn_uuid: uuid
          }
        ]
      )
    end
  end

  defp initiate_payment(_ctx) do
    uuid = UUID.uuid4()
    order_uuid = UUID.uuid4()

    {payment, _events, _error} =
      execute(List.wrap(build(:initiate_payment, uuid: uuid, order_uuid: order_uuid)))

    [
      payment: payment
    ]
  end

  # defp initiate_invalid_payment(_ctx) do
  #   uuid = UUID.uuid4()
  #   order_uuid = UUID.uuid4()
  #
  #   {payment, _events, _error} =
  #     execute(List.wrap(build(:initiate_invalid_payment, uuid: uuid, order_uuid: order_uuid)))
  #
  #   [
  #     payment: payment
  #   ]
  # end

  defp complete_payment(%{payment: payment}) do
    uuid = UUID.uuid4()

    {payment, _events, _error} =
      execute(
        List.wrap(
          build(:complete_payment,
            payment_uuid: payment.uuid,
            txn_uuid: uuid,
            status: @status_success
          )
        ),
        payment
      )

    [
      payment: payment
    ]
  end

  defp initiate_refund(%{payment: payment}) do
    {payment, _events, _error} =
      execute(
        List.wrap(
          build(:initiate_refund,
            payment_uuid: payment.uuid,
            order_uuid: payment.order_uuid
          )
        ),
        payment
      )

    [
      payment: payment
    ]
  end
end
