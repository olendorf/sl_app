require 'rails_helper'

RSpec.describe User, type: :model do
    it { should respond_to :avatar_name }
    it { should respond_to :avatar_key }
end
