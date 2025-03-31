defmodule FarmshiftBackend.Organizations.Organization do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "organizations" do
    field :name, :string
    field :description, :string
    field :country, :string
    field :locale, :string
    field :timezone, :string
    field :plan, :string, default: "free"
    field :features, :map, default: %{}

    # Associations
    has_many :organization_users, FarmshiftBackend.Organizations.OrganizationUser
    has_many :users, through: [:organization_users, :user]

    timestamps(type: :utc_datetime)
  end

  @doc """
  Changeset for creating a new organization.
  """
  def changeset(organization, attrs) do
    organization
    |> cast(attrs, [:name, :description, :country, :locale, :timezone, :plan, :features])
    |> validate_required([:name])
    |> validate_length(:name, min: 2, max: 100)
    |> unique_constraint(:name)
    |> validate_inclusion(:plan, ["free", "pro", "enterprise"])
  end
end