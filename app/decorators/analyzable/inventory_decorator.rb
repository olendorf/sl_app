# frozen_string_literal: true

module Analyzable
  # Decorator for the Analyzable::Inventory class
  class InventoryDecorator < Draper::Decorator
    delegate_all

    def pretty_perms(who)
      output = []
      Analyzable::Inventory::PERMS.each do |perm, flag|
        output << perm.to_s.titlecase if (flag & send("#{who}_perms")).positive?
      end
      output.join('|')
    end
    
  end
end
