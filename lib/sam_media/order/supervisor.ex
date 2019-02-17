defmodule SamMedia.Order.Supervisor do
  use Supervisor

  alias SamMedia.Order

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_arg) do
    Supervisor.init(
      [
        Order.Projectors.Order
      ],
      strategy: :one_for_one
    )
  end
end
