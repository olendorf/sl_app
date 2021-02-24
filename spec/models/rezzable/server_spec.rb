# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rezzable::Server, type: :model do
  it { should respond_to :abstract_web_object }
  it { should have_many(:clients).class_name('AbstractWebObject').dependent(:nullify) }
  it { should have_many(:inventories).class_name('Analyzable::Inventory').dependent(:destroy) }
end
