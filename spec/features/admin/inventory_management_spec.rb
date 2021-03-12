# frozen_string_literal: true

require 'rails_helper'
# Capybara.register_driver :selenium do |app|
#     Capybara::Selenium::Driver.new(app, browser: :chrome)
# end

RSpec.feature 'Inventory management', type: :feature do
  context 'admin namespace' do
    it_behaves_like 'it has inventory request behavior', 'admin'
  end

  context 'my namespace' do
    it_behaves_like 'it has inventory request behavior', 'my'
  end
end
