defmodule FarmshiftBackend.Organizations.OrganizationUser do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "organization_users" do
    belongs_to :organization, FarmshiftBackend.Organizations.Organization
    belongs_to :user, FarmshiftBackend.Accounts.User
    field :role, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(organization_user, attrs) do
    organization_user
    |> cast(attrs, [:organization_id, :user_id, :role])
    |> validate_required([:organization_id, :user_id, :role])
    |> validate_inclusion(:role, ["admin", "scheduler", "viewer"])
    |> unique_constraint([:organization_id, :user_id], name: :org_user_unique_index)
  end
end