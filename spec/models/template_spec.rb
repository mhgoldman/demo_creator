require 'rails_helper'

RSpec.describe Template, type: :model do
  context ".pull" do
    it "handles starting with no templates and receiving templates from the server" do
      VCR.use_cassette("templates_pull_with_3_templates", decode_compressed_response: true) do
        Template.pull
      end

      templates = Template.all
      expect(templates.size).to eq(3)
      expect(templates[0].name).to eq "Windows 7 Enterprise SP1 64-bit - Sysprepped"
      expect(templates[1].name).to eq "Demo Environment Template"
      expect(templates[2].name).to eq "Demo Environment Template 2"
    end

    it "handles starting with no templates and NOT receiving templates from the server" do
      VCR.use_cassette("templates_pull_with_no_templates", decode_compressed_response: true) do
        Template.pull
      end

      templates = Template.all
      expect(templates.size).to eq(0)
    end


    it "handles starting with some templates and NOT receiving templates from the server" do
      Template.create!(name: 'test template 1', skytap_id: 12345, region_name: 'US-East')
      Template.create!(name: 'test template 2', skytap_id: 23456, region_name: 'US-West')

      VCR.use_cassette("templates_pull_with_no_templates", decode_compressed_response: true) do
        Template.pull
      end

      templates = Template.all
      expect(templates.size).to eq(0)
    end

    it "does nothing if the existing records match those on the server" do
      Template.create(name: "Windows 7 Enterprise SP1 64-bit - Sysprepped", skytap_id: 248757, region_name: 'US-East')
      Template.create(name: "Demo Environment Template", skytap_id: 557121, region_name: 'US-East')
      Template.create(name: "Demo Environment Template 2", skytap_id: 557145, region_name: 'US-East')

      VCR.use_cassette("templates_pull_with_3_templates", decode_compressed_response: true) do
        Template.pull
      end

      templates = Template.all
      expect(templates.size).to eq(3)
      expect(templates.map {|t| t.skytap_id}.sort).to eq([248757, 557121, 557145])
    end

    it "adds only templates that have been added on the server" do
      Template.create(name: "Windows 7 Enterprise SP1 64-bit - Sysprepped", skytap_id: 248757, region_name: 'US-East')

      VCR.use_cassette("templates_pull_with_3_templates", decode_compressed_response: true) do
        Template.pull
      end

      templates = Template.all
      expect(templates.size).to eq(3)
      expect(templates.map {|t| t.skytap_id}.sort).to eq([248757, 557121, 557145])            
    end

    it "removes only templates that have been removed on the server" do
      Template.create(name: "Windows 7 Enterprise SP1 64-bit - Sysprepped", skytap_id: 248757, region_name: 'US-East')
      Template.create(name: "Demo Environment Template", skytap_id: 557121, region_name: 'US-East')
      Template.create(name: "Demo Environment Template 2", skytap_id: 557145, region_name: 'US-East')
      Template.create(name: "This Template Ain't On The Server", skytap_id: 123456, region_name: 'US-East')

      VCR.use_cassette("templates_pull_with_3_templates", decode_compressed_response: true) do
        Template.pull
      end

      templates = Template.all
      expect(templates.size).to eq(3)
      expect(templates.map {|t| t.skytap_id}.sort).to eq([248757, 557121, 557145])
    end
  end
end
