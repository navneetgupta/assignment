defmodule SamMedia.Payment.Aggregates.PaymentTest do
  use SamMedia.AggregateCase, aggregate: SamMedia.Payment.Aggregates.Payment

  alias SamMedia.Payment.Events.{PaymentIntitated, PaymentCompleted, RefundProcessed}
  alias SamMedia.Payment.Enums.EnumsPayment

  @status_success EnumsPayment.payment_status()[:SUCCESS]
  @status_success EnumsPayment.payment_status()[:DECLINED]

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

  defp initiate_payment(_ctx) do
    uuid = UUID.uuid4()
    order_uuid = UUID.uuid4()

    {payment, _events, _error} =
      execute(List.wrap(build(:initiate_payment, uuid: uuid, order_uuid: order_uuid)))

    [
      payment: payment
    ]
  end

  defp initiate_invalid_payment(_ctx) do
    uuid = UUID.uuid4()
    order_uuid = UUID.uuid4()

    {payment, _events, _error} =
      execute(List.wrap(build(:initiate_invalid_payment, uuid: uuid, order_uuid: order_uuid)))

    [
      payment: payment
    ]
  end
end
