class PullTemplatesJob < ActiveJob::Base
  queue_as :'' #Que uses blank queue name

  def perform
  	Template.pull
  end
end
