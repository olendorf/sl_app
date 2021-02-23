# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Terminal management', type: :feature do
  let(:owner) { FactoryBot.create :owner }
  let(:terminal) { 
    terminal = FactoryBot.build :terminal, user_id: owner.id
    terminal.save
    terminal
  }

  let(:uri_regex) do
    %r{\Ahttps:\/\/sim3015.aditi.lindenlab.com:12043\/cap\/[-a-f0-9]{36}\?
       auth_digest=[a-f0-9]+&auth_time=[0-9]+\z}x
  end

  before(:each) do
    login_as(owner, scope: :user)
  end

  scenario 'User deletes a terminal' do
    stub = stub_request(:delete, uri_regex)
           .to_return(status: 200, body: '', headers: {})

    visit admin_rezzable_terminal_path(terminal)
    click_on 'Delete Rezzable Terminal'
    expect(page).to have_text('Terminal was successfully destroyed.')
    expect(stub).to have_been_requested
  end

  scenario 'User updates a terminal' do
    stub_request(:put, uri_regex)
      .with(body: /\S*/)
      .to_return(status: 200, body: '', headers: {})

    visit edit_admin_rezzable_terminal_path(terminal)
    fill_in 'Object name', with: 'foo'
    fill_in 'Description', with: 'bar'
    click_on 'Update Terminal'
    expect(page).to have_text('Terminal was successfully updated.')
  end
end