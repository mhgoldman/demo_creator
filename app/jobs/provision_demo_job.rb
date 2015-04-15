class ProvisionDemoJob < ApplicationJob
  def perform(demo)
  	#TODO! PRevent infinite unrecoverable retries!
  	demo.provision!
  end
end
