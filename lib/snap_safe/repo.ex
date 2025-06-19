defmodule SnapSafe.Repo do
  use Ecto.Repo,
    otp_app: :snap_safe,
    adapter: Ecto.Adapters.Postgres
end
