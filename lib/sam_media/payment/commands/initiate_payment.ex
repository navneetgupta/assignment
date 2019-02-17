defmodule SamMedia.Payment.Commands.InitiatePayment do
  alias __MODULE__

  @moduledoc """

  """

  defstruct uuid: "",
            order_uuid: "",
            card_number: "",
            card_holder_name: "",
            card_expiry: "",
            card_security_code: "",
            order_amount: 0

  use ExConstructor
  use Vex.Struct

  validates(:uuid, uuid: true)

  validates(:order_uuid, uuid: true)

  validates(:amount,
    presence: [message: "can't be empty"],
    amount: true
  )

  validates(:card_number,
    presence: [message: "can't be empty"],
    card_number: true
  )

  validates(:card_holder_name,
    presence: [message: "can't be empty"],
    string: true
  )

  validates(:card_security_code,
    presence: [message: "can't be empty"],
    card_security_code: true
  )

  @doc """
  Assign a unique identity for the payment
  """
  def assign_uuid(%InitiatePayment{} = intitate_payment, uuid) do
    %InitiatePayment{intitate_payment | uuid: uuid}
  end

  @doc """
  Assign a unique identity for the order
  """
  def assign_order_uuid(%InitiatePayment{} = intitate_payment, order_uuid) do
    %InitiatePayment{intitate_payment | order_uuid: order_uuid}
  end
end
