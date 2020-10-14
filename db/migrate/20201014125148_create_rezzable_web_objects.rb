# frozen_string_literal: true

class CreateRezzableWebObjects < ActiveRecord::Migration[6.0]
  def change
    create_table :rezzable_web_objects, &:timestamps
  end
end
