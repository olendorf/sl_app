# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Home page features', type: :feature do
  let(:user) { FactoryBot.create :user }
  let(:owner) { FactoryBot.create :owner }

  context 'user not logged in' do
    scenario 'user should see sign in link' do
      visit root_path
      expect(page).to have_link('Sign In', href: new_user_session_path)
    end
    
    scenario 'user cannot visit admin pages' do
      visit admin_root_path
      expect(page).to have_current_path(new_user_session_path)
      expect(page).to have_content('You need to sign in or sign up before continuing.')
    end
  end
  
  context 'admin logs in' do
    before(:each) do
      visit static_pages_home_path
      click_on('Sign In')
      fill_in('Avatar name', with: owner.avatar_name)
      fill_in('Password', with: 'password')
      click_on('Log in')
    end
    scenario ' and visits admin pages' do
      expect(page).to have_current_path(admin_root_path)
    end
  end

  context 'user is logged in' do
    scenario 'user cannot visit admin pages' do
      login_as(user, scope: :user)
      visit admin_root_path
      expect(page).to_not have_current_path(admin_root_path)
    end
  end
end