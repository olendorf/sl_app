# frozen_string_literal: true

ActiveAdmin.register Analyzable::Inventory do
  include ActiveAdmin::InventoryBehavior

  menu label: 'Inventory'

  decorate_with Analyzable::InventoryDecorator

  actions :all, except: %i[new create ]
  
  index titles: 'Inventory' do 
    column 'Name' do |inventory|
      link_to inventory.inventory_name, admin_analyzable_inventory_path(inventory)
    end
    column 'Description' do |inventory|
      truncate(inventory.inventory_description, length: 10, separator: ' ')
    end
    column :price
    column 'Server' do |inventory|
      link_to inventory.server.object_name, admin_rezzable_server_path(inventory.server_id)
    end
    column 'User' do |inventory|
      link_to inventory.user.avatar_name, admin_user_path(inventory.user_id)
    end 
    column 'Inventory Type' do |inventory|
      inventory.inventory_type.titlecase
    end
    column 'Owner Perms' do |inventory|
      inventory.pretty_perms(:owner)
    end
    column 'Next Perms' do |inventory|
      inventory.pretty_perms(:next)
    end
    column :created_at
    column :updated_at
    actions
  end
  
  filter :inventory_name
  filter :inventory_description, label: 'Description'
  filter :user_avatar_name, as: :string, label: 'Object Name'
  filter :price, as: :numeric
  filter :inventory_type, as: :select, collection: Analyzable::Inventory.inventory_types
  filter :created_at, as: :date_range
  filter :updated_at, as: :date_range

  show title: :inventory_name do
    attributes_table do
      row 'Name', &:inventory_name
      row 'Type', &:inventory_type
      row 'Owner' do |inventory|
        link_to inventory.server.user.avatar_name, admin_user_path(inventory.server.user)
      end
      row 'Owner Perms' do |inventory|
        inventory.pretty_perms(:owner)
      end
      row 'Next Perms' do |inventory|
        inventory.pretty_perms(:next)
      end
      row 'Server' do |inventory|
        link_to inventory.server.object_name, admin_rezzable_server_path(inventory.server)
      end
      row :created_at
    end
  end

  # sidebar :give_inventory, partial: 'give_inventory_form', only: %i[show edit]

  permit_params :server_id, :price, :inventory_description

  form title: proc { "Edit #{resource.inventory_name}" } do |f|
    f.inputs do
      f.input :price
      f.input :inventory_description, label: 'Description'
      f.input :server, as: :select,
                       include_blank: false,
                       collection: resource.server.user.servers.map { |s|
                         [s.object_name, s.id]
                       }
    end
    f.actions do
      f.action :submit
      f.cancel_link(action: 'show')
    end
  end

  # member_action :give, method: :post do
  #   redirect_back notice: "Given!"
  # end
end

