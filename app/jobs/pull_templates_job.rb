class PullTemplatesJob < ActiveJob::Base
  queue_as :''

  def perform
  	Template.pull
  end
end
