# frozen_string_literal: true

module Analyzable
  # Model of Inventory in SL
  class Inventory < ApplicationRecord
    validates_presence_of :inventory_name
    validates :inventory_name, uniqueness: { scope: :server_id }
    validates_presence_of :inventory_type
    validates_presence_of :owner_perms
    validates_presence_of :next_perms

    belongs_to :user, optional: true
    belongs_to :server, class_name: 'Rezzable::Server'
    has_many :sales, class_name: 'Analyzable::Transaction', 
                     dependent: :nullify

    enum inventory_type: {
      texture: 0,
      sound: 1,
      landmark: 3,
      clothing: 5,
      object: 6,
      notecard: 7,
      script: 10,
      body_part: 13,
      animation: 20,
      gesture: 21,
      setting: 56
    }

    # Some metaprogramming here to generate methods to determine
    # the perms of an inventory along the lines of owner_can_modify? or
    # next_can_transfer?
    PERMS = { copy: 0x00008000, modify: 0x0004000, transfer: 0x00002000 }.freeze

    %i[owner next].each do |who|
      PERMS.each do |perm, _value|
        define_method("#{who}_can_#{perm}?") do
          (send("#{who}_perms") & PERMS[perm]).positive?
        end
      end
    end
  end
end
