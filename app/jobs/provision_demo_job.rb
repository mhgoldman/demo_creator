class ProvisionDemoJob < ApplicationJob
  def perform(demo)
    begin
    	demo.provision!
    rescue => ex
      demo.update(status: :error, provisioning_error: "#{ex.class}: #{ex.message}")
    end
  end
end
