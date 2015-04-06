class DemoConfirmationMailer < ApplicationMailer
	default from: 'donotreply@demo-creator.skytap.com'

	def confirmation_email(demo)
		@demo = demo
		mail(to: @demo.requestor.email, subject: 'Your Demo Environment Request')
	end
end
