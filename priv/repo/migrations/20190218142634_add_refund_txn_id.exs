defmodule SamMedia.Repo.Migrations.AddRefundTxnId do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      add(:refund_txn_uuid, :uuid)
    end
  end
end
