require 'skytap_api'

class Template < ActiveRecord::Base
	has_many :environment_requests

	def self.pull
		current_template_skytap_ids = Template.all.map {|t| t.skytap_id}
		SkytapAPI.get("projects/#{ENV['templates_project_id']}/templates").each do |template_info|
			Template.create(skytap_id: template_info.id, name: template_info.name) unless current_template_skytap_ids.include?(template_info.id.to_i)
		end

		all
	end
end
