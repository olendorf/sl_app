# frozen_string_literal: true

ActiveAdmin.register Analyzable::Inventory, as: 'Inventory' do
  include ActiveAdmin::InventoryBehavior

  menu label: 'Inventory'

  decorate_with Analyzable::InventoryDecorator

  actions :all, except: %i[new create]

  index titles: 'Inventory' do
    selectable_column
    column 'Name' do |inventory|
      link_to inventory.inventory_name, admin_inventory_path(inventory)
    end
    column 'Description' do |inventory|
      truncate(inventory.inventory_description, length: 10, separator: ' ')
    end
    column :price
    column 'Server' do |inventory|
      link_to inventory.server.object_name, admin_server_path(inventory.server_id)
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
    column 'Product' do |inventory|
      
      product_link = inventory.user.product_links.find_by_link_name(inventory.inventory_name)
      if product_link
        link_to product_link.product.product_name, admin_product_path(product_link.product)
      else
        'No Product Linked'
      end
    end
    
    column 'Revenue' do |inventory|
      inventory.revenue
    end
    column "Units Sold" do |inventory|
      inventory.transactions_count
    end
    column :created_at
    column :updated_at
    actions
  end

  filter :inventory_name
  filter :inventory_description, label: 'Description'
  filter :server_abstract_web_object_object_name, as: :string, label: 'Server Name'
  filter :user_avatar_name, as: :string, label: 'User Name'
  filter :price, as: :numeric
  filter :inventory_type, as: :select, collection: Analyzable::Inventory.inventory_types
  filter :created_at, as: :date_range
  filter :updated_at, as: :date_range

  sidebar :give_inventory, partial: 'give_inventory_form', only: %i[show edit]

  show title: :inventory_name do
    attributes_table do
      row 'Name', &:inventory_name
      row 'Type', &:inventory_type
      row :price
      row 'Product' do |inventory|
      
        product_link = inventory.user.product_links.find_by_link_name(inventory.inventory_name)
        if product_link
          link_to product_link.product.product_name, admin_product_path(product_link.product)
        else
          'No Product Linked'
        end
      end
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
        link_to inventory.server.object_name, admin_server_path(inventory.server)
      end
      row 'Sales' do |inventory|
        # sales = inventory.sales
        "#{inventory.revenue} $L (#{inventory.transactions_count})"
      end
      row 'Date/Time',  &:created_at
    end
    
    panel 'Sales' do 
      paginated_collection(
        resource.sales.page(
          params[:sales_page]
        ).per(10), param_name: 'sales_page'
      ) do 
        table_for collection.order(created_at: :desc), download_links: false do 
          column 'Date/Time' do |sale|
            link_to sale.created_at.to_s(:long), admin_transaction_path(sale)
          end
          column 'Customer', &:target_name
          column 'amount'
        end
      end
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
  controller do
    def scoped_collection
      super.includes(%i[server user])
    end

    def destroy
      begin
        InventorySlRequest.delete_inventory(resource)
      rescue RestClient::ExceptionWithResponse => e
        flash[:error] = t('active_admin.inventory.delete.failure',
                          message: e.response)
      end
      super
    end

    def update
      if params['analyzable_inventory']['server_id']
        begin
          InventorySlRequest.move_inventory(
            resource, params['analyzable_inventory']['server_id']
          )
        rescue RestClient::ExceptionWithResponse => e
          flash[:error] = t('active_admin.inventory.move.failure',
                            message: e.response)
        end
      end
      super
    end

    def batch_action
      if params['batch_action'] == 'destroy'
        InventorySlRequest.batch_destroy(
          params['collection_selection']
        )
      end
      super
    end
  end
end
