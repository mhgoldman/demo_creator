class ProvisioningStatus
  include ActiveModel::Serializers::JSON

  attr_accessor :status_name, :percent_complete, :message

  STATUS_MAP = {
    creating: { percent_complete: 0, message: "Provisioning environment" },
    assigning: { percent_complete: 20, message: "Assigning environment ownership" },
    scheduling: { percent_complete: 40, message: "Configuring access window" },
    connecting: {percent_complete: 60, message: "Connecting to global network" },
    starting: { percent_complete: 80, message: "Starting environment" },
    complete: { percent_complete: 100, message: "Provisioning complete" }
  }.with_indifferent_access

  def initialize(status_name)
    raise ArgumentError unless STATUS_MAP.key?(status_name)
    
    @status_name = status_name
    @percent_complete = STATUS_MAP[status_name][:percent_complete]
    @message = STATUS_MAP[status_name][:message]
  end

  def attributes
    {'status_name' => nil, 'percent_complete' => nil, 'message' => nil}
  end
end