class DemoConfirmationMailer < ApplicationMailer
	default from: ENV['mail_from']

	def confirmation_email(demo)
		@demo = demo
		mail(to: @demo.requestor.email, subject: 'Your Demo Environment Request')
	end
end
