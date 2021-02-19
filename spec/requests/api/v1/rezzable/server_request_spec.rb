# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Rezzable::Servers', type: :request do
  it_behaves_like 'a user object API', :server
end
