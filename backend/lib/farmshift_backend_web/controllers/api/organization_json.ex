defmodule FarmshiftBackendWeb.API.OrganizationJSON do
  alias FarmshiftBackend.Organizations.Organization

  def index(%{organizations: organizations}) do
    %{data: for({organization, role} <- organizations, do: data(organization, role))}
  end

  def show(%{organization: {organization, role}}) do
    %{data: data(organization, role)}
  end

  def create(%{organization: {organization, role}}) do
    %{data: data(organization, role)}
  end

  def update(%{organization: {organization, role}}) do
    %{data: data(organization, role)}
  end

  defp data(%Organization{} = organization, role) do
    base_data = %{
      id: organization.id,
      name: organization.name,
      description: organization.description,
      country: organization.country,
      locale: organization.locale,
      timezone: organization.timezone,
      plan: organization.plan,
      features: organization.features
    }

    if role do
      Map.put(base_data, :user_role, role)
    else
      base_data
    end
  end
end