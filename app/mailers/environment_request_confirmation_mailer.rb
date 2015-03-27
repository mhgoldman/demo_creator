class EnvironmentRequestConfirmationMailer < ApplicationMailer
	default from: 'donotreply@demo-creator.skytap.com'

	def confirmation_email(environment_request)
		@environment_request = environment_request
		mail(to: @environment_request.requestor.email, subject: 'Your Demo Environment Request')
	end
end
