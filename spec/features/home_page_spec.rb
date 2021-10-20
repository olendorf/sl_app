# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Home page features', type: :feature do
  let(:user) { FactoryBot.create :user }
  let(:owner) { FactoryBot.create :owner }

  context 'user not logged in' do
    scenario 'user should see sign in link' do
      visit root_path
      expect(page).to have_link('Login', href: new_user_session_path)
    end

    scenario 'user cannot visit admin pages' do
      visit admin_root_path
      expect(page).to have_current_path(new_user_session_path)
      expect(page).to have_content('You need to sign in or sign up before continuing.')
    end
  end

  context 'admin logs in' do
    before(:each) do
      visit pages_home_path
      click_on('Login')
      fill_in('Avatar name', with: owner.avatar_name)
      fill_in('Password', with: 'Pa$sW0rd')
      click_on('Log in')
    end
    scenario ' and visits admin pages' do
      expect(page).to have_current_path(admin_dashboard_path)
    end

    scenario ' and visists home page' do
      visit pages_home_path
      find('.dropdown a', text: owner.avatar_name)
      expect(page).to have_content(owner.avatar_name)
      expect(page).to have_link('Logout', href: destroy_user_session_path)
      expect(page).to have_link('My stuff', href: my_dashboard_path)
      expect(page).to have_link('Admin stuff', href: admin_dashboard_path)
    end

    scenario ' user signs out' do
      visit pages_home_path
      click_on('Logout')
      expect(page).to have_content('Signed out successfully.')
      expect(page).to have_current_path(root_path)
    end
  end

  context 'user is logged in' do
    scenario 'user cannot visit admin pages' do
      login_as(user, scope: :user)
      visit admin_root_path
      expect(page).to_not have_current_path(admin_root_path)
      expect(page).to have_link('Logout', href: destroy_user_session_path)
    end
  end
end
