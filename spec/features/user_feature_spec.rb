# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'User management', type: :feature do
  let(:user) { FactoryBot.create :user, account_level: 0, expiration_date: nil }
  let(:owner) { FactoryBot.create :owner }

  before(:each) do
    login_as(owner, scope: :user)
  end

  # scenario 'user attempts to increase account level with inactive account' do
  #   visit edit_admin_user_path(user)
  #   fill_in 'Account level', with: 2
  #   click_on 'Update User'
  #   expect(page).to have_text('A payment is required to activate this account.')
  # end

  # scenario 'owner deletes a manager from the users show page' do
  #   user.managers << FactoryBot.create_list(:listed_manager, 5)
  #   visit admin_user_path(user)
  #   manager = user.managers.sample
  #   click_on "delete_manager_#{manager.id}"
  #   expect(page).to have_text 'Avatar removed from the list.'
  #   expect(Listable::Avatar.exists?(manager.id)).to be_falsey
  # end
end