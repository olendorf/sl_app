# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Server management', type: :feature do
  context 'admin namespace' do
    it_behaves_like 'it has a rezzable SL request behavior', :server, 'admin'
  end

  context 'my namespace' do
    it_behaves_like 'it has a rezzable SL request behavior', :server, 'my'
  end

  let(:uri_regex) do
    %r{\Ahttps://sim3015.aditi.lindenlab.com:12043/cap/[-a-f0-9]{36}/give_money\?
       auth_digest=[a-f0-9]+&auth_time=[0-9]+\z}x
  end

  feature 'sending money to an avatar' do
    let(:user) { FactoryBot.create :user }
    let(:server) { FactoryBot.create :server, user_id: user.id }

    scenario 'User gives money' do
      stub = stub_request(:post, uri_regex)
             .with(body: '{"avatar_name":"Random Citizen","amount":"200"}')
             .to_return(body: { avatar_key: SecureRandom.uuid }.to_json)
      login_as(user, scope: :user)
      visit my_server_path(server)

      fill_in 'give_money-avatar_name', with: 'Random Citizen'
      fill_in 'give_money-amount', with: 200
      click_on 'Give Money'

      expect(page).to have_text('200 lindens given to Random Citizen')
      expect(stub).to have_been_requested
      expect(user.reload.transactions.size).to eq 1
    end

    scenario 'User gives money with error' do
      stub = stub_request(:post, uri_regex)
             .with(body: '{"avatar_name":"Random Citizen","amount":"200"}')
             .to_return(status: 400, body: 'foo')
      login_as(user, scope: :user)
      visit my_server_path(server)

      fill_in 'give_money-avatar_name', with: 'Random Citizen'
      fill_in 'give_money-amount', with: 200
      click_on 'Give Money'

      expect(page).to have_text('Unable to send money to Random Citizen: foo')
      expect(stub).to have_been_requested
      expect(user.transactions.size).to eq 0
    end
  end
end
