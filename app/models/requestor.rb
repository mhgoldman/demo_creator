class Requestor < ActiveRecord::Base
	has_many :environment_requests
	validates :email, presence: true
	validates :skytap_url, presence: true

	before_save :create_user

  private

  def create_user
    user_obj = SkytapAPI.post("users",
      login_name: login_name,
      first_name: first_name,
      last_name: last_name,
      password: SecureRandom.hex,
      email: ENV['shadow_users_email']
    )

		#TODO NEED TO AADD TO DEPARTMENT AND APPLY QUOTAS
    update(skytap_url: user_obj.url)
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
