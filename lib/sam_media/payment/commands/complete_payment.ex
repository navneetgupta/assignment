defmodule SamMedia.Payment.Commands.CompletePayment do
  alias __MODULE__

  defstruct payment_uuid: "",
            txn_uuid: "",
            status: ""

  use ExConstructor
  use Vex.Struct

  validates(:payment_uuid, uuid: true)
  validates(:txn_uuid, uuid: true)

  def assign_txn_uuid(%CompletePayment{} = complete, txn_uuid) do
    %CompletePayment{complete | txn_uuid: txn_uuid}
  end

  def assign_payment_uuid(%CompletePayment{} = complete, payment_uuid) do
    %CompletePayment{complete | payment_uuid: payment_uuid}
  end

  def assign_status(%CompletePayment{} = complete, status) do
    %CompletePayment{complete | status: status}
  end
end
