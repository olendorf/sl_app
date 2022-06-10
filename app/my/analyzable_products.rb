# frozen_string_literal: true

ActiveAdmin.register Analyzable::Product, namespace: :my, as: 'Product' do
  menu parent: 'Sales', label: 'Products'

  scope_to :current_user

  index titles: 'Products' do
    selectable_column
    column 'Product Name' do |product|
      link_to product.product_name, my_product_path(product)
    end

    column 'Product Links' do |product|
      product.product_links.size
    end
    column 'Revenue', &:revenue
    column 'Units Sold', &:transactions_count
    column :created_at
    column :updated_at
    actions
  end

  filter :product_name
  filter :revenue
  filter :transactions_count
  filter :created_at

  show title: :product_name do
    attributes_table do
      row 'Image' do |product|
        if product.image_key
          image_tag "http://secondlife.com/app/image/#{product.image_key}/1"
        else
          image_tag 'no_image_available'
        end
      end
      row :product_name
      row 'Aliases' do |vendor|
        vendor.product_links.collect(&:link_name).join('; ')
      end
      row 'Owner', sortable: 'users.avatar_name' do |vendor|
        if vendor.user
          link_to vendor.user.avatar_name, my_user_path(vendor.user)
        else
          'Orphan'
        end
      end
      row 'Sales' do |vendor|
        "#{vendor.revenue} $L (#{vendor.transactions_count}})"
      end
      row :created_at
      row :updated_at
    end

    panel '' do
      div class: 'column sm' do
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

      div class: 'column sm' do
        h1 'Customers'
        amounts = resource.sales.group(:target_name).sum(:amount)
        data = resource.sales.group(:target_name).count.sort_by do |_k, v|
          v
        end

        data = data.reverse.collect do |k, v|
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
      # Hash[h.sort_by{|k, v| v}.reverse]
      div class: 'column sm' do
        h1 'Inventories'
        sales = resource.sales.joins(:inventory)
        amounts = sales.group(:inventory_name).sum(:amount)
        data = sales.joins(:inventory).group(:inventory_name).count.sort_by do |_k, v|
          v
        end

        data = data.reverse.collect do |k, v|
          { inventory_name: k, purchases: v, amount_paid: amounts[k] }
        end

        paginated_data = Kaminari.paginate_array(data)
                                 .page(params[:customer_page]).per(10)

        table_for paginated_data do
          column :inventory_name
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
        render partial: 'product_sales_timeline'
      end
    end
  end

  permit_params :product_name, :image_key,
                product_links_attributes: %i[id link_name user_id _destroy]

  form do |f|
    f.inputs do
      f.input :product_name
      f.input :image_key
      f.has_many :product_links,
                 label: 'Aliases',
                 new_record: true,
                 allow_destroy: true do |pl|
        pl.input :link_name
        pl.input :user_id, input_html: { value: current_user.id }, as: :hidden
      end
    end
    f.actions
  end

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :user_id, :image_key, :product_name
  #
  # or
  #
  # permit_params do
  #   permitted = [:user_id, :image_key, :product_name]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  controller do
    def show
      gon.ids = [resource.id]
      super
    end
    # def scoped_collection
    # super.includes(:user)
    # end
  end
end
