class Demo < ActiveRecord::Base
	TOKEN_LENGTH = 32

	attr_accessor :email

	belongs_to :template
	belongs_to :requestor

	enum status: [:pending, :confirmed, :provisioning, :provisioned]

	validates :template_id, presence: true
	validates :requestor_id, presence: true
	validates :email, presence: true

	before_validation :set_requestor
	before_save :set_token, :set_expirations
	before_create :set_pending

	def url
		Rails.application.routes.url_helpers.demo_url(token)
	end

	def provision_later
		ProvisionDemoJob.perform_later(self)
	end

	def provision!
		provisioning!

		config = SkytapAPI.post('configurations', 
			template_id: template.skytap_id
		)

		update(skytap_id: config.id)

		update(published_url: config.publish_sets.first.desktops_url) if config.publish_sets.length > 0

    SkytapAPI.post("schedules",
      title: "Schedule for #{config.name} - [#{config.id}]",
      configuration_id: config.id,
      start_at: Time.now.utc,
      end_at: usage_expiration,
      delete_at_end: true,
      time_zone: "UTC"
    )

    SkytapAPI.post("tunnels?source_network_id=#{config.networks.first.id}&target_network_id=#{ENV['global_network_id']}") if ENV['global_network_id']

		SkytapAPI.put(config.url,
			owner: requestor.get_skytap_url
		)

		SkytapAPI.put(config.url,
			name: name,
			runstate: "running"
		)

		provisioned!
	end

	def provisionable?
		confirmed? && !expired?
	end

	def ready?
		provisioned? && !expired?
	end

	def expired?
		self.confirmation_expiration <= Time.now || self.usage_expiration <= Time.now
	end

	private

	def name
		"Demo Environment - #{template.name} - #{requestor.email} - #{description}"
	end

	def set_requestor
		if self.email && !self.requestor
			self.requestor = Requestor.where(email: email).first || Requestor.create(email: email)
			self.save
		elsif !self.email && self.requestor
			self.email = self.requestor.email
		end
	end

	def set_token
		self.token = SecureRandom.hex(TOKEN_LENGTH) unless self.token
	end

	def set_expirations
		self.confirmation_expiration = Time.now.utc + ENV['confirmation_period_hours'].to_i.hours unless self.confirmation_expiration
		self.usage_expiration = Time.now.utc + ENV['usage_period_hours'].to_i.hours unless self.usage_expiration
	end

	def set_pending
		self.status = 'pending'
	end
end
