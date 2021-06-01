# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rezzable::Terminal, type: :model do
  # it { is_expected.to act_as(:rezzable).class_name('AbstractWebObject') }
  it { should respond_to :abstract_web_object }

  it_behaves_like 'it is a transactable', :terminal

  let(:user) { FactoryBot.create :owner }

  let(:terminal) do
    terminal = FactoryBot.build :terminal, user_id: user.id
    terminal.save
    terminal
  end

  it 'should return the correct response data' do
    expect(terminal.response_data).to eq(
      { api_key: terminal.api_key }
    )
  end
end
