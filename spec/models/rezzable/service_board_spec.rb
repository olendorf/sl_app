# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rezzable::ServiceBoard, type: :model do
  it_behaves_like 'a rezzable object', :service_board, 1

  it_behaves_like 'it has rentable behavior', :service_board
end
