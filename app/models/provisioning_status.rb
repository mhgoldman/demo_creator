class ProvisioningStatus
  attr_accessor :status_name, :percent_complete, :message

  STATUS_MAP = {
    creating: { percent_complete: 0, message: "Provisioning environment" },
    assigning: { percent_complete: 20, message: "Assigning environment ownership" },
    scheduling: { percent_complete: 40, message: "Configuring access window" },
    connecting: {percent_complete: 60, message: "Connecting to global network" },
    starting: { percent_complete: 80, message: "Starting environment" },
    complete: { percent_complete: 100, message: "Provisioning complete" }
  }

  def initialize(status_name)
    @status_name = status_name
    @percent_complete = STATUS_MAP[status_name][:percent_complete]
    @message = STATUS_MAP[status_name][:message]
  end
end

# class Demo

#   composed_of :provisioning_status, mapping: %w(provisioning_status status)
# end

# demo.provisioning_status
# demo.provisioning_status.status
# demo.provisioning_status.percent_complete
# demo.provisioning_status.message

#http://api.rubyonrails.org/classes/ActiveRecord/Aggregations/ClassMethods.html