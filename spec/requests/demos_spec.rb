require 'rails_helper'

RSpec.describe "Demos", type: :request do
  describe "GET / (demos)" do
    it "responds to not_found requests correctly" do
      expect {
          get demo_path('nonexistent'), nil, { 'HTTP_ACCEPT' => 'application/json' }
        }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "responses to bad_requests correctly" do
      template = Template.create!(name: "Windows 7 Enterprise SP1 64-bit - Sysprepped", skytap_id: 248757, region_name: 'US-East')
      demo = Demo.create!(template: template, email: 'me@skytap.com')
      demo.update(confirmation_expiration: 10.years.ago)

      get demo.url, nil, { 'HTTP_ACCEPT' => 'application/json' }
      expect(response).to have_http_status(:bad_request)
    end

    it "responds to good requests with json containing required attributes" do
      template = Template.create!(name: "Windows 7 Enterprise SP1 64-bit - Sysprepped", skytap_id: 248757, region_name: 'US-East')
      demo = Demo.create!(template: template, email: 'me@skytap.com')

      expected_attributes = [:id, :status, :description, :token, :published_url, :skytap_id, :provisioning_error]
      expected_date_attributes = [:confirmation_expiration, :usage_expiration]
      expected_template_attributes = [:id, :skytap_id, :name, :region_name]
      expected_requestor_attributes = [:id, :email, :skytap_url]
      expected_provisioning_status_attributes = [:status_name, :percent_complete, :message]

      demo.provisioning!

      get demo.url, nil, { 'HTTP_ACCEPT' => 'application/json' }
      expect(response).to have_http_status(:ok)

      demo.reload
      demo_json = json[:demo]

      expected_attributes.each do |attr|
        expect(demo_json[attr]).to eq(demo.send(attr))
      end

      expected_date_attributes.each do |attr|
        expect(demo_json[attr]).to eq(demo.send(attr).iso8601)
      end

      expected_template_attributes.each do |attr|
        expect(demo_json[:template][attr]).to eq(demo.template.send(attr))
      end

      expected_requestor_attributes.each do |attr|
        expect(demo_json[:requestor][attr]).to eq(demo.requestor.send(attr))
      end

      expected_provisioning_status_attributes.each do |attr|
        expect(demo_json[:provisioning_status][attr]).to eq(demo.provisioning_status.send(attr))
      end
    end
  end
end
