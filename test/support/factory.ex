defmodule SamMedia.Factory do
  use ExMachina

  alias SamMedia.Payment.Commands.{InitiatePayment, CompletePayment, ProcessRefund}
  alias SamMedia.Order.Commands.{CreateOrder, CancelOrder, CompleteOrder, DeliverOrder}

  def valid_payment_factory do
    %{
      card_number: "1234123412341234",
      card_holder_name: "Navneet Kumar",
      card_expiry: "12/21",
      card_security_code: "123",
      uuid: UUID.uuid4(),
      order_uuid: UUID.uuid4(),
      order_amount: 100
    }
  end

  def invalid_payment_factory do
    %{
      card_number: "1234123412341235",
      card_holder_name: "Navneet Kumar",
      card_expiry: "12/21",
      card_security_code: "123",
      uuid: UUID.uuid4(),
      order_uuid: UUID.uuid4(),
      order_amount: 100
    }
  end

  def order_factory do
    %{
      uuid: UUID.uuid4(),
      amount: 100,
      card_number: "1234123412341234",
      card_expiry: "12/21",
      card_security_code: "123",
      card_holder_name: "Navneet Kumar",
      user_name: "Navneet Gupta",
      user_mobile: "1212121212"
    }
  end

  def complete_p_factory do
    %{payment_uuid: UUID.uuid4(), txn_uuid: UUID.uuid4(), status: 1}
  end

  def refund_payment_factory do
    %{
      payment_uuid: UUID.uuid4(),
      order_uuid: UUID.uuid4()
    }
  end

  def initiate_payment_factory do
    struct(InitiatePayment, build(:valid_payment))
  end

  def initiate_invalid_payment_factory do
    struct(InitiatePayment, build(:invalid_payment))
  end

  def complete_payment_factory do
    struct(CompletePayment, build(:complete_p))
  end

  def process_refund_factory do
    struct(ProcessRefund, build(:refund_payment))
  end

  def create_order_factory do
    struct(CreateOrder, build(:order))
  end

  def complete_order_factory do
    struct(CompleteOrder, %{})
  end

  def deliver_order_factory do
    struct(DeliverOrder, %{})
  end
end
