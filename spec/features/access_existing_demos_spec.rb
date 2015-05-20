require 'rails_helper'

RSpec.feature "AccessExistingDemos", type: :feature do
  before do
    t = Template.create!(name: "Windows 7 Enterprise SP1 64-bit - Sysprepped", skytap_id: 248757, region_name: 'US-East')    
    @demo = Demo.create!(template: t, email: 'me@mgoldman.com')
  end

  scenario "User confirms after confirmation expired" do
    @demo.update!(confirmation_expiration: 1.day.ago)

    visit(@demo.url)
    expect(page).to have_content("Your demo has expired")
  end

  scenario "User access after usage expired" do
    @demo.update!(usage_expiration: 1.day.ago)

    visit(@demo.url)
    expect(page).to have_content("Your demo has expired")
  end

  scenario "User accesses existing demo that isn't provisioned yet" do
    @demo.provisioning!

    visit(@demo.url)
    expect(page).to have_content("Your demo is provisioning")
  end

  scenario "User accesses existing demo successfully" do
    @demo.update!(status: :provisioned, skytap_id: 123456, published_url: 'http://bogus/url')

    visit(@demo.url)
    expect(page).to have_content("to access your environment")
    expect(page).to have_link("click here", href: 'http://bogus/url')
  end

  xscenario "User accesses existing demo in an error state"

  scenario "Demo status is updated in real time", js: true do
    @demo.provisioning!

    visit(@demo.url)

    expect(page).to have_content("Your demo is provisioning")

    @demo.update!(status: :provisioned, skytap_id: 123456, published_url: 'http://bogus/url')
    expect(page).not_to have_content("Your demo is provisioning")
    expect(page).to have_content("to access your environment")
    expect(page).to have_link("click here", href: 'http://bogus/url')

  end
end
