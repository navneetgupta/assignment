defmodule SamMedia.Payment.Supervisor do
  use Supervisor

  alias SamMedia.Payment

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_arg) do
    Supervisor.init(
      [
        Payment.ProcessManager.PaymentManager,
        Payment.ProcessManager.RefundPaymentManager
      ],
      strategy: :one_for_one
    )
  end
end
