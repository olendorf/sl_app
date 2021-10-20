# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Pages', type: :request do
  %w[home products pricing documentation faqs].each do |page|
    describe "GET /#{page}" do
      it 'returns http success' do
        get "/pages/#{page}"
        expect(response).to have_http_status(:success)
      end
    end
  end
end
