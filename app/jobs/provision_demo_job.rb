class ProvisionDemoJob < ApplicationJob
  def perform(demo)
    begin
    	demo.provision!
    rescue => ex
      msg = "#{ex.class}: #{ex.message}"

      if ex.respond_to?(:response)
        resp = JSON.parse(ex.response)
        msg = "#{resp['error']} (#{msg})" if resp['error']
      end

      demo.update(status: :error, provisioning_error: msg)
    end
  end
end
