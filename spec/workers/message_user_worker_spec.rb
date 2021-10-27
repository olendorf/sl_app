# frozen_string_literal: true

require 'rails_helper'
RSpec.describe MessageUserWorker, type: :worker do
  let(:owner) { FactoryBot.create :owner }

  before(:each) do
    3.times do
      owner.web_objects << FactoryBot.create(:server)
    end
  end

  let(:uri_regex) do
    %r{\Ahttps://sim3015.aditi.lindenlab.com:12043/cap/[-a-f0-9]{36}/message_user\?
       auth_digest=[a-f0-9]+&auth_time=[0-9]+\z}x
  end

  describe 'queing the job' do
    it 'job in correct queue' do
      stub_request(:post, uri_regex)
        .with(body:
        /"avatar_name":.*Random Citizen.*Your SLapp Data account expired .*maps.secondlife.com.*/)
      described_class.perform_async(owner.servers.sample.id, 'Random Citizen', SecureRandom.uuid, 3.days.ago)
      assert_equal 'default', described_class.queue
    end

    it 'goes into the jobs array for testing environment' do
      stub_request(:post, uri_regex)
        .with(body:
        /"avatar_name":.*Random Citizen.*Your SLapp Data account expired .*maps.secondlife.com.*/)
      expect do
        described_class.perform_async(owner.servers.sample.id, 'Random Citizen', SecureRandom.uuid, 3.days.ago)
      end.to change(described_class.jobs, :size).by(1)
      described_class.new.perform(owner.servers.sample.id, 'Random Citizen', SecureRandom.uuid, 3.days.ago)
    end
  end
end
