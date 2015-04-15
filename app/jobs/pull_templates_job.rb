class PullTemplatesJob < ApplicationJob
  def perform
  	Template.pull
  end
end
