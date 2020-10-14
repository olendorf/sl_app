# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  it { should respond_to :avatar_name }
  it { should respond_to :avatar_key }

  it { should define_enum_for(:role).with_values(%i[user prime admin owner]) }

  let(:user)  { FactoryBot.create :user }
  let(:prime) { FactoryBot.create :prime }
  let(:admin) { FactoryBot.build :admin }
  let(:owner) { FactoryBot.create :owner }
  
  it { should have_many :abstract_web_objects }

  describe 'can be' do
    User.roles.each do |role, _value|
      it { should respond_to "can_be_#{role}?".to_sym }
    end
    it 'should properly test can_be_<role>?' do
      expect(admin.can_be_owner?).to be_falsey
      expect(admin.can_be_user?).to be_truthy
      expect(owner.can_be_user?).to be_truthy
      expect(user.admin?).to be_falsey
      expect(user.can_be_user?).to be_truthy
      expect(prime.can_be_user?).to be_truthy
      expect(prime.can_be_prime?).to be_truthy
      expect(prime.can_be_admin?).to be_falsey
    end
  end
end
