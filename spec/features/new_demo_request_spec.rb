require 'rails_helper'

RSpec.feature "DemoRequests", type: :feature do
  before do
    ActionMailer::Base.deliveries.clear
    t = Template.create!(name: "Demo Environment Template 2", skytap_id: 557145, region_name: 'US-East')
  end

  scenario "User requests demo with bad info" do
    visit root_path
    click_button 'Create Demo'
    expect(page).to have_content('Please correct the errors below')
  end

  scenario 'User requests demo successfully' do
    visit root_path
    select 'Demo Environment Template 2', from: 'Template'
    fill_in 'Email', with: 'me@skytap.com'
    fill_in 'Description', with: 'my kewl demo'
    click_button 'Create Demo'
    expect(page).to have_content('OK, check your email')

    open_email('me@skytap.com')

    VCR.use_cassette("demo_provisioning") do
      click_first_link_in_email
    end

    expect(page).to have_content('Please wait while provisioning starts')

    visit(current_path)
    expect(page).to have_content('Your demo is available')
  end

  scenario 'Use requests demo successfully with JS', js: true do
    visit root_path
    select 'Demo Environment Template 2', from: 'Template'
    fill_in 'Email', with: 'me@skytap.com'
    fill_in 'Description', with: 'my kewl demo'
    click_button 'Create Demo'
    expect(page).to have_content('OK, check your email')

    demo = Demo.last
    demo.provisioning!

    visit demo_path(demo)

    expect(page).to have_content('Please wait while your demo is provisioned')
    expect(page).to have_content('Provisioning environment')

    demo.update(provisioning_status_name: :adding)
    expect(page).to have_content('Adding environment to project')

    demo.update(provisioning_status_name: :assigning)
    expect(page).to have_content('Assigning environment ownership')

    demo.update(provisioning_status_name: :scheduling)
    expect(page).to have_content('Configuring access window')

    demo.update(provisioning_status_name: :connecting)
    expect(page).to have_content('Connecting to global network')

    demo.update(provisioning_status_name: :starting)
    expect(page).to have_content('Starting environment')

    demo.update(provisioning_status_name: :complete)
    demo.provisioned!
    expect(page).to have_content('Your demo is available')

  end
end
