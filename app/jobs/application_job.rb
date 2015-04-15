class ApplicationJob < ActiveJob::Base
  DEFAULT_QUEUE = ""
  queue_as DEFAULT_QUEUE #Que uses blank queue name
end