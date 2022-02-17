# frozen_string_literal: true

require 'rails_helper'
RSpec.describe PayUserWorker, type: :worker do
  # require 'erb'
  # include ERB::Util

  let(:user) { FactoryBot.create :active_user }
  let(:server) { FactoryBot.create :server, user_id: user.id }
  let(:avatar) { FactoryBot.create :avatar }

  let(:uri_regex) do
    %r{\Ahttps://sim3015.aditi.lindenlab.com:12043/cap/[-a-f0-9]{36}/pay_user\?
       auth_digest=[a-f0-9]+&auth_time=[0-9]+\z}x
  end

  describe 'queing the job' do
    it 'job in correct queue' do
      reg_str = '{|"avatar_name\":\".*,\"avatar_key\":.*\",\"amount":"100"}'
      stub_request(:put, uri_regex)
        .with(body: /#{reg_str}/)
      # ServerSlRequest.pay_user(
      #   user.servers.sample.id, employee.avatar_name, employee.avatar_key, employee.pay_owed
      # )
      described_class.perform_async(server.id, avatar.avatar_name, avatar.avatar_key, 100)
      assert_equal 'default', described_class.queue
    end

    # it 'goes into the jobs array for testing environment' do
    #   stub_request(:post, uri_regex)
    #     .with(body:
    #     "{\"avatar_key\":\"#{avatar.avatar_key}\"}")
    #   described_class.perform_async(inventory.id, avatar.avatar_key)
    #   expect(described_class.jobs.size).to eq 1
    #   described_class.new.perform(inventory.id, avatar.avatar_key)
    # end
  end
end
