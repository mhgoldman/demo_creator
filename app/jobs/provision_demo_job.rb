class ProvisionDemoJob < ActiveJob::Base
  queue_as :'' #Que uses blank queue name

  def perform(demo)
  	#TODO! PRevent infinite unrecoverable retries!
  	demo.provision!
  end
end
