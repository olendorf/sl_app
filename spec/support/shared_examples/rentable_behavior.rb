# frozen_string_literal: true

RSpec.shared_examples 'it has rentable behavior' do |_model_name|
  # let(:user) { FactoryBot.create :user }
  # let(:web_object) { FactoryBot.create model_name.to_sym }

  it { should have_many(:states).dependent(:destroy) }
end
