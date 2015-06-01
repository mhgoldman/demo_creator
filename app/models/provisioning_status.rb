class ProvisioningStatus
  attr_accessor :status, :percent_complete, :message

  STATUS_MAP = {
    started: [10, "Its started!"],
    pre_something: [50, "Half way pre something"],
    done: [100, "Completed"]
  }

  def initialize(status)
    @status = status
    @percent_complete = STATUS_MAP[status].first
    @message = STATUS_MAP[status].last
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