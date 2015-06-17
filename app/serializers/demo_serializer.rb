class DemoSerializer < ActiveModel::Serializer
  attributes :id, :status, :description, :token, :published_url, :confirmation_expiration, :usage_expiration, :skytap_id, :provisioning_error

  def confirmation_expiration
    object.confirmation_expiration.iso8601
  end

  def usage_expiration
    object.usage_expiration.iso8601
  end

  has_one :template
  has_one :requestor
  has_one :provisioning_status
end