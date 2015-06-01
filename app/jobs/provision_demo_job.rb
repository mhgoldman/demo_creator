class ProvisionDemoJob < ApplicationJob
  def perform(demo)
    begin
    	demo.provision!
    rescue => ex
      msg = "#{ex.class}: #{ex.message}"

      begin
        resp = JSON.parse(ex.response)
        msg = "#{resp['error']} (#{msg})" if resp['error']
      rescue
        # if there's no JSON in the response, so be it.
      end

      demo.error!(msg)
    end
  end
end
