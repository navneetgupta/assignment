defmodule SamMedia.Order.Projections.Order do
  use Ecto.Schema

  @primary_key {:uuid, :binary_id, autogenerate: false}
  schema "orders" do
    field(:version, :integer, default: 0)
    field(:user_name, :string)
    field(:user_mobile, :string)
    field(:user_email, :string, default: "")
    field(:amount, :integer)
    field(:status, :integer)
    field(:payment_uuid, :binary_id)
    field(:payment_status, :integer)
    field(:refund_txn_uuid, :binary_id)

    timestamps()
  end
end
