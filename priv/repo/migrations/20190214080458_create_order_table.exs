defmodule SamMedia.Repo.Migrations.CreateOrderTable do
  use Ecto.Migration

  def change do
    create table(:orders, primary_key: false) do
      add(:uuid, :uuid, primary_key: true)
      add(:user_name, :string)
      add(:user_email, :string)
      add(:user_mobile, :string)
      add(:amount, :bigint)
      add(:status, :integer, default: 1)
      add(:payment_uuid, :uuid)
      add(:payment_status, :integer, default: 1)

      timestamps()
    end
  end
end
