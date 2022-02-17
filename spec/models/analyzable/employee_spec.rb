# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Analyzable::Employee, type: :model do
  it { should belong_to :user }
  it { should have_many(:work_sessions).class_name('Analyzable::WorkSession') }

  it {
    should validate_uniqueness_of(
      :avatar_key
    ).scoped_to(:user_id).with_message('This avatar is already an employee.')
  }
end
