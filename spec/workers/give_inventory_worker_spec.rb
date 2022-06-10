# frozen_string_literal: true

require 'rails_helper'
RSpec.describe GiveInventoryWorker, type: :worker do
  require 'erb'
  include ERB::Util

  let(:user) { FactoryBot.create :active_user }
  let(:server) { FactoryBot.create :server, user_id: user.id }
  let(:inventory) do
    inventory = FactoryBot.create(:inventory, user_id: user.id)
    server.inventories << inventory
    inventory
  end
  let(:avatar) { FactoryBot.create :avatar }

  let(:uri_regex) do
    %r{\Ahttps://sim3015.aditi.lindenlab.com:12043/cap/[-a-f0-9]{36}/
       services/give_inventory\?auth_digest=[a-f0-9]+&auth_time=[0-9]+\z}x
  end

  describe 'queing the job' do
    it 'job in correct queue' do
      stub_request(:post, uri_regex)
        .with(body:
        "{\"inventory_name\":\"#{
            inventory.inventory_name}\",\"avatar_name\":\"#{
              avatar.avatar_name}\"}")
      described_class.perform_async(inventory.id, avatar.avatar_name)
      assert_equal 'default', described_class.queue
    end

    it 'goes into the jobs array for testing environment' do
      stub_request(:post, uri_regex)
        .with(body:
        "{\"inventory_name\":\"#{
                inventory.inventory_name}\",\"avatar_name\":\"#{
                    avatar.avatar_name}\"}")
      described_class.perform_async(inventory.id, avatar.avatar_name)
      expect(described_class.jobs.size).to eq 1
      described_class.new.perform(inventory.id, avatar.avatar_name)
    end
  end
end
