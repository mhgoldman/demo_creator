require 'skytap_api'

class Requestor < ActiveRecord::Base
	has_many :demos
	validates :email, presence: true

#TODO ick
  def get_skytap_url
    self.skytap_url ||= create_skytap_user
  end

  private

  def create_skytap_user
    user_obj = SkytapAPI.post("users",
      login_name: login_name,
      first_name: first_name,
      last_name: last_name,
      password: SecureRandom.hex,
      email: ENV['shadow_users_email']
    )

    update(skytap_url: user_obj.url)

    SkytapAPI.post("departments/#{ENV['shadow_users_dept_id']}/users/#{user_obj.id}") if ENV['shadow_users_dept_id']
    
    { "cumulative_svms" => ENV['shadow_user_svm_hours_monthly_quota'],
      "concurrent_svms" => ENV['shadow_user_concurrent_svms_quota'],
      "concurrent_storage_size" => ENV['shadow_users_storage_quota_mb']
    }.each do |quota_name, quota_value|
      SkytapAPI.post("users/#{user_obj.id}/quotas",
        name: quota_name,
        limit: quota_value
      ) if quota_value
    end 

    self.skytap_url
  end

  def neutralized_email
    self.email.gsub(/[@\.]/, "-")
  end

  def login_name
    neutralized_email + "@shadow-user.customer-name.com"
  end

  def first_name
    neutralized_email
  end

  def last_name
    "shadow-user"
  end	
end
