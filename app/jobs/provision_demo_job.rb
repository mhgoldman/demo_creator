class ProvisionDemoJob < ActiveJob::Base
  queue_as :''

  def perform(demo)
  	#TODO! PRevent infinite unrecoverable retries!
  	demo.provision!
  end
end
