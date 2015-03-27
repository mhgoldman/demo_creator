require 'skytap_api'

module CourseCreator
  class ShadowUser
    def initialize(email)
      @email = email
      @user_obj = get_user || create_user
    end

    def url
      @user_obj ? @user_obj.url : nil
    end

    private

    def get_user
      all_users = SkytapAPI.get("users")
      login_name_users = all_users.select {|u| u.login_name == login_name}
      login_name_users.empty? ? nil : login_name_users.first
    end

    def create_user
      @user_obj = SkytapAPI.post("users",
        login_name: login_name,
        first_name: first_name,
        last_name: last_name,
        password: SecureRandom.hex,
        email: ENV['shadow_users_email']
      )
    end

    def neutralized_email
      @email.gsub(/[@\.]/, "-")
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
end