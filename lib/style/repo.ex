defmodule Style.Repo do
  use Ecto.Repo,
    otp_app: :style,
    adapter: Ecto.Adapters.Postgres
end
