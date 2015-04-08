namespace :demo_creator do
  desc "Pull templates"
  task pull_templates: :environment do
  	Template.pull_later
  end
end
