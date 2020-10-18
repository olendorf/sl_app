require 'rails_helper'

RSpec.describe Rezzable::Terminal, type: :model do
  # it { is_expected.to act_as(:rezzable).class_name('AbstractWebObject') }
  it { should respond_to :rezzable }
end
