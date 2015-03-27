class EnvironmentRequest < ActiveRecord::Base
	TOKEN_LENGTH = 32

	attr_accessor :email

	belongs_to :template
	belongs_to :requestor

	enum status: [:provisioning, :provisioned]

	validates :email, presence: true
	validates :template, presence: true
	validates :requestor, presence: true

	before_validation :set_requestor
	before_save :set_token, :set_expirations

	def url
		Rails.application.routes.url_helpers.environment_request_url(token)
	end

	def provision!
		update(status: :provisioning)
		# do a thing to begin provisioning in the background
		# the background job will set status to provisioned
		config = SkytapAPI.post('configurations', 
			template_id: template.skytap_id
		)

		SkytAPI.put(config.url,
			name: name,
			owner: requestor.skytap_url
		)

    SkytapAPI.post("schedules",
      title: "Schedule for #{config.name} [#{config.id}]",
      configuration_id: config.id,
      start_at: Time.now.utc, #Util::Time.skytap_time_str(Time.now.utc),
      end_at: usage_expiration, #Util::Time.skytap_time_str(usage_expiration),
      delete_at_end: true,
      time_zone: "UTC"
    )


	end

	def provisionable?
		!expired? && self.status == nil
	end

	def provisioning?
		self.status == :provisioning
	end

	def ready?
		!expired? && self.status == :provisioned
	end

	def expired?
		self.confirmation_expiration <= Time.now || self.usage_expiration <= Time.now
	end

	private

	def name
		"Demo Environment - #{self.template.name} - #{self.requestor.email} - #{self.description}"
	end

	def set_requestor
		if self.email
			self.requestor = Requestor.where(email: email).first || Requestor.create(email: email)
		elsif self.requestor
			self.email = self.requestor.email
		end
	end

	def set_token
		self.token = SecureRandom.hex(TOKEN_LENGTH) unless self.token
	end

	def set_expirations
		self.confirmation_expiration = Time.now.utc + ENV['confirmation_period_hours'].to_i.hours
		self.usage_expiration = Time.now.utc + ENV['usage_period_hours'].to_i.hours
	end
end
