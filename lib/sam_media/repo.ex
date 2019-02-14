defmodule SamMedia.Repo do
  use Ecto.Repo,
    otp_app: :sam_media,
    adapter: Ecto.Adapters.Postgres
end
