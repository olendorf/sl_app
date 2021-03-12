# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Server management', type: :feature do
  context 'admin namespace' do
    it_behaves_like 'it has a rezzable SL request behavior', :server, 'admin'
  end

  context 'my namespace' do
    it_behaves_like 'it has a rezzable SL request behavior', :server, 'my'
  end
end
