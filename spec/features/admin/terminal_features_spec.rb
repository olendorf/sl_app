# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Terminal management', type: :feature do
  it_behaves_like 'it has a rezzable SL request behavior', :terminal
end
