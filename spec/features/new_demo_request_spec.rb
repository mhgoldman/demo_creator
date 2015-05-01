require 'rails_helper'

RSpec.feature "DemoRequests", type: :feature do
  before do
    ActionMailer::Base.deliveries.clear
    t = Template.create!(name: "Windows 7 Enterprise SP1 64-bit - Sysprepped", skytap_id: 248757, region_name: 'US-East')
  end

  scenario "User requests demo with bad info" do
    visit root_path
    click_button 'Create Demo'
    expect(page).to have_content('Nope, try again')
  end

  scenario 'User requests demo successfully' do
    visit root_path
    select 'Windows 7 Enterprise SP1 64-bit - Sysprepped', from: 'Template'
    fill_in 'Email', with: 'me@mgoldman.com'
    fill_in 'Description', with: 'my kewl demo'
    click_button 'Create Demo'
    expect(page).to have_content('OK, check your email')

    open_email('me@mgoldman.com')

    VCR.use_cassette("demo_provisioning") do
      click_first_link_in_email
    end

    expect(page).to have_content('started provisioning')

    visit(current_path)
    expect(page).to have_content('ok, here is your environment')
  end

  scenario 'User accesses expired demo' do
    visit root_path
    select 'Windows 7 Enterprise SP1 64-bit - Sysprepped', from: 'Template'
    fill_in 'Email', with: 'me@mgoldman.com'
    fill_in 'Description', with: 'my kewl demo'
    click_button 'Create Demo'
    expect(page).to have_content('OK, check your email')

    open_email('me@mgoldman.com')

    VCR.use_cassette("demo_provisioning") do
      click_first_link_in_email
    end

    expect(page).to have_content('started provisioning')

    visit(current_path)
    expect(page).to have_content('ok, here is your environment')
  end

end
