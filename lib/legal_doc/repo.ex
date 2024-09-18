defmodule LegalDoc.Repo do
  use Ecto.Repo,
    otp_app: :legal_doc,
    adapter: Ecto.Adapters.Postgres
end
