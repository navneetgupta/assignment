defmodule SamMedia.Payment.ProcessManager.PaymentManager do
  use Commanded.ProcessManagers.ProcessManager,
    name: "PaymentManager",
    router: SamMedia.Router

  alias __MODULE__
  import Integer

  @derive [Jason.Encoder]
  defstruct payment_uuid: nil,
            order_amount: 0,
            status: nil

  alias SamMedia.Payment.Events.{PaymentIntitated, PaymentCompleted}
  alias SamMedia.Payment.Commands.CompletePayment
  alias SamMedia.Payment.Enums.EnumsPayment

  def interested?(%PaymentIntitated{payment_uuid: payment_uuid}), do: {:start, payment_uuid}
  def interested?(%PaymentCompleted{payment_uuid: payment_uuid}), do: {:stop, payment_uuid}

  def handle(%PaymentManager{}, %PaymentIntitated{card_number: card_number} = initiated) do
    cond do
      String.split_at(card_number, -2) |> elem(1) |> String.to_integer() |> Integer.is_even() ==
          true ->
        %CompletePayment{
          payment_uuid: initiated.uuid,
          txn_uuid: UUID.uuid4(),
          status: EnumsPayment.payment_status()[:SUCCESS]
        }

      true ->
        %CompletePayment{
          payment_uuid: initiated.uuid,
          txn_uuid: UUID.uuid4(),
          status: EnumsPayment.payment_status()[:DECLINED]
        }
    end
  end

  def apply(%PaymentManager{} = payment_pm, %PaymentIntitated{} = created) do
    %PaymentManager{
      payment_pm
      | payment_uuid: created.uuid,
        order_amount: created.org_uuid,
        status: EnumsPayment.payment_status()[:PROCESSING]
    }
  end

  # Stop process manager after three failures
  def error({:error, _failure}, _failed_command, %{context: %{failures: failures}})
      when failures >= 2 do
    # take Corrective Measures
    {:stop, :too_many_failures}
  end

  # Retry command, record failure count in context map
  def error({:error, _failure}, _failed_command, %{context: context}) do
    context = Map.update(context, :failures, 1, fn failures -> failures + 1 end)
    {:retry, context}
  end
end
