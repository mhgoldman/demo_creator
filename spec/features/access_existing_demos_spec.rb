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
    expect(page).to have_content("Please wait while your demo is provisioned")
  end

  scenario "User accesses existing demo successfully" do
    @demo.update!(status: :provisioned, skytap_id: 123456, published_url: 'http://bogus/url')

    visit(@demo.url)
    expect(page).to have_content("Your demo is available")
    expect(page).to have_link("Access Demo", href: 'http://bogus/url')
  end

  scenario "User accesses existing demo in an error state" do
    @demo.update!(status: :error, skytap_id: 123456, provisioning_error: 'something bad happened')

    visit(@demo.url)
    expect(page).to have_content("An error has occurred")
    expect(page).to have_content("something bad happened")
  end

  scenario "Demo status is updated in real time", js: true do
    @demo.provisioning!

    visit(@demo.url)

    expect(page).to have_content("Please wait while your demo is provisioned")

    # TODO This doesn't work because the href doesn't get updated until you click the button. Why?
    @demo.update!(status: :provisioned, skytap_id: 123456, published_url: 'http://bogus/url')
    sleep 10

    expect(page).not_to have_content("Please wait while your demo is provisioned")
    expect(page).to have_content("Your demo is available")
    expect(page).to have_link("Access Demo", href: 'http://bogus/url')

  end
end
