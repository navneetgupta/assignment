defmodule SamMedia.Repo.Migrations.AddVersionToOrders do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      add(:version, :bigint)
    end
  end
end
