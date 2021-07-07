# frozen_string_literal: true

ActiveAdmin.register Rezzable::Vendor, as: 'Vendor' do
  include ActiveAdmin::RezzableBehavior

  menu label: 'Vendors'

  actions :all, except: %i[new create]

  decorate_with Rezzable::VendorDecorator

  filter :abstract_web_object_object_name, as: :string, label: 'Object Name'
  filter :abstract_web_object_description, as: :string, label: 'Description'
  filter :abstract_web_object_user_avatar_name, as: :string, label: 'Owner'
  filter :abstract_web_object_region, as: :string, label: 'Region'
  filter :web_object_pinged_at, as: :date_range, label: 'Last Ping'
  filter :abstract_web_object_create_at, as: :date_range
  filter :goal

  index title: 'Vendors' do
    selectable_column
    column 'Object Name', sortable: :object_name do |vendor|
      link_to vendor.object_name, admin_vendor_path(vendor)
    end
    column 'Description' do |vendor|
      truncate(vendor.description, length: 10, separator: ' ')
    end
    column 'Location', sortable: :region, &:slurl
    column 'Server', sortable: 'server.object_name' do |vendor|
      link_to vendor.server.object_name,
              admin_server_path(vendor.server) if vendor.server
    end
    column 'Owner', sortable: 'users.avatar_name' do |vendor|
      if vendor.user
        link_to vendor.user.avatar_name, admin_user_path(vendor.user)
      else
        'Orphan'
      end
    end
    column 'Sales ' do |vendor|
      vendor.sales.count
    end
    column 'Revenue' do |vendor|
      vendor.sales.sum(:amount)
    end
    column 'Version', &:semantic_version
    column :status, &:pretty_active

    column :created_at, sortable: :created_at
    actions
  end

  # sidebar :settings, only: %i[edit show] do
  #   attributes_table do
  #     row :show_last_donation
  #     row :show_last_donor
  #     row :show_total
  #     row :show_largest_donation
  #     row :show_biggest_donor
  #     row :goal
  #     row :dead_line
  #   end
  # end

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
      row 'Owner', sortable: 'users.avatar_name' do |vendor|
        if vendor.user
          link_to vendor.user.avatar_name, admin_user_path(vendor.user)
        else
          'Orphan'
        end
      end
      row 'Server' do |vendor|
        if vendor.server
          link_to vendor.server.object_name, admin_server_path(vendor.server)
        else
          ''
        end
      end
      row 'Inventory Name' do |vendor|
        inventory = vendor.server.inventories.find_by_inventory_name(vendor.inventory_name)
        link_to inventory.inventory_name, admin_inventory_path(inventory)
      end
      row :location, &:slurl
      row 'Sales' do |vendor|
        sales = vendor.sales
        "#{sales.sum(:amount)} $L (#{sales.count} sales)"
      end
      row :updated_at
      row :pinged_at
      row :version, &:semantic_version
      row :status, &:pretty_active
    end
    
    panel 'Sales' do 
      paginated_collection(
        resource.sales.page(
          params[:sales_page]
        ).per(10), param_name: 'sales_page'
      ) do 
        table_for collection.order(created_at: :desc), download_links: false do 
          column :created_at
          column 'Customer', &:target_name
          column 'amount'
        end
      end
    end

  #   panel 'Top 10 Donors For This Box' do
  #     counts = resource.transactions.group(:target_name).count
  #     sums = resource.transactions.group(:target_name).order('sum_amount DESC').sum(:amount)
  #     data = sums.collect { |k, v| { donor: k, amount: v, count: counts[k] } }
  #     paginated_data = Kaminari.paginate_array(data).page(params[:donor_page]).per(10)

  #     table_for paginated_data do
  #       column :donor
  #       column :amount
  #       column('Donations') do |item|
  #         item[:count]
  #       end
  #     end
  #   end
  # end
  end

  # sidebar :donations, only: :show do
  #   paginated_collection(
  #     resource.transactions.page(
  #       params[:donation_page]
  #     ).per(10), param_name: 'donation_page'
  #   ) do
  #     table_for collection.order(created_at: :desc).decorate, download_links: false do
  #       column :created_at
  #       column 'Payer/Payee', &:target_name
  #       column :amount
  #     end
  #   end
  # end

  permit_params :object_name, :description, :server_id, :inventory_name

  form title: proc { "Edit #{resource.object_name}" } do |f|


    f.inputs do
      div class: 'alert' do 
        h1 "Only change the server OR inventory. Changing both will result in errors."
      end
      f.input :object_name, label: 'Vendor name'
      f.input :description
      f.input :server_id, as: :select, collection: resource.user.servers.map { |s|
        [s.object_name, s.actable.id]
      }
      f.input :inventory_name, as: :select, 
                               collection: resource.server.inventories.
                                  collect { |inv| inv.inventory_name }
      f.input :image_key
    end
    f.actions
    end

  # controller do
  #   def scoped_collection
  #     super.includes(%i[server user transactions])
  #   end
  # end
end
