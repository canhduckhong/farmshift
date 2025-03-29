defmodule FarmshiftBackend.Repo do
  use Ecto.Repo,
    otp_app: :farmshift_backend,
    adapter: Ecto.Adapters.Postgres
end
