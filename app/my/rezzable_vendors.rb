# frozen_string_literal: true

ActiveAdmin.register Rezzable::Vendor, as: 'Vendor', namespace: :my do
  include ActiveAdmin::RezzableBehavior

  menu parent: 'Objects', label: 'Vendors', if: proc {
                                                  current_user.vendors.size.positive?
                                                }

  actions :all, except: %i[new create]

  scope_to :current_user, association_method: :vendors

  decorate_with Rezzable::VendorDecorator

  filter :abstract_web_object_object_name, as: :string, label: 'Object Name'
  filter :abstract_web_object_description, as: :string, label: 'Description'
  filter :abstract_web_object_region, as: :string, label: 'Region'
  filter :web_object_pinged_at, as: :date_range, label: 'Last Ping'
  filter :abstract_web_object_create_at, as: :date_range, label: 'Date Created'
  filter :goal

  index title: 'Vendors' do
    selectable_column
    column 'Object Name', sortable: :object_name do |vendor|
      link_to vendor.object_name, my_vendor_path(vendor)
    end
    column 'Description' do |vendor|
      truncate(vendor.description, length: 10, separator: ' ')
    end
    column 'Location', sortable: :region, &:slurl
    column 'Server', sortable: 'server.object_name' do |vendor|
      link_to vendor.server.object_name,
              my_server_path(vendor.server) if vendor.server
    end
    column 'Inventory' do |vendor|
      inventory = vendor.server.inventories.find_by_inventory_name(
        vendor.inventory_name
      )
      if inventory
        link_to inventory.inventory_name, my_inventory_path(inventory)
      else
        'No Inventory'
      end
    end
    column 'Sales ', &:transactions_count
    column 'Revenue', &:revenue
    column 'Version', &:semantic_version
    column :status, &:pretty_active

    column :created_at, sortable: :created_at
    actions
  end

  show title: :object_name do
    attributes_table do
      row 'Image' do |vendor|
        if vendor.image_key
          image_tag "http://secondlife.com/app/image/#{vendor.image_key}/1"
        else
          image_tag 'no_image_available'
        end
      end
      row :object_name, &:object_name
      row :object_key, &:object_key
      row :description
      row 'Server' do |vendor|
        if vendor.server
          link_to vendor.server.object_name, my_server_path(vendor.server)
        else
          ''
        end
      end
      row 'Inventory' do |vendor|
        inventory = vendor.server.inventories.find_by_inventory_name(vendor.inventory_name)
        if inventory
          link_to inventory.inventory_name, my_inventory_path(inventory)
        else
          'No Inventory'
        end
      end
      row :location, &:slurl
      row 'Sales' do |vendor|
        "#{vendor.revenue} $L (#{vendor.transactions_count} sales)"
      end
      row :created_at
      row :updated_at
      row :pinged_at
      row :version, &:semantic_version
      row :status, &:pretty_active
    end

    panel '' do
      div class: 'column md' do
        h1 'Sales'
        paginated_collection(
          resource.sales.page(
            params[:sales_page]
          ).per(10), param_name: 'sales_page'
        ) do
          table_for collection.order(created_at: :desc), download_links: false do
            column 'Date/Time' do |sale|
              link_to sale.created_at.to_s(:long), my_transaction_path(sale)
            end
            column 'Customer', &:target_name
            column 'amount'
          end
        end
      end

      div class: 'column md' do
        h1 'Customers'
        amounts = resource.sales.group(:target_name).sum(:amount)
        data = resource.sales.group(:target_name).count.collect do |k, v|
          { avatar_name: k, purchases: v, amount_paid: amounts[k] }
        end
        paginated_data = Kaminari.paginate_array(data)
                                 .page(params[:customer_page]).per(10)

        table_for paginated_data do
          column :avatar_name
          column :purchases
          column :amount_paid
        end
        div id: 'customers-footer' do
          paginate paginated_data, param_name: 'customer_page'
        end
        div class: 'pagination_information' do
          page_entries_info paginated_data, entry_name: 'Customers'
        end
      end
    end

    panel '' do
      div class: 'column lg' do
        render partial: 'vendor_sales_timeline'
      end
    end

  end

  permit_params :object_name, :description, :server_id, :inventory_name, :image_key

  form title: proc { "Edit #{resource.object_name}" } do |f|
    f.inputs do
      div class: 'alert' do
        h1 'Only change the server OR inventory. Changing both will result in errors.'
      end
      f.input :object_name, label: 'Vendor name'
      f.input :description
      f.input :server_id, as: :select, collection: resource.user.servers.map { |s|
        [s.object_name, s.actable.id]
      }
      f.input :inventory_name, as: :select,
                               collection: resource.server.inventories
                                                   .collect(&:inventory_name)
      f.input :image_key
    end
    f.actions
  end

  controller do
    def show
      gon.ids = [resource.id]
      super
    end
    # def scoped_collection
    #   super.includes(%i[user])
    # end
  end
end
