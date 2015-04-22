require 'skytap_api'

class Template < ActiveRecord::Base
	has_many :demos
	validates :skytap_id, presence: true
	validates :name, presence: true
	validates :region_name, presence: true

	def self.pull
		current_template_skytap_ids = Template.pluck(:skytap_id)

		new_template_info = SkytapAPI.get("projects/#{ENV['templates_project_id']}/templates")
		new_template_skytap_ids = new_template_info.map {|template_info| template_info.id.to_i}


		current_template_skytap_ids.each do |template_skytap_id|
			unless new_template_skytap_ids.include?(template_skytap_id)
				Template.find_by(skytap_id: template_skytap_id).destroy
			end
		end

		new_template_info.each do |template_info|
			Template.create(skytap_id: template_info.id, name: template_info.name, region_name: template_info.region) unless current_template_skytap_ids.include?(template_info.id.to_i)
		end

		all
	end

	def self.pull_later
		PullTemplatesJob.perform_later
	end
end
