require 'rails_helper'

RSpec.describe Demo, type: :model do
  context ".create" do
    it "requires a whitelisted email or requestor to save" do
      t = Template.create!(name: "Windows 7 Enterprise SP1 64-bit - Sysprepped", skytap_id: 248757, region_name: 'US-East')

      demo = Demo.new(template: t)
      expect(demo).to_not be_valid

      demo.email = 'foo@bar.com'
      expect(demo).to_not be_valid

      demo = Demo.new(template: t)      
      demo.email = 'me@skytap.com'
      expect(demo).to be_valid
      expect(demo.requestor).to_not be_nil

      demo2 = Demo.new(template: t, requestor: demo.requestor)
      expect(demo2).to be_valid
    end

    it "re-uses an existing requestor with same email" do
      t = Template.create(name: "Windows 7 Enterprise SP1 64-bit - Sysprepped", skytap_id: 248757, region_name: 'US-East')
      demo = Demo.create!(template: t, email: 'me@skytap.com')
      demo2 = Demo.create!(template: t, email: 'me@skytap.com')

      expect(demo.requestor).to eq(demo2.requestor)
    end

    it "sets the token, expirations & status" do
      t = Template.create(name: "Windows 7 Enterprise SP1 64-bit - Sysprepped", skytap_id: 248757, region_name: 'US-East')
      demo = Demo.create!(template: t, email: 'me@skytap.com')

      expect(demo.token.length).to eq(Demo::TOKEN_LENGTH * 2)
      expect(demo.confirmation_expiration).to be_a(Time)
      expect(demo.usage_expiration).to be_a(Time)
      expect(demo).to be_pending
    end
  end

  context ".provision" do
    it "provisions the demo" do
      t = Template.create(name: "Windows 7 Enterprise SP1 64-bit - Sysprepped", skytap_id: 248757, region_name: 'US-East')
      demo = Demo.create!(template_id: t.id, email: 'me@skytap.com')
      demo.save!
      demo.confirmed!

      VCR.use_cassette("demo_provisioning") do
        demo.provision!
      end
    end
  end
end
