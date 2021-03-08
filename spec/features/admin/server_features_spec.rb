# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Server management', type: :feature do
  it_behaves_like 'it has a rezzable SL request behavior', :server
end