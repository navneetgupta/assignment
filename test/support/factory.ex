defmodule SamMedia.Factory do
  use ExMachina

  alias SamMedia.Payment.Commands.{InitiatePayment, CompletePayment, ProcessRefund}

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

  def complete_payment_factory do
    struct(CompletePayment, build(:complete_p))
  end

  def process_refund_factory do
    struct(ProcessRefund, build(:refund_payment))
  end
end
