require 'rails_helper'

RSpec.feature "AccessExistingDemos", type: :feature do
  before do
    t = Template.create!(name: "Windows 7 Enterprise SP1 64-bit - Sysprepped", skytap_id: 248757, region_name: 'US-East')    
    @demo = Demo.create!(template: t, email: 'me@mgoldman.com')#, skytap_id: 123456, published_url: 'http://bogus/puburl', status: confirmed)
  end

  scenario "User confirms after confirmation expired" do
    @demo.update!(confirmation_expiration: 1.day.ago)

    visit(@demo.url)
    expect(page).to have_content("oh snap, you're expired")
  end

  scenario "User access after usage expired" do
    @demo.update!(usage_expiration: 1.day.ago)

    visit(@demo.url)
    expect(page).to have_content("oh snap, you're expired")
  end

  scenario "User accesses existing demo that isn't provisioned yet" do
    @demo.provisioning!

    visit(@demo.url)
    expect(page).to have_content("hold your horses, i'm working on it")
  end

  scenario "User access existing demo successfully" do
    @demo.update!(status: :provisioned, skytap_id: 123456, published_url: 'http://bogus/url')

    visit(@demo.url)
    expect(page).to have_content("ok, here is your environment: http://bogus/url")
  end
end
