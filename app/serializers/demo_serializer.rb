class DemoSerializer < ActiveModel::Serializer
  attributes :id, :status, :description, :token, :published_url, :confirmation_expiration, :usage_expiration, :skytap_id, :created_at, :updated_at, :provisioning_error
  has_one :template
  has_one :requestor
  has_one :provisioning_status
end